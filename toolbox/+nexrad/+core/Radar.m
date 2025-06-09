classdef Radar < nexrad.core.resources.UnderlyingPythonFramework
	%RADAR A class for storing antenna coordinate radar data.
	%
	% This class has been adapted from The Python-ARM Radar Toolkit (pyart.core.radar.Radar) (c) 2013
	% UChicago Argonne, LLC. The original source code for the module can be found at:
	% https://github.com/ARM-DOE/pyart (Version 1.19.5)
	%
	% The structure of the Radar class is based on the CF/Radial Data file
	% format. Global attributes and variables (section 4.1 and 4.3) are
	% represented as a structure in the metadata attribute. Other required and
	% optional variables are represented as structures in a attribute with the
	% same name as the variable in the CF/Radial standard. When a optional
	% attribute not present the attribute has a value of missing. The data for a
	% given variable is stored in the structure under the 'data' field. Moment
	% field data is stored as a structure of structures in the fields
	% attribute. Sub-convention variables are stored as a structure of
	% structures under the meta_group attribute.
	
	properties (Dependent)
		altitude
		altitude_agl
		antenna_transition
		azimuth
		drift
		elevation
		fields
		fixed_angle
		% gate_altitude
		% gate_latitude
		% gate_longitude
		% gate_x
		% gate_y
		% gate_z
		georefs_applied
		heading
		instrument_parameters
		latitude
		longitude
		metadata
		ngates
		nrays
		nsweeps
		pitch
		% projection
		radar_calibration
		range
		ray_angle_res
		rays_are_indexed
		% rays_per_sweep
		roll
		rotation
		scan_rate
		scan_type
		sweep_end_ray_index
		sweep_mode
		sweep_number
		sweep_start_ray_index
		target_scan_rate
		tilt
		time
	end
	
	% Constructor
	methods
		function obj = Radar(filename)
			% For array pre-allocation
			if nargin < 1, return, end
			
			if isstring(filename)
				for iFile = length(filename):-1:1
					try
						RadarPy = py.pyart.io.read_nexrad_archive(filename(iFile));
					catch ME
						hyperref = sprintf('<a href="matlab: disp(''%s'')">[Show]</a>', ME.message);
						warning("NEXRAD:IO:InvalidID", "Python Exception occured while reading '%s', so skipping. " + ...
							"%s", filename(iFile), hyperref);
						continue
					end
					obj(iFile).underlyingDatastore = RadarPy;
				end
				
			elseif isa(filename, "nexrad.aws.resources.LocalNexradFile")
				for iFile = length(filename):-1:1
					try
						RadarPy = py.pyart.io.read_nexrad_archive(filename(iFile).filepath);
					catch ME
						hyperref = sprintf('<a href="matlab: disp(''%s'')">[Show]</a>', ME.message);
						warning("NEXRAD:IO:InvalidID", "Python Exception occured while reading '%s', so skipping. " + ...
							"%s", filename(iFile).filepath, hyperref);
						continue
					end
					obj(iFile).underlyingDatastore = RadarPy;
				end
				
			elseif isa(filename, "py.pyart.core.radar.Radar")
				obj.underlyingDatastore = filename;
				
			else
				error("NEXRAD:CORE:InvalidInput", "'%s' is an unsupported construction class.", class(filename));
			end
		end
	end
	
	% Internal get methods
	methods
		function value = get.altitude(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.altitude);
		end
		
		function value = get.altitude_agl(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.altitude_agl);
		end
		
		function value = get.antenna_transition(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.antenna_transition);
		end
		
		function value = get.azimuth(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.azimuth);
		end
		
		function value = get.drift(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.drift);
		end
		
		function value = get.elevation(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.elevation);
		end
		
		function value = get.fields(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.fields);
		end
		
		function value = get.fixed_angle(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.fixed_angle);
		end
		
		function value = get.georefs_applied(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.georefs_applied);
		end
		
		function value = get.heading(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.heading);
		end
		
		function value = get.instrument_parameters(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.instrument_parameters);
		end
		
		function value = get.latitude(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.latitude);
		end
		
		function value = get.longitude(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.longitude);
		end
		
		function value = get.metadata(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.metadata);
		end
		
		function value = get.ngates(obj)
			value = double(obj.underlyingDatastore.ngates);
		end
		
		function value = get.nrays(obj)
			value = double(obj.underlyingDatastore.nrays);
		end
		
		function value = get.nsweeps(obj)
			value = double(obj.underlyingDatastore.nsweeps);
		end
		
		function value = get.pitch(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.pitch);
		end
		
		function value = get.radar_calibration(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.radar_calibration);
		end
		
		function value = get.range(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.range);
		end
		
		function value = get.ray_angle_res(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.ray_angle_res);
		end
		
		function value = get.rays_are_indexed(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.rays_are_indexed);
		end
		
		function value = get.roll(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.roll);
		end
		
		function value = get.rotation(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.rotation);
		end
		
		function value = get.scan_rate(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.scan_rate);
		end
		
		function value = get.scan_type(obj)
			value = string(obj.underlyingDatastore.scan_type);
		end
		
		function value = get.sweep_end_ray_index(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.sweep_end_ray_index);
			value.data = value.data + 1; % Apply zero-indexing offset (Python -> MATLAB)
		end
		
		function value = get.sweep_mode(~)
			% value = obj.convertPyDict(obj.underlyingDatastore.sweep_mode);
			value = missing; % TODO Stored as a py.memoryview object
		end
		
		function value = get.sweep_number(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.sweep_number);
		end
		
		function value = get.sweep_start_ray_index(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.sweep_start_ray_index);
			value.data = value.data + 1; % Apply zero-indexing offset (Python -> MATLAB)
		end
		
		function value = get.target_scan_rate(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.target_scan_rate);
		end
		
		function value = get.tilt(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.tilt);
		end
		
		function value = get.time(obj)
			value = obj.convertPyDict(obj.underlyingDatastore.time);
		end
	end
	
	% Private functions for checking limits, etc.
	methods (Hidden, Access=private)
		function check_sweep_in_range(obj, sweep)
			% Check that a sweep number is in range.
			arguments
				obj
				sweep (1,:) double
			end
			
			if any(sweep < 1) || any(sweep > obj.nsweeps)
				error("Sweep out of range: %i", sweep);
			end
		end
		
		function check_field_exists(obj, field_name)
			% Check that a field exists in the fields property.
			%
			% ======
			% INPUTS
			% ======
			% field_name (1,1) string
			%     Name of field to check.
			
			arguments
				obj
				field_name (1,1) string
			end
			
			if ~isfield(obj.fields, field_name)
				error("Field not available: %s", field_name);
			end
		end
	end
	
	% Private sweep start/end get methods
	methods (Hidden, Access=private)
		function startIdx = get_start(obj, sweep)
			% Return the starting ray index for a given sweep.
			obj.check_sweep_in_range(sweep);
			startIdx = obj.sweep_start_ray_index.data(sweep);
		end
		
		function endIdx = get_end(obj, sweep)
			% Return the ending ray for a given sweep.
			obj.check_sweep_in_range(sweep)
			endIdx = obj.sweep_end_ray_index.data(sweep);
		end
		
		function [startIdx, endIdx] = get_start_end(obj, sweep)
			% Return the starting and ending ray for a given sweep.
			startIdx = obj.get_start(sweep);
			endIdx = obj.get_end(sweep);
		end
		
		function data = get_slice(obj, sweep)
			% Return a slice for selecting rays for a given sweep.
			
			arguments
				obj
				sweep (1,1) double
			end
			
			[startIdx, endIdx] = obj.get_start_end(sweep);
			data = startIdx:endIdx;
			data = data';
		end
	end
	
	% Public per sweep get methods
	methods
		function data = get_field(obj, sweep, field_name)
			% Return the field data for a given sweep.
			%
			% ======
			% INPUTS
			% ======
			% sweep (1,1) double
			%     Sweep number to retrieve data for, 0 based.
			% field_name (1,1) string
			%     Name of the field from which data should be retrieved.
			%
			% ======
			% OUTPUT
			% ======
			% data (N,obj.nrays) double
			%     Array containing data for the requested sweep and field.
			
			arguments
				obj
				sweep (1,1) double
				field_name (1,1) string
			end
			
			obj.check_field_exists(field_name);
			s = obj.get_slice(sweep);
			data = obj.fields.(field_name).data(s, :);
		end
		
		function azimuths = get_azimuth(obj, sweep)
			% Return an array of azimuth angles for a given sweep.
			%
			% ======
			% INPUTS
			% ======
			% sweep (1,1) double
			%     Sweep number to retrieve data for, 0 based.
			%
			% ======
			% OUTPUT
			% ======
			% azimuths double
			%     Array containing the azimuth angles for a given sweep.
			
			arguments
				obj
				sweep (1,1) double
			end
			
			s = obj.get_slice(sweep);
			azimuths = obj.azimuth.data(s);
		end
		
		function elevation = get_elevation(obj, sweep)
			% Return an array of elevation angles for a given sweep.
			%
			% Parameters
			% ----------
			% sweep : int
			%     Sweep number to retrieve data for, 0 based.
			% copy : bool, optional
			%     True to return a copy of the elevations. False, the default,
			%     returns a view of the elevations (when possible), changing this
			%     data will change the data in the underlying Radar object.
			%
			% Returns
			% -------
			% elevation : array
			%     Array containing the elevation angles for a given sweep.
			
			arguments
				obj
				sweep (1,1) double
			end
			
			s = obj.get_slice(sweep);
			elevation = obj.elevation.data(s);
		end
	end
	
	% Private radar gate conversion
	methods (Hidden, Access=private)
		function [x, y, z] = get_gate_x_y_z(obj, sweep, edges, filter_transitions)
			% Return the x, y and z gate locations in meters for a given sweep.
			%
			% With the default parameter this method returns the same data as
			% contained in the gate_x, gate_y and gate_z attributes but this method
			% performs the gate location calculations only for the specified sweep
			% and therefore is more efficient than accessing this data through these
			% attribute.
			%
			% When used with :py:func:`get_field` this method can be used to obtain
			% the data needed for plotting a radar field with the correct spatial
			% context.
			%
			% Parameters
			% ----------
			% sweep : int
			%     Sweep number to retrieve gate locations from, 0 based.
			% edges : bool, optional
			%     True to return the locations of the gate edges calculated by
			%     interpolating between the range, azimuths and elevations.
			%     False (the default) will return the locations of the gate centers
			%     with no interpolation.
			% filter_transitions : bool, optional
			%     True to remove rays where the antenna was in transition between
			%     sweeps. False will include these rays. No rays will be removed
			%     if the antenna_transition attribute is not available (set to None).
			%
			% Returns
			% -------
			% x, y, z : 2D array
			%     Array containing the x, y and z, distances from the radar in
			%     meters for the center (or edges) for all gates in the sweep.
			% import nexrad.transforms.antenna_vectors_to_cartesian -- TODO -- Do I want to this this instead?
			
			if nargin < 3, edges = false; end
			if nargin < 4, filter_transitions = false; end
			
			azimuths = obj.get_azimuth(sweep);
			elevations = obj.get_elevation(sweep);
			
			if ~ismissing(filter_transitions) && ~ismissing(obj.antenna_transition)
				sweep_slice = obj.get_slice(sweep);
				valid = (obj.antenna_transition.data(sweep_slice) == 0);
				azimuths = azimuths(valid);
				elevations = elevations(valid);
			end
			
			[x, y, z] = nexrad.transforms.antenna_vectors_to_cartesian(obj.range.data, azimuths, elevations, edges);
		end
	end
	
	% Public visualisation methods
	methods
		function pc = pointCloud(obj, field_name, sweep)
			%POINTCLOUD Generate point cloud for a given field and sweep(s).
			%
			% ======
			% INPUTS
			% ======
			% field_name (1,1) string
			%		Name of the field from which data should be retrieved.
			%
			% sweep (1,N) double
			%		Sweep number to retrieve data for, 1 based.
			%
			% ======
			% OUTPUT
			% ======
			% pc (1,1) pointCloud
			%		Point Cloud object representing the measured data for the
			%		given field and sweep(s).
			
			arguments
				obj
				field_name (1,1) string = "reflectivity";
				sweep (1,:) double = 1;
			end
			
			% Input checks
			obj.check_field_exists(field_name);
			obj.check_sweep_in_range(sweep)
			
			% Initialise x, y, z, and data tmp variables
			x = [];
			y = [];
			z = [];
			data = [];
			
			% Turn off warning backtrace
			warning('off', 'backtrace');
			
			% Loop over the number of sweeps
			for iSweep = sweep
				
				% Get the x, y, z coordinates of the gates
				[tmpX, tmpY, tmpZ] = obj.get_gate_x_y_z(iSweep);
				
				% Get the field data
				tmpData = obj.get_field(iSweep, field_name);
				
				% Turn into column vector (due to nature of point cloud, proper order is not required)
				tmpX = reshape(tmpX, [], 1);
				tmpY = reshape(tmpY, [], 1);
				tmpZ = reshape(tmpZ, [], 1);
				tmpData = reshape(tmpData, [], 1);
				
				% Get the index if the invalid entries
				invalidIdx = isnan(tmpData);
				
				% Give warning if the sweep has no valid entries
				if sum(~invalidIdx) == 0
					
					warning('NEXRAD:CORE:InvalidSweepData', '"%s" has no valid entries for sweep %i', field_name, iSweep);
					continue
				end
				
				% Remove invalid x, y, z, and data entries
				tmpX(invalidIdx) = [];
				tmpY(invalidIdx) = [];
				tmpZ(invalidIdx) = [];
				tmpData(invalidIdx) = [];
				
				% Append to new rows
				x = [x; tmpX]; %#ok<AGROW>
				y = [y; tmpY]; %#ok<AGROW>
				z = [z; tmpZ]; %#ok<AGROW>
				data = [data; tmpData]; %#ok<AGROW>
			end
			
			% Apply colour to pointCloud depending on the intensity of the
			% Normalise intensity values
			% dataNorm = data ./ max(data);
			
			% Turn on warning backtrace
			warning('on', 'backtrace');
			
			% Error if there is no sweep data
			if isempty(data)
				error('NEXRAD:CORE:InvalidSweepData', '"%s" has no valid data for any sweeps (%i-%i)', ...
					field_name, min(sweep), max(sweep));
			end
			
			% Generate pointCloud and output
			pc = pointCloud([x, y, z], 'Intensity', data);
		end
		
		function view(obj, fieldName, sweep)
			%VIEW Visualise point cloud data for a given field and sweep(s).
			%
			% ======
			% INPUTS
			% ======
			% field_name (1,1) string
			%		Name of the field from which data should be retrieved.
			%
			% sweep (1,N) double
			%		Sweep number to retrieve data for, 1 based.
			
			arguments
				obj
				fieldName (1,1) string = "reflectivity";
				sweep (1,:) double = 1;
			end
			
			% Input checks
			obj.check_field_exists(fieldName);
			obj.check_sweep_in_range(sweep)
			
			% Get point cloud data
			pc = obj.pointCloud(fieldName, sweep);
			
			% Generate visualisation
			pcviewer(pc, 'CameraProjection', 'orthographic', 'ViewPlane', 'XY', 'ColorSource', 'Intensity', ...
				'PointSize', 0.1);
		end
	end
	
end