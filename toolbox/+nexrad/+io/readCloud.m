function filename = readCloud(varargin)
%READCLOUD
%

% Initialise output
filename = string.empty(1,0);

% Parse inputs (any additional inputs are ignored)
p = inputParser;
p.KeepUnmatched = true;
p.addRequired('radarID', @(z)mustBeText(z));
p.addRequired('startTime', @(z)isdatetime(z));
p.addRequired('endTime', @(z)isdatetime(z));
p.addOptional('saveLocation', string.empty(1,0), @(z)mustBeTextScalar(z));
p.addParameter('awsStructure', true, @(z)islogical(z));
p.addParameter('manual', false, @(z)islogical(z));
p.parse(varargin{:});

% Extract overwritable inputs
saveLocation = p.Results.saveLocation;
awsStructure = p.Results.awsStructure;

% Check if a radar station ID has been given and it is valid
if isempty(p.Results.radarID), error('NEXRAD:IO:InvalidID', 'No radar station ID has been given'); end
if ~any(strcmp(p.Results.radarID, string(enumeration('nexrad.utility.radarID')))), error('NEXRAD:IO:InvalidID', ...
		'ID: "%s" is not a valid NEXRAD or TDWR radar ID', p.Results.radarID); end

try
	% Check if given parameters match valid AWS entries for the nexrad archive and return filepaths to cloud depository
	availScansPy = nexrad.aws.queryAvailScans(p.Results.radarID, p.Results.startTime, p.Results.endTime);
catch ME
	% Python associated "NoneType object is not iterable" error is mostly meaningless so throw more useful error
	error('NEXRAD:IO:InvalidID', 'NCDC database is out of record for radarID "%s" at time range specified by "%s" and "%s"', ...
		p.Results.radar, string(p.Results.startTime), string(p.Results.endTime));
end

% If the save location is empty, download to temp folder in a time-stamped subfolder with AWS structure
if isempty(saveLocation)
	saveLocation = fullfile(tempdir, 'NEXRAD-Database');
end

% TODO -- add ui to allow user to manually choose which of the remote files to download from the list available? [20/03/2025]

% Check the cloud files have not already been downloaded to path (only checks saveLocation or the corresponding aws folder in savelocation)
[missingScansPy, ~, ~, presentScans] = nexrad.aws.checkAvailScans(availScansPy, saveLocation, awsStructure);

if ~isempty(presentScans)
	if awsStructure
		% Use AWS key to get the absolute path to the local files
		filename = [filename, fullfile(saveLocation, presentScans.key)];
	else
		% Generate filename string containing the absolute path to the local files
		filename = [filename, fullfile(saveLocation, presentScans.filename)];
	end
end

if ~isempty(missingScansPy)
	% Download the missing scans to data folder (python format).
	[~, results] = nexrad.aws.downloadAvailScans(missingScansPy, saveLocation, awsStructure);
	
	% Generate filename string containing the absolute path to the downloaded files
	filename = [filename, results.filepath];
end