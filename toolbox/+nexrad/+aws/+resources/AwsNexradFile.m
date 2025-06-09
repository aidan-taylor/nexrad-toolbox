classdef AwsNexradFile < nexrad.core.resources.UnderlyingPythonFramework
	% AWSNEXRADFILE Metadata for remote NEXRAD files on AWS
	% This is a wrapper for py.nexradaws.resources.awsnexradfile.AwsNexradFile
	% objects [1].
	%
	% ==========
	% References
	% ==========
	% ..[1] https://github.com/aarande/nexradaws/blob/master/nexradaws/resources/awsnexradfile.py
	
	properties (Dependent)
		awspath (1,1) string
		filename (1,1) string
		key (1,1) string
		last_modified (1,1) datetime
		radar_id (1,1) string
		scan_time (1,1) datetime
	end
	
	methods % Constructor
		function obj = AwsNexradFile(AwsNexradFilePy)
			%AWSNEXRADFILE
			%
			
			% For array pre-allocation
			if nargin < 1, return, end
			
			if isa(AwsNexradFilePy, "py.nexradaws.resources.awsnexradfile.AwsNexradFile")
				obj.underlyingDatastore = AwsNexradFilePy;
				
			elseif isa(AwsNexradFilePy, "py.list")
				for iScan = length(AwsNexradFilePy):-1:1
					obj(iScan).underlyingDatastore = AwsNexradFilePy{iScan};
				end
				
			else
				error("'%s' is an unsupported construction class.", class(AwsNexradFilePy));
			end
		end
	end
	
	methods % Get methods
		function value = get.awspath(obj)
			value = string(obj.underlyingDatastore.awspath);
		end
		
		function value = get.filename(obj)
			value = string(obj.underlyingDatastore.filename);
		end
		
		function value = get.key(obj)
			value = string(obj.underlyingDatastore.key);
		end
		
		function value = get.last_modified(~)
			value = missing;
		end
		
		function value = get.radar_id(obj)
			value = string(obj.underlyingDatastore.radar_id);
		end
		
		function value = get.scan_time(obj)
			% Need to convert within python to a str so can be read by matlab as a datetime
			[timeStr, zoneStr] = pyrun({'time = input.scan_time', ...
				'timeStr = f"{time:%d-%m-%Y %H:%M:%S}.{time.microsecond // 1000:03d}"', ...
				'zoneStr = time.tzinfo.zone'}, ["timeStr", "zoneStr"], input=obj.underlyingDatastore);
			
			value = datetime(string(timeStr), 'InputFormat', 'dd-MM-yyyy HH:mm:ss.SSS', 'TimeZone', string(zoneStr));
			value.Format = 'dd-MM-yyyy HH:mm:ssZ';
		end
	end
	
end