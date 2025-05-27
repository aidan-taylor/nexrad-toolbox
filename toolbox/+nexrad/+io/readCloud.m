function filename = readCloud(varargin)
	%READCLOUD Read NEXRAD Level 2 Archive AWS Bucket
	% Query bucket for archive files belonging to radarID between startTime and
	% endTime. Checks saveLocation for previously downloaded files then downloads
	% those missing. Returns string of the absolute paths to the files.
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
	% ==================================
	% INPUTS (Name-Value)
	% ==================================
	%
	% saveLocation (1,1) string
	%		Local folder to save downloaded scans to. Also provides the location
	%		to check whether any scans are already downloaded.
	%		(tempdir/NEXRAD-Database, default).
	%
	% awsStructure (1,1) logical
	%		Maintain AWS bucket folder structure (true, default). Download all
	%		files into same folder (false).
	%
	% =======
	% OUTPUTS
	% =======
	%
	% filename (1,M) string
	%		String containing the absolute paths to the downloaded files.
	%
	% ========
	% Examples
	% ========
	%
	% filename = nexrad.io.readCloud([], "KABR", datetime([2025 01 01 00 00 00]), datetime([2025 01 01 01 00 00]));
	%		Downloads the available Level 2 archive files from AWS for KABR on
	%		1st January 2025 between 00:00 and 01:00 and returns the filenames.
	
	% Initialise output
	filename = string.empty(1,0);
	
	% Parse inputs (any additional inputs are ignored)
	p = inputParser;
	p.KeepUnmatched = true;
	p.addRequired('radarID', @(z)mustBeText(z));
	p.addRequired('startTime', @(z)isdatetime(z));
	p.addRequired('endTime', @(z)isdatetime(z));
	p.addParameter('saveLocation', fullfile(tempdir, "NEXRAD-Database"), @(z)mustBeTextScalar(z));
	p.addParameter('awsStructure', true, @(z)islogical(z));
	% p.addParameter('manual', false, @(z)islogical(z)); % TODO [20/03/25]
	p.parse(varargin{:});
	
	% Check if a radar station ID has been given and it is valid
	% if isempty(p.Results.radarID), error('NEXRAD:IO:InvalidID', 'No radar station ID has been given'); end
	% if ~any(strcmp(p.Results.radarID, string(enumeration('nexrad.utility.radarID')))), warning('NEXRAD:IO:InvalidID', ...
	% 		'ID: "%s" is not a valid NEXRAD or TDWR radar ID', p.Results.radarID); end
	
	% Check if given parameters match valid AWS entries for the nexrad archive
	% and return filepaths to cloud depository 
	availScansPy = nexrad.aws.queryAvailScans(p.Results.radarID, p.Results.startTime, p.Results.endTime);
	
	% TODO -- add ui to allow user to manually choose which of the remote files to
	% download from the list available? [20/03/2025]
	
	% Check the cloud files have not already been downloaded to path (only checks
	% saveLocation or the corresponding aws folder in savelocation)
	[missingScansPy, ~, ~, presentScans] = nexrad.aws.checkAvailScans(availScansPy, p.Results.saveLocation, p.Results.awsStructure);
	
	if ~isempty(presentScans)
		if p.Results.awsStructure
			% Use AWS key to get the absolute path to the local files
			filename = [filename, fullfile(p.Results.saveLocation, presentScans.key)];
		else
			% Generate filename string containing the absolute path to the local
			% files
			filename = [filename, fullfile(p.Results.saveLocation, presentScans.filename)];
		end
	end
	
	if ~isempty(missingScansPy)
		% Download the missing scans to data folder (python format).
		[~, results] = nexrad.aws.downloadAvailScans(missingScansPy, p.Results.saveLocation, p.Results.awsStructure);
		
		% Generate filename string containing the absolute path to the downloaded
		% files
		filename = [filename, results.filepath];
	end