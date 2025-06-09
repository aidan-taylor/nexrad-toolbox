classdef DownloadResults < nexrad.core.resources.UnderlyingPythonFramework
	% DOWNLOADRESULTS
	% This is a wrapper for py.nexradaws.resources.downloadresults.DownloadResults
	% objects [1].
	%
	% ==========
	% References
	% ==========
	% ..[1] https://github.com/aarande/nexradaws/blob/master/nexradaws/resources/downloadresults.py
	
	properties (Dependent)
		failed (1,:) nexrad.aws.resources.AwsNexradFile
		failed_count (1,1) double
		success (1,:) nexrad.aws.resources.LocalNexradFile
		success_count (1,1) double
		total (1,1) double
	end
	
	methods % Constructor
		function obj = DownloadResults(DownloadResultsPy)
			if isa(DownloadResultsPy, "py.nexradaws.resources.downloadresults.DownloadResults")
				obj.underlyingDatastore = DownloadResultsPy;
				
			else
				error("'%s' is an unsupported construction class.", class(DownloadResultsPy));
			end
		end
	end
	
	methods % Get methods
		function value = get.failed(obj)
			if obj.failed_count > 0
				value = nexrad.aws.resources.AwsNexradFile(obj.underlyingDatastore.failed);
			else
				value = nexrad.aws.resources.AwsNexradFile.empty(1,0);
			end
		end
		
		function value = get.failed_count(obj)
			value = double(obj.underlyingDatastore.failed_count);
		end
		
		function value = get.success(obj)
			if obj.success_count > 0
				value = nexrad.aws.resources.LocalNexradFile(obj.underlyingDatastore.success);
			else
				value = nexrad.aws.resources.LocalNexradFile.empty(1,0);
			end
		end
		
		function value = get.success_count(obj)
			value = double(obj.underlyingDatastore.success_count);
		end
		
		function value = get.total(obj)
			value = double(obj.underlyingDatastore.total);
		end
	end
	
end