function [resultsPy, results] = downloadAvailScans(availScansPy, location, awsStructure, nThreads)
%DOWNLOADAVAILSCANS Download selected scans to local drive and report success/fail metadata.
%
% Downloads the given scan data from the AWS NEXRAD Archive. Returns the metadata required to read the files from the
% local system.
%
% INPUTS
% availScans (py.list) - List containing the metadata for each of the scan available in the AWS NEXRAD archive. Fields
%									are: awspath, key, scan_time, radar_id, filename, last_modified (unused).
% location (string) - Local drive path to desired download folder.
% awsStructure (logical) - Whether or not to use the AWS folder structure inside the download location...
%									(year/month/day/radar/).
%
% OUTPUTS
% results (struct) - Structure containing the metadata for each of the scans downloaded from the AWS NEXRAD archive.
%								Fields are: awspath, key, scan_time, radar_id, filename, failed (if download(s) unsuccessful).
% resultsPy (py.list) - Python list containing the raw metadata for downloaded scans to enable direct compatibility
%									further in work flow
%
% We will access data from the **noaa-nexrad-level2** bucket, with the data organized as:
% "s3://noaa-nexrad-level2/year/month/date/radarsite/{radarsite}{year}{month}{date}_{hour}{minute}{second}_V06"
%

arguments
	availScansPy (1,:) py.list
	location (1,1) string = pwd;
	awsStructure (1,1) logical = true;
	nThreads (1,1) double = 6;
end

% Initialise python AWS interface
conn = py.nexradaws.NexradAwsInterface();

% Attempt download of all available scan files
resultsPy = conn.download(availScansPy, location, keep_aws_folders=awsStructure, threads=nThreads);

% TODO Handle download failures?
% if double(resultsPy.failed_count) > 0
% end

% Convert information to matlab friendly format if desired (usually called with [~, results])
if nargout > 1
	% Convert success and output so can be further used
	results = nexrad.conversions.pyAwsNexradFile(resultsPy.success);
end