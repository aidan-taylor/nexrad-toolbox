classdef (Abstract) UnderlyingPythonFramework
	%UNDERLYINGPYTHON Provides a framework for storing and interacting with
	% underlying Python objects.
	% This is an internal class definition.
	
	properties (Hidden, SetAccess=protected, GetAccess=protected)
		underlyingDatastore (1,1) % Store original python object
	end
	
	% Public backend methods
	methods (Sealed, Access=public)
		function value = aslist(obj)
			%ASLIST Convert object into python list
			% The cell array is converted into a tuple which is then unpacked
			value = pyrun("value = [*tup]", "value", tup={obj.underlyingDatastore});
		end
		
	end
	
	% Protected backend methods
	methods (Sealed, Hidden, Access=protected)
		function value = convertPyDict(obj, dict)
			%CONVERTPYDICT Recursively converts a python dictionary into a
			% structure (nested dictionary to nested structure). If the
			% dictionary is missing (Python None) then a 'missing' object is
			% returned. For a MaskedArray, the mask is applied during the
			% conversion.
			
			if isa(dict, "py.NoneType")
				value = missing;
				return
				
			else
				tmp = dictionary(dict);
				
				for sField = tmp.keys'
					if startsWith(sField{:}, "_"), continue, end
					
					if isa(dict{sField{:}}, "py.str")
						value.(sField{:}) = string(dict{sField{:}});
						
					elseif isa(dict{sField{:}}, "py.numpy.ma.MaskedArray")
						value.(sField{:}) = double(dict{sField{:}}.data);
						invalidIdx = logical(dict{sField{:}}.mask);
						value.(sField{:})(invalidIdx) = NaN;
						
					elseif isa(dict{sField{:}}, "py.numpy.ndarray")
						value.(sField{:}) = double(dict{sField{:}});
						
					elseif isa(dict{sField{:}}, "py.dict")
						value.(sField{:}) = obj.convertPyDict(dict{sField{:}});
						
					elseif isa(dict{sField{:}}, "double")
						value.(sField{:}) = dict{sField{:}};
						
					else
						warning("'%s' is an unsupported conversion class.", class(dict{sField{:}}));
						continue
					end
				end
			end
		end
		
	end
	
end