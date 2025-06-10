function results = downloadAvailScans(missingScans, location, awsStructure, nThreads)
	%DOWNLOADAVAILSCANS Download selected scans to a local drive and report
	% success/fail metadata. 
	%
	% This is a wrapper for py.nexradaws.NexradAwsInterface().download()
	% function [1]. Currently download errors are not handled.
	%
	% =================
	% INPUTS (Required)
	% =================
	% missingScans (1,N) nexrad.aws.resources.AwsNexradFile
	%		Object array containing the metadata for each of the scan available
	%		in the AWS bucket. This is typically output directly by
	%		nexrad.aws.checkAvailScans or by nexrad.aws.queryAvailScans. 
	%
	% =================
	% INPUTS (Optional)
	% =================
	% location (1,1) string
	%		Local drive path to desired download folder.
	%
	% awsStructure (1,1) logical
	%		Whether or not to use the AWS folder structure inside the download
	%		location. This is in the form: "../year/month/day/radarsite/".
	%
	% nThreads (1,1) double
	%		The number of processor threads used to concurrently download
	%		files. This is the number of physical cores of a system rather than
	%		virtual threads.
	%
	% =======
	% OUTPUTS
	% =======
	% results (1,1) nexrad.aws.resources.AwsNexradFile
	%		Object containing the metadata for successful and failed downloads.
	%
	% ==========
	% References
	% ==========
	% ..[1] https://github.com/aarande/nexradaws/blob/master/nexradaws/nexradawsinterface.py
	% ..[2] We will access data from the **noaa-nexrad-level2** bucket, with the data organized as:
	% "s3://noaa-nexrad-level2/year/month/date/radarsite/{radarsite}{year}{month}{date}_{hour}{minute}{second}_V06"
	
	arguments (Input)
		missingScans (1,:) nexrad.aws.resources.AwsNexradFile
		location (1,1) string = fullfile(tempdir, "NEXRAD-Database");
		awsStructure (1,1) logical = true;
		nThreads (1,1) double = 6;
	end
	
	arguments (Output)
		results (1,1) nexrad.aws.resources.DownloadResults
	end
	
	% Initialise python AWS interface
	conn = py.nexradaws.NexradAwsInterface();
	
	% Attempt download of all missing scan files [2]
	resultsPy = conn.download(missingScans.aslist, location, keep_aws_folders=awsStructure, threads=nThreads);
	
	% Convert to matlab friendly format
	results = nexrad.aws.resources.DownloadResults(resultsPy);
	
	% TODO Handle download failures?
	% if results.failed_count > 0
	% end