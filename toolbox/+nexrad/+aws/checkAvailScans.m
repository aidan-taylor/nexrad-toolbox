function [missingScansPy, presentScansPy, missingScans, presentScans] = checkAvailScans(availScansPy, location, keepAwsStructure)
%CHECKAVAILSCANS Checks if scans are already downloaded to local drive.
%

arguments
	availScansPy (1,:) py.list
	location (1,1) string = pwd;
	keepAwsStructure (1,1) logical = false;
end

% For glob, we need to ensure the filesep is forward slash to prevent string codes
location = strrep(location, '\', '/');

% Form python code to run
pyCode = {...
	'import os', ...
	'from glob import glob', ... % Needed to get files in folder
	'', ...
	'missingScans = []', ... % Initialise outputs
	'presentScans = []', ...
	'', ...
	'dataFolder = os.path.join(location, "*")', ... % Form path to every file in root folder (no extension)
	'downloadedFiles = glob(dataFolder)', ... % Get list of files in folder
	'', ...
	'for iScan in range(len(availScans)):', ... % Loop over the number of scans
	'', ...
	'	if availScans[iScan].filename.endswith("MDM"):', ... (short circuit)
	'		continue', ... % Skip files that end in MPM as this is unreadable by the pyart module (maintenance?)
	'', ...
	'	if aws:', ... % If AWS folder structure is maintained
	'		dataFolder = os.path.join(location, availScans[iScan].awspath, "*")', ... % Form current loop datapath (in aws)
	... % ('\' will not escape as aws path aways starts with year)
	'		downloadedFiles = glob(dataFolder)', ... % Get list of files in folder (regenerates every loop in case the aws path changes)
	'', ...
	'	if any(availScans[iScan].filename in sFile for sFile in downloadedFiles):', ...
	'		presentScans.append(availScans[iScan])', ... % If the scan file is in the local folder, add to present list
	'', ...
	'	else:', ...
	'		missingScans.append(availScans[iScan])', ... % Otherwise, add to missing list
	};

% Run python code and return the missing scans
[missingScansPy, presentScansPy] = pyrun(pyCode, ["missingScans", "presentScans"], availScans=availScansPy, location=location, aws=keepAwsStructure);

% Convert information to matlab friendly format if desired (usually called with [~, missingScans])
if nargout > 2, missingScans = nexrad.conversions.pyAwsNexradFile(missingScansPy); end

% Convert information to matlab friendly format if desired (usually called with [~, ~, ~, presentScans])
if nargout > 3, presentScans = nexrad.conversions.pyAwsNexradFile(presentScansPy); end