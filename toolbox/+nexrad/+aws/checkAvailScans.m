function [missingScansPy, presentScansPy, missingScans, presentScans] = checkAvailScans(availScansPy, location, awsStructure)
%CHECKAVAILSCANS Checks if scans are already downloaded to local drive.
%

arguments
	availScansPy (1,:) py.list
	location (1,1) string = pwd;
	awsStructure (1,1) logical = true;
end

% For glob, we need to ensure the filesep is forward slash to prevent string codes
location = strrep(location, '\', '/');

% Run python code and return the missing scans
[missingScansPy, presentScansPy] = pyrunfile("+nexrad/+aws/checkAvailScans.py", ["missingScans", "presentScans"], ...
	availScans=availScansPy, location=location, awsStructure=awsStructure);

% Convert information to matlab friendly format if desired (usually called with [~, missingScans])
if nargout > 2, missingScans = nexrad.conversions.pyAwsNexradFile(missingScansPy); end

% Convert information to matlab friendly format if desired (usually called with [~, ~, ~, presentScans])
if nargout > 3, presentScans = nexrad.conversions.pyAwsNexradFile(presentScansPy); end