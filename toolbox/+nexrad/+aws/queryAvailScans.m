function [availScansPy, availScans] = queryAvailScans(radarID, startTime, endTime)
% QUERYAVAILSCANS Return file IDs of available scans in AWS bucket for a given
% radar between two points in time.  
%
% Checks AWS NEXRAD Archive for scan data for the given station between the
% given time range. Returns the metadata required to download or read the files
% direct from the cloud. 
%
% INPUTS
% radar (string) - Four letter ICAO name of the NEXRAD station from which the
%				   scans are desired. For a mapping of ICAO to station name, see
%				   https://www.roc.noaa.gov/branches/program-branch/site-id-database/site-id-network-sites.php. 
% startTime (datetime) - Start of the time range between which scans are desired.
% endTime (datetime) - End of the time range between which scans are desired.
%
% OUTPUTS
% availScansPy (py.list) - Python list containing the raw metadata for the
%						   available scans to enable direct compatibility
%						   further in work flow   
%
% availScans (struct) - Structure containing the metadata for each of the scan
%						available in the AWS NEXRAD archive. Fields are:
%						awspath, key,  scan_time, radar_id, filename. 
%
% We will access data from the **noaa-nexrad-level2** bucket, with the data organized as: 
% "s3://noaa-nexrad-level2/year/month/date/radarsite/{radarsite}{year}{month}{date}_{hour}{minute}{second}_V06"
%
% TODO -- Loop over the number of radar IDs given and time ranges? [20/03/2025]
arguments
	radarID (1,:) string
	startTime (1,:) datetime
	endTime (1,:) datetime
end

% Convert string array to cell
radarID = cellstr(radarID);

% Run python code and return the missing scans
availScansPy = pyrunfile("+nexrad/+aws/queryAvailScans.py", "availScans", ...
	radarID=radarID, startTime=startTime, endTime=endTime);

% Convert information to matlab friendly format if desired (usually called with
% [~, availscans]) 
if nargout > 1
	availScans = nexrad.conversions.pyAwsNexradFile(availScansPy);
end