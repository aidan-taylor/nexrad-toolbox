function [availScansPy, availScans] = queryAvailScans(radarID, startTime, endTime)
	% QUERYAVAILSCANS Return file IDs of available scans in AWS bucket for a given
	% radar between two points in time.
	%
	% Checks AWS NEXRAD Archive for scan data for the given station between the
	% given time range. Returns the metadata required to download or read the files
	% direct from the cloud. 
	% 
	% There is an edge case where some queries starting or ending at 00:00 can
	% fail due to the MATLAB-Python conversion missing the time. This is
	% currently unhandled.
	% 
	% =================================
	% INPUTS (Required)
	% =================================
	%
	% radarID (1,N) string
	%		Four letter ICAO name of the NEXRAD station from which the scans are
	%		desired. For a mapping of ICAO to station name, see
	%		https://www.roc.noaa.gov/branches/program-branch/site-id-database/site-id-network-sites.php.
	%
	% startTime (1,N) datetime
	%		Start of the time range between which scans are desired. If not
	%		specified, timezone is assumed UTC.
	%
	% endTime (1,N) datetime
	%		End of the time range between which scans are desired. If not
	%		specified, timezone is assumed UTC.
	%
	% =======
	% OUTPUTS
	% =======
	%
	% availScansPy (1,M) py.list
	%		Python list containing the raw metadata for the available scans to
	%		enable direct compatibility further in work flow
	%
	% availScans (1,1) struct
	%		Structure containing the metadata for each of the scan available in
	%		the AWS NEXRAD archive. Fields are: awspath, key, scan_time,
	%		radar_id, filename.
	%
	% ========
	% Examples
	% ========
	%
	% availScansPy = nexrad.aws.queryAvailScans("KABR", datetime([2025 01 01 09 00 00]), datetime([2025 01 01 10 00 00]));
	%		Returns the Level 2 archive files available in AWS for KABR on
	%		1st January 2025 between 09:00 and 10:00. This is formatted as a
	%		py.list variable containing a list of AwsNexradFile objects.
	%
	% availScansPy = nexrad.aws.queryAvailScans("KABR", ...
	% datetime([2023 01 01 09 00 00; 2024 01 01 09 00 00; 2025 01 01 09 00 00]), ...
	% datetime([2023 01 01 10 00 00; 2024 01 01 10 00 00; 2025 01 01 10 00 00]));
	%		Returns the Level 2 archive files available in AWS for KABR on
	%		1st January 2023 between 09:00 and 10:00, 1st January 2024 between
	%		00:00 and 01:00, and 1st January 2025 between 00:00 and 01:00.
	%
	% [~, availScans] = nexrad.aws.queryAvailScans(["KABR", "KABX", "KAKQ"], ...
	% datetime([2025 01 01 09 00 00]), datetime([2025 01 01 10 00 00]));
	%		Returns the available archives for each of KABR, KABX, and KAKQ on
	%		1st January 2025 between 09:00 and 10:00. The output has been
	%		converted to a structure containing each field of the AwsNexradFile
	%		object.
	%
	% [availScansPy, availScans] = nexrad.aws.queryAvailScans(["KABR", "KABX", "KAKQ"], ...
	% datetime([2023 01 01 09 00 00; 2024 01 01 09 00 00; 2025 01 01 09 00 00]), ...
	% datetime([2023 01 01 10 00 00; 2024 01 01 10 00 00; 2025 01 01 10 00 00]));
	%		Returns the Level 2 archive files available in AWS for KABR on
	%		1st January 2023 between 09:00 and 10:00, KABX on 1st January 2024 between
	%		09:00 and 10:00, and KAKQ 1st January 2025 between 09:00 and 10:00.
	%		Outputs both the raw python list and the converted structure.
	%
	% ==========
	% References
	% ==========
	%
	% ..[1] We will access data from the **noaa-nexrad-level2** bucket, with the data organized as:
	% "s3://noaa-nexrad-level2/year/month/date/radarsite/{radarsite}{year}{month}{date}_{hour}{minute}{second}_V06"
	
	arguments
		radarID (1,:) string
		startTime (1,:) datetime
		endTime (1,:) datetime
	end
	
	% Assert matching dimensions are given
	if isscalar(radarID)
		
		if length(startTime) ~= length(endTime)
			error('NEXRAD:AWS:InvalidInput', ['radarID is a scalar so startTime and ' ...
				'endTime must have the same dimensions']);
		end
	else
		
		if ~isscalar(startTime) && length(radarID) ~= length(startTime)
			error('NEXRAD:AWS:InvalidInput', ['radarID is a vector so startTime must ' ...
				'either be a scalar or a vector with the same length as radarID']);
		end
		
		if ~isscalar(endTime) && length(radarID) ~= length(endTime)
			error('NEXRAD:AWS:InvalidInput', ['radarID is a vector so endTime must ' ...
				'either be a scalar or a vector with the same length as radarID']);
		end
	end
	
	% Convert string array to cell
	radarID = cellstr(radarID);
	
	% Run python code and return the missing scans [1]
	availScansPy = pyrunfile("+nexrad/+aws/+resources/queryAvailScans.py", "availScans", ...
		radarID=radarID, startTime=startTime, endTime=endTime);
	
	% Convert information to matlab friendly format if desired (usually called with
	% [~, availscans])
	if nargout > 1
		availScans = nexrad.conversions.pyAwsNexradFile(availScansPy);
	end