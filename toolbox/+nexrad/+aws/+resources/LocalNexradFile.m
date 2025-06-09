classdef LocalNexradFile < nexrad.core.resources.UnderlyingPythonFramework
	% LOCALNEXRADFILE Metadata for local NEXRAD files
	% This is a wrapper for py.nexradaws.resources.localnexradfile.LocalNexradFile
	% objects [1].
	%
	% ==========
	% References
	% ==========
	% ..[1] https://github.com/aarande/nexradaws/blob/master/nexradaws/resources/localnexradfile.py
	
	properties (Dependent)
		filename (1,1) string
		filepath (1,1) string
		key (1,1) string
		last_modified (1,1) datetime
		radar_id (1,1) string
		scan_time (1,1) datetime
	end
	
	properties (Hidden, SetAccess=immutable, GetAccess=private)
		awsStructure (1,1) logical
		location (1,1) string % Store the local folder present in (this is an artefact of
		% nexrad.aws.checkAvailScans which actually passes a AwsNexradFile when
		% assigning present scans and so has no filepath property to extract)
	end
	
	methods % Constructor
		function obj = LocalNexradFile(LocalNexradFilePy, location, awsStructure)
			% For array pre-allocation
			if nargin < 1, return, end
			
			if isa(LocalNexradFilePy, "py.nexradaws.resources.localnexradfile.LocalNexradFile")
				obj.underlyingDatastore = LocalNexradFilePy;
				
			elseif isa(LocalNexradFilePy, "py.nexradaws.resources.awsnexradfile.AwsNexradFile")
				if nargin ~= 3
					error("If a '%s' object is passed, the folder it is downloaded in and whether the AWS folder " + ...
						"structure was maintained during download must also be passed", class(LocalNexradFilePy));
				end
				obj.location = location;
				obj.awsStructure = awsStructure;
				
			elseif isa(LocalNexradFilePy, "py.list")
				for iScan = length(LocalNexradFilePy):-1:1
					obj(iScan).underlyingDatastore = LocalNexradFilePy{iScan};
					
					if isa(LocalNexradFilePy{iScan}, "py.nexradaws.resources.awsnexradfile.AwsNexradFile")
						if nargin ~= 3
							error("If a '%s' object is passed, the folder it is downloaded in and whether the AWS folder " + ...
								"structure was maintained during download must also be passed", class(LocalNexradFilePy{iScan}));
						end
						obj(iScan).location = location;
						obj(iScan).awsStructure = awsStructure;
					end
				end

			else
				error("'%s' is an unsupported construction class.", class(LocalNexradFilePy));
			end
		end
	end
	
	methods % Get methods
		function value = get.filename(obj)
			value = string(obj.underlyingDatastore.filename);
		end
		
		function value = get.filepath(obj)
			if obj.location == ""
				value = string(obj.underlyingDatastore.filepath);
				value = strrep(value, '\', '/');
			else
				if obj.awsStructure
					value = fullfile(obj.location, obj.key);
				else
					value = fullfile(obj.location, obj.filename);
				end
				value = strrep(value, '\', '/');
			end
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