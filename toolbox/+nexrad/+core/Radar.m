classdef Radar
	%RADAR A class for storing antenna coordinate radar data.
	%
	% This class has been adapted from The Python-ARM Radar Toolkit (pyart.core.radar.Radar) (c) 2013
	% UChicago Argonne, LLC. The original source code for the module can be found at:
	% https://github.com/ARM-DOE/pyart (Version 1.19.5)
	%
	% The structure of the Radar class is based on the CF/Radial Data file
	% format. Global attributes and variables (section 4.1 and 4.3) are
	% represented as a dictionary in the metadata attribute. Other required and
	% optional variables are represented as dictionaries in a attribute with the
	% same name as the variable in the CF/Radial standard. When a optional
	% attribute not present the attribute has a value of None. The data for a
	% given variable is stored in the dictionary under the 'data' key. Moment
	% field data is stored as a dictionary of dictionaries in the fields
	% attribute. Sub-convention variables are stored as a dictionary of
	% dictionaries under the meta_group attribute.
	%
	% Refer to the attribute section for information on the parameters.
	%
	% Attributes
	% ----------
	% time : struct
	%     Time at the center of each ray.
	% range : struct
	%     Range to the center of each gate (bin).
	% fields : struct of structs
	%     Moment fields.
	% metadata : struct
	%     Metadata describing the instrument and data.
	% scan_type : string
	%     Type of scan, one of 'ppi', 'rhi', 'sector' or 'other'. If the scan
	%     volume contains multiple sweep modes this should be 'other'.
	% latitude : struct
	%     Latitude of the instrument.
	% longitude : struct
	%     Longitude of the instrument.
	% altitude : struct
	%     Altitude of the instrument, above sea level.
	% altitude_agl : struct or missing
	%     Altitude of the instrument above ground level. If not provided this
	%     attribute is set to missing, indicating this parameter not available.
	% sweep_number : struct
	%     The number of the sweep in the volume scan, 0-based.
	% sweep_mode : struct
	%     Sweep mode for each mode in the volume scan.
	% fixed_angle : struct
	%     Target angle for thr sweep. Azimuth angle in RHI modes, elevation
	%     angle in all other modes.
	% sweep_start_ray_index : struct
	%     Index of the first ray in each sweep relative to the start of the
	%     volume, 0-based.
	% sweep_end_ray_index : struct
	%     Index of the last ray in each sweep relative to the start of the
	%     volume, 0-based.
	% rays_per_sweep : LazyLoadDict
	%     Number of rays in each sweep. The data key of this attribute is
	%     create upon first access from the data in the sweep_start_ray_index and
	%     sweep_end_ray_index attributes. If the sweep locations needs to be
	%     modified, do this prior to accessing this attribute or use
	%     :py:func:`init_rays_per_sweep` to reset the attribute.
	% target_scan_rate : struct or missing
	%     Intended scan rate for each sweep. If not provided this attribute is
	%     set to missing, indicating this parameter is not available.
	% rays_are_indexed : struct or missing
	%     Indication of whether ray angles are indexed to a regular grid in
	%     each sweep. If not provided this attribute is set to missing, indicating
	%     ray angle spacing is not determined.
	% ray_angle_res : struct or missing
	%     If rays_are_indexed is not missing, this provides the angular resolution
	%     of the grid. If not provided or available this attribute is set to
	%     missing.
	% azimuth : struct
	%     Azimuth of antenna, relative to true North. Azimuth angles are
	%     recommended to be expressed in the range of [0, 360], but other
	%     representations are not forbidden.
	% elevation : struct
	%     Elevation of antenna, relative to the horizontal plane. Elevation
	%     angles are recommended to be expressed in the range of [-180, 180],
	%     but other representations are not forbidden.
	% gate_x, gate_y, gate_z : LazyLoadDict
	%     Location of each gate in a Cartesian coordinate system assuming a
	%     standard atmosphere with a 4/3 Earth's radius model. The data keys of
	%     these attributes are create upon first access from the data in the
	%     range, azimuth and elevation attributes. If these attributes are
	%     changed use :py:func:`init_gate_x_y_z` to reset.
	% gate_longitude, gate_latitude : LazyLoadDict
	%     Geographic location of each gate. The projection parameter(s) defined
	%     in the `projection` attribute are used to perform an inverse map
	%     projection from the Cartesian gate locations relative to the radar
	%     location to longitudes and latitudes. If these attributes are changed
	%     use :py:func:`init_gate_longitude_latitude` to reset the attributes.
	% projection : struct or string
	%     Projection parameters defining the map projection used to transform
	%     from Cartesian to geographic coordinates. The default dictionary sets
	%     the 'proj' key to 'pyart_aeqd' indicating that the native Py-ART
	%     azimuthal equidistant projection is used. This can be modified to
	%     specify a valid pyproj.Proj projparams dictionary or string.
	%     The special key '_include_lon_0_lat_0' is removed when interpreting
	%     this dictionary. If this key is present and set to True, which is
	%     required when proj='pyart_aeqd', then the radar longitude and
	%     latitude will be added to the dictionary as 'lon_0' and 'lat_0'.
	% gate_altitude : LazyLoadDict
	%     The altitude of each radar gate as calculated from the altitude of the
	%     radar and the Cartesian z location of each gate. If this attribute
	%     is changed use :py:func:`init_gate_altitude` to reset the attribute.
	% scan_rate : struct or missing
	%     Actual antenna scan rate. If not provided this attribute is set to
	%     missing, indicating this parameter is not available.
	% antenna_transition : struct or missing
	%     Flag indicating if the antenna is in transition, 1 = yes, 0 = no.
	%     If not provided this attribute is set to missing, indicating this
	%     parameter is not available.
	% rotation : struct or missing
	%     The rotation angle of the antenna. The angle about the aircraft
	%     longitudinal axis for a vertically scanning radar.
	% tilt : struct or missing
	%     The tilt angle with respect to the plane orthogonal (Z-axis) to
	%     aircraft longitudinal axis.
	% roll : struct or missing
	%     The roll angle of platform, for aircraft right wing down is positive.
	% drift : struct or missing
	%     Drift angle of antenna, the angle between heading and track.
	% heading : struct or missing
	%     Heading (compass) angle, clockwise from north.
	% pitch : struct or missing
	%     Pitch angle of antenna, for aircraft nose up is positive.
	% georefs_applied : struct or missing
	%     Indicates whether the variables have had georeference calculation
	%     applied.  Leading to Earth-centric azimuth and elevation angles.
	% instrument_parameters : struct of structs or missing
	%     Instrument parameters, if not provided this attribute is set to missing,
	%     indicating these parameters are not avaiable. This dictionary also
	%     includes variables in the radar_parameters CF/Radial subconvention.
	% radar_calibration : struct of structs or missing
	%     Instrument calibration parameters. If not provided this attribute is
	%     set to missing, indicating these parameters are not available
	% ngates : double
	%     Number of gates (bins) in a ray.
	% nrays : double
	%     Number of rays in the volume.
	% nsweeps : double
	%     Number of sweep in the volume.
	
	properties
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
	
	methods
		function self = Radar(varargin)
		%RADAR Construct an instance of this class
		%   Detailed explanation goes here
		% if isempty(varargin), return, end
		if isempty(varargin), return, end 
		
		inputs = self.parseInputs(varargin{:});
		
		self.time = inputs.time;
		self.range = inputs.range;
		
		self.fields = inputs.fields;
		self.metadata = inputs.metadata;
		self.scan_type = inputs.scan_type;
		
		self.latitude = inputs.latitude;
		self.longitude = inputs.longitude;
		self.altitude = inputs.altitude;
		self.altitude_agl = inputs.altitude_agl; % optional
		
		self.sweep_number = inputs.sweep_number;
		self.sweep_mode = inputs.sweep_mode;
		self.fixed_angle = inputs.fixed_angle;
		self.sweep_start_ray_index = inputs.sweep_start_ray_index;
		self.sweep_end_ray_index = inputs.sweep_end_ray_index;
		
		self.target_scan_rate = inputs.target_scan_rate;  % optional
		self.rays_are_indexed = inputs.rays_are_indexed;  % optional
		self.ray_angle_res = inputs.ray_angle_res;  % optional
		
		self.azimuth = inputs.azimuth;
		self.elevation = inputs.elevation;
		self.scan_rate = inputs.scan_rate;  % optional
		self.antenna_transition = inputs.antenna_transition;  % optional
		self.rotation = inputs.rotation;  % optional
		self.tilt = inputs.tilt;  % optional
		self.roll = inputs.roll;  % optional
		self.drift = inputs.drift;  % optional
		self.heading = inputs.heading;  % optional
		self.pitch = inputs.pitch;  % optional
		self.georefs_applied = inputs.georefs_applied;  % optional
		
		self.instrument_parameters = inputs.instrument_parameters;  % optional
		self.radar_calibration = inputs.radar_calibration;  % optional
		
		self.ngates = length(inputs.range.data);
		self.nrays = length(inputs.time.data);
		self.nsweeps = length(inputs.sweep_number.data);
		% self.projection = {"proj": "pyart_aeqd", "_include_lon_0_lat_0": True}
		end
		
		function inputs = parseInputs(~, varargin)
		% Parses the required and optional inputs to the constructor
		p = inputParser;
		p.StructExpand = false;
		
		p.addRequired('time', @(x)isstruct(x));
		p.addRequired('range', @(x)isstruct(x));
		p.addRequired('fields', @(x)isstruct(x));
		p.addRequired('metadata', @(x)isstruct(x));
		p.addRequired('scan_type', @(x)mustBeTextScalar(x));
		p.addRequired('latitude', @(x)isstruct(x));
		p.addRequired('longitude', @(x)isstruct(x));
		p.addRequired('altitude', @(x)isstruct(x));
		p.addRequired('sweep_number', @(x)isstruct(x));
		p.addRequired('sweep_mode', @(x)isstruct(x));
		p.addRequired('fixed_angle', @(x)isstruct(x));
		p.addRequired('sweep_start_ray_index', @(x)isstruct(x));
		p.addRequired('sweep_end_ray_index', @(x)isstruct(x));
		p.addRequired('azimuth', @(x)isstruct(x));
		p.addRequired('elevation', @(x)isstruct(x));
		
		p.addParameter('altitude_agl', missing, @(x)any([isstruct(x), ismissing(x)]));
		p.addParameter('target_scan_rate', missing, @(x)any([isstruct(x), ismissing(x)]));
		p.addParameter('rays_are_indexed', missing, @(x)any([isstruct(x), ismissing(x)]));
		p.addParameter('ray_angle_res', missing, @(x)any([isstruct(x), ismissing(x)]));
		p.addParameter('scan_rate', missing, @(x)any([isstruct(x), ismissing(x)]));
		p.addParameter('antenna_transition', missing, @(x)any([isstruct(x), ismissing(x)]));
		p.addParameter('instrument_parameters', missing, @(x)any([isstruct(x), ismissing(x)]));
		p.addParameter('radar_calibration', missing, @(x)any([isstruct(x), ismissing(x)]));
		p.addParameter('rotation', missing, @(x)any([isstruct(x), ismissing(x)]));
		p.addParameter('tilt', missing, @(x)any([isstruct(x), ismissing(x)]));
		p.addParameter('roll', missing, @(x)any([isstruct(x), ismissing(x)]));
		p.addParameter('drift', missing, @(x)any([isstruct(x), ismissing(x)]));
		p.addParameter('heading', missing, @(x)any([isstruct(x), ismissing(x)]));
		p.addParameter('pitch', missing, @(x)any([isstruct(x), ismissing(x)]));
		p.addParameter('georefs_applied', missing, @(x)any([isstruct(x), ismissing(x)]));
		
		p.parse(varargin{:});
		inputs = p.Results;
		end
	end
	
	% TODO -- Do I need the getstate / setstate functions?
	
	% Attribute init/reset method
	methods
		% 	def init_rays_per_sweep(self):
		%     """Initialize or reset the rays_per_sweep attribute."""
		%     lazydic = LazyLoadDict(get_metadata("rays_per_sweep"))
		%     lazydic.set_lazy("data", _rays_per_sweep_data_factory(self))
		%     self.rays_per_sweep = lazydic
		%
		% def init_gate_x_y_z(self):
		%     """Initialize or reset the gate_{x, y, z} attributes."""
		%     gate_x = LazyLoadDict(get_metadata("gate_x"))
		%     gate_x.set_lazy("data", _gate_data_factory(self, 0))
		%     self.gate_x = gate_x
		%
		%     gate_y = LazyLoadDict(get_metadata("gate_y"))
		%     gate_y.set_lazy("data", _gate_data_factory(self, 1))
		%     self.gate_y = gate_y
		%
		%     gate_z = LazyLoadDict(get_metadata("gate_z"))
		%     gate_z.set_lazy("data", _gate_data_factory(self, 2))
		%     self.gate_z = gate_z
		%
		% def init_gate_longitude_latitude(self):
		%     """
		%     Initialize or reset the gate_longitude and gate_latitude attributes.
		%     """
		%     gate_longitude = LazyLoadDict(get_metadata("gate_longitude"))
		%     gate_longitude.set_lazy("data", _gate_lon_lat_data_factory(self, 0))
		%     self.gate_longitude = gate_longitude
		%
		%     gate_latitude = LazyLoadDict(get_metadata("gate_latitude"))
		%     gate_latitude.set_lazy("data", _gate_lon_lat_data_factory(self, 1))
		%     self.gate_latitude = gate_latitude
		%
		% def init_gate_altitude(self):
		%     """Initialize the gate_altitude attribute."""
		%     gate_altitude = LazyLoadDict(get_metadata("gate_altitude"))
		%     gate_altitude.set_lazy("data", _gate_altitude_data_factory(self))
		%     self.gate_altitude = gate_altitude
	end
	
	% private functions for checking limits, etc.
	methods (Hidden, Access=private)
		function check_sweep_in_range(obj, sweep)
		%Check that a sweep number is in range.
		if sweep < 1 || sweep > obj.nsweeps
			error("Sweep out of range: %i", sweep);
		end
		end
	end
	
	% public check functions
	methods
		function check_field_exists(self, field_name)
		% Check that a field exists in the fields dictionary.
		%
		% If the field does not exist raise a KeyError.
		%
		% Parameters
		% ----------
		% field_name : str
		%     Name of field to check.
		
		if ~isfield(self.fields, field_name)
			error("Field not available: %s", field_name);
		end
		end
	end
	
	% Get methods
	methods
		function startIdx = get_start(self, sweep)
		% Return the starting ray index for a given sweep.
		self.check_sweep_in_range(sweep);
		startIdx = self.sweep_start_ray_index.data(sweep) + 1;
		end
		
		function endIdx = get_end(self, sweep)
		% Return the ending ray for a given sweep.
		self.check_sweep_in_range(sweep)
		endIdx = self.sweep_end_ray_index.data(sweep) + 1;
		end
		
		function [startIdx, endIdx] = get_start_end(self, sweep)
		% Return the starting and ending ray for a given sweep.
		startIdx = self.get_start(sweep);
		endIdx = self.get_end(sweep);
		end
		
		function data = get_slice(self, sweep)
		% Return a slice for selecting rays for a given sweep.
		[startIdx, endIdx] = self.get_start_end(sweep);
		data = startIdx:endIdx;
		data = data';
		end
		
		function data = get_field(self, sweep, field_name)
		% Return the field data for a given sweep.
		%
		% When used with :py:func:`get_gate_x_y_z` this method can be used to
		% obtain the data needed for plotting a radar field with the correct
		% spatial context.
		%
		% Parameters
		% ----------
		% sweep : double
		%     Sweep number to retrieve data for, 0 based.
		% field_name : string
		%     Name of the field from which data should be retrieved.
		% copy : bool, optional
		%     True to return a copy of the data. False, the default, returns
		%     a view of the data (when possible), changing this data will
		%     change the data in the underlying Radar object.
		%
		% Returns
		% -------
		% data : array
		%     Array containing data for the requested sweep and field.
		% if nargin < 3, copy = false; end -- TODO -- Figure out the copy (handle) functionality
		self.check_field_exists(field_name);
		s = self.get_slice(sweep);
		data = self.fields.(field_name).data(s, :);
		
		% Set invalid entries to nan
		data(data>self.fields.(field_name).valid_max) = nan;
		data(data<self.fields.(field_name).valid_min) = nan;
		end
		
		function azimuths = get_azimuth(self, sweep)
		% Return an array of azimuth angles for a given sweep.
		%
		% Parameters
		% ----------
		% sweep : double
		%     Sweep number to retrieve data for, 0 based.
		% copy : bool, optional
		%     True to return a copy of the azimuths. False, the default, returns
		%     a view of the azimuths (when possible), changing this data will
		%     change the data in the underlying Radar object.
		%
		% Returns
		% -------
		% azimuths : array
		%     Array containing the azimuth angles for a given sweep.
		
		s = self.get_slice(sweep);
		azimuths = self.azimuth.data(s);
		end
		
		function elevation = get_elevation(self, sweep)
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
		
		s = self.get_slice(sweep);
		elevation = self.elevation.data(s);
		end
		
		function [x, y, z] = get_gate_x_y_z(self, sweep, edges, filter_transitions)
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
		
		azimuths = self.get_azimuth(sweep);
		elevations = self.get_elevation(sweep);
		
		if ~ismissing(filter_transitions) && ~ismissing(self.antenna_transition)
			sweep_slice = self.get_slice(sweep);
			valid = (self.antenna_transition.data(sweep_slice) == 0);
			azimuths = azimuths(valid);
			elevations = elevations(valid);
		end
		
		[x, y, z] = nexrad.transforms.antenna_vectors_to_cartesian(self.range.data, azimuths, elevations, edges);
		end
		
		function area = get_gate_area(self, sweep)
		% Return the area of each gate in a sweep. Units of area will be the
		% same as those of the range variable, squared.
		%
		% Assumptions:
		%     1. Azimuth data is in degrees.
		%
		% Parameters
		% ----------
		% sweep : int
		%     Sweep number to retrieve gate locations from, 0 based.
		%
		% Returns
		% -------
		% area : 2D array of size (ngates - 1, nrays - 1)
		%     Array containing the area (in m * m) of each gate in the sweep.
		
		s = self.get_slice(sweep);
		azimuths = self.azimuth.data(s);
		ranges = self.range.data;
		
		circular_area = pi * ranges^2;
		annular_area = diff(circular_area);
		
		az_diffs = diff(azimuths);
		az_diffs(az_diffs < 0.0) = az_diffs(az_diffs < 0.0) + 360;
		
		d_azimuths = az_diffs / 360.0;  % Fraction of a full circle
		
		[dca, daz] = meshgrid(annular_area, d_azimuths);
		
		area = abs(dca * daz);
		end
		
		function [lat, lon, alt] = get_gate_lat_lon_alt(self, sweep, reset_gate_coords, filter_transitions)
		% Return the longitude, latitude and altitude gate locations.
		% Longitude and latitude are in degrees and altitude in meters.
		%
		% With the default parameter this method returns the same data as
		% contained in the gate_latitude, gate_longitude and gate_altitude
		% attributes but this method performs the gate location calculations
		% only for the specified sweep and therefore is more efficient than
		% accessing this data through these attribute. If coordinates have
		% at all, please use the reset_gate_coords parameter.
		%
		% Parameters
		% ----------
		% sweep : int
		%     Sweep number to retrieve gate locations from, 0 based.
		% reset_gate_coords : bool, optional
		%     Optional to reset the gate latitude, gate longitude and gate
		%     altitude attributes before using them in this function. This
		%     is useful when the geographic coordinates have changed and gate
		%     latitude, gate longitude and gate altitude need to be reset.
		% filter_transitions : bool, optional
		%     True to remove rays where the antenna was in transition between
		%     sweeps. False will include these rays. No rays will be removed
		%     if the antenna_transition attribute is not available (set to None).
		%
		% Returns
		% -------
		% lat, lon, alt : 2D array
		%     Array containing the latitude, longitude and altitude,
		%     for all gates in the sweep.
		
		if nargin < 2, reset_gate_coords = false; end
		if nargin < 3, filter_transitions = false; end
		
		s = self.get_slice(sweep);
		
		if reset_gate_coords % TODO -- Sort how to implement LazyLoadDict
			% gate_latitude = LazyLoadDict(get_metadata("gate_latitude"));
			% gate_latitude.set_lazy("data", _gate_lon_lat_data_factory(self, 1));
			% self.gate_latitude = gate_latitude;
			%
			% gate_longitude = LazyLoadDict(get_metadata("gate_longitude"));
			% gate_longitude.set_lazy("data", _gate_lon_lat_data_factory(self, 0));
			% self.gate_longitude = gate_longitude;
			%
			% gate_altitude = LazyLoadDict(get_metadata("gate_altitude"));
			% gate_altitude.set_lazy("data", _gate_altitude_data_factory(self));
			% self.gate_altitude = gate_altitude;
		end
		
		lat = self.gate_latitude.data(s);
		lon = self.gate_longitude.data(s);
		alt = self.gate_altitude.data(s);
		
		if ~ismissing(filter_transitions) && ~ismissing(self.antenna_transition)
			valid = (self.antenna_transition.data(s) == 0);
			lat = lat(valid);
			lon = lon(valid);
			alt = alt(valid);
		end
		end
		
		function nyq_vel = get_nyquist_vel(self, sweep, check_uniform)
		% Return the Nyquist velocity in meters per second for a given sweep.
		%
		% Raises a LookupError if the Nyquist velocity is not available, an
		% Exception is raised if the velocities are not uniform in the sweep
		% unless check_uniform is set to False.
		%
		% Parameters
		% ----------
		% sweep : int
		%     Sweep number to retrieve data for, 0 based.
		% check_uniform : bool
		%     True to check to perform a check on the Nyquist velocities that
		%     they are uniform in the sweep, False will skip this check and
		%     return the velocity of the first ray in the sweep.
		%
		% Returns
		% -------
		% nyquist_velocity : float
		%     Array containing the Nyquist velocity in m/s for a given sweep.
		if nargin < 2, check_uniform = true; end
		
		s = self.get_slice(sweep);
		
		try
			nyq_vel = self.instrument_parameters.nyquist_velocity.data.(s);
		catch TypeError
			error("Nyquist velocity unavailable");
		end
		
		if check_uniform
			if any(nyq_vel ~= nyq_vel(0))
				error("Nyquist velocities are not uniform in sweep");
			end
		end
		
		nyq_vel = double(nyq_vel(0));
		end
		
		function out = pointCloud(self, fieldName, sweep)
		% Wrapper for external function which converts the sweep data
		% into a matlab pointCloud class.
		if nargin < 2, fieldName = 'reflectivity'; end
		if nargin < 3, sweep = 1; end
		
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
			[tmpX, tmpY, tmpZ] = self.get_gate_x_y_z(iSweep);
			
			% Get the field data
			tmpData = self.get_field(iSweep, fieldName);
			
			% Turn into column vector (due to nature of point cloud, proper order is not required)
			tmpX = reshape(tmpX, [], 1);
			tmpY = reshape(tmpY, [], 1);
			tmpZ = reshape(tmpZ, [], 1);
			tmpData = reshape(tmpData, [], 1);
			
			% Get the index if the invalid entries
			invalidIdx = isnan(tmpData);
			
			% Give warning if the sweep has no valid entries
			if sum(~invalidIdx) == 0
				
				warning('NEXRAD:CORE:InvalidSweepData', '"%s" has no valid entries for sweep %i', fieldName, iSweep);
				continue
			end
			
			% Remove invalid x, y, z, and data entries
			tmpX(invalidIdx) = [];
			tmpY(invalidIdx) = [];
			tmpZ(invalidIdx) = [];
			tmpData(invalidIdx) = [];
			
			% Append to new rows
			x = [x; tmpX];
			y = [y; tmpY];
			z = [z; tmpZ];
			data = [data; tmpData];
		end
		
		% Apply colour to pointCloud depending on the intensity of the
		% Normalise intensity values
		% dataNorm = data ./ max(data);
		
		% Turn on warning backtrace
		warning('on', 'backtrace');
		
		% Error if there is no sweep data
		if isempty(data)
			error('NEXRAD:CORE:InvalidSweepData', '"%s" has no valid data for any sweeps (%i-%i)', ...
				fieldName, min(sweep), max(sweep));
		end
		
		% Generate pointCloud and output
		out = pointCloud([x, y, z], 'Intensity', data);
		
		% Call external function to transform
		% out = nexrad.transforms.scan_to_point_cloud(self.azimuth, self.elevation, self.range, self.fields.(field));
		end
	end
	
	% Methods
	methods
		function info(self, level, out)
		% Print information on radar.
		%
		% Parameters
		% ----------
		% level : {'compact', 'standard', 'full', 'c', 's', 'f'}, optional
		%     Level of information on radar object to print, compact is
		%     minimal information, standard more and full everything.
		% out : file-like, optional
		%     Stream to direct output to, default is to print information
		%     to standard out (the screen).
		if nargin < 2, level = 'standard'; end
		if nargin < 3, out = 1; end
		
		switch level
			case "c"
				level = "compact";
			case "s"
				level = "standard";
			case "f"
				level = "full";
		end
		
		if ~ismember(level, {'standard', 'compact', 'full'})
			error('NEXRAD:CORE:InvalidParamter', "invalid level parameter");
		end
		
		self.dic_info("altitude", level, out);
		self.dic_info("altitude_agl", level, out);
		self.dic_info("antenna_transition", level, out);
		self.dic_info("azimuth", level, out);
		self.dic_info("elevation", level, out);
		
		fprintf(out, "fields:");
		% for field_name, field_dic in self.fields.items()
		%     self.dic_info(field_name, level, out, field_dic, 1);
		% end
		
		self.dic_info("fixed_angle", level, out);
		
		if ismissing(self.instrument_parameters)
			fprintf(out, "instrument_parameters: None");
		else
			fprintf(out, "instrument_parameters:");
			% for name, dic in self.instrument_parameters.items():
			%     self.dic_info(name, level, out, dic, 1);
			% end
		end
		
		self.dic_info("latitude", level, out);
		self.dic_info("longitude", level, out);
		
		fprintf(out, "nsweeps: %i", self.nsweeps);
		fprintf(out, "ngates: %i", self.ngates);
		fprintf(out, "nrays: %i", self.nrays);
		
		if ismissing(self.radar_calibration)
			fprintf(out, "radar_calibration: None");
		else
			fprintf(out, "radar_calibration:");
			% for name, dic in self.radar_calibration.items():
			%     self.dic_info(name, level, out, dic, 1);
			% end
		end
		
		self.dic_info("range", level, out);
		self.dic_info("scan_rate", level, out);
		fprintf(out, "scan_type: %s", self.scan_type);
		self.dic_info("sweep_end_ray_index", level, out);
		self.dic_info("sweep_mode", level, out);
		self.dic_info("sweep_number", level, out);
		self.dic_info("sweep_start_ray_index", level, out);
		self.dic_info("target_scan_rate", level, out);
		self.dic_info("time", level, out);
		
		% Airborne radar parameters
		if ~ismissing(self.rotation), self.dic_info("rotation", level, out); end
		if ~ismissing(self.tilt), self.dic_info("tilt", level, out); end
		if ~ismissing(self.roll), self.dic_info("roll", level, out); end
		if ~ismissing(self.drift), self.dic_info("drift", level, out); end
		if ~ismissing(self.heading), self.dic_info("heading", level, out); end
		if ~ismissing(self.pitch), self.dic_info("pitch", level, out); end
		if ~ismissing(self.georefs_applied), self.dic_info("georefs_applied", level, out); end
		
		% Always print out all metadata last
		self.dic_info("metadata", "full", out);
		end
		
		function viewer = view(self, fieldName, sweep)
		
		if nargin < 2, fieldName = 'reflectivity'; end
		if nargin < 3, sweep = 1; end
		
		pc = self.pointCloud(fieldName, sweep);
		
		viewer = pcviewer(pc, 'CameraProjection', 'orthographic', 'ViewPlane', 'XY', 'ColorSource', 'Intensity', ...
			'PointSize', 0.1);
		end
	end
	
	methods (Access=private)
		function dic_info(self, attr, level, out, dic, ident_level)
		% Print information on a dictionary attribute.
		if nargin < 5, dic = missing; end
		if nargin < 6, ident_level = 0; end
		
		if ismissing(dic)
			dic = self.(attr);
		end
		
		ilvl0 = repmat('\t', 1, ident_level);
		ilvl1 = repmat('\t', 1, ident_level + 1);
		
		if ismissing(dic)
			fprintf(out, '%s: %s', attr, missing);
			return
		end
		
		% Make a string summary of the data key if it exists.
		if ~isfield(dic, 'data')
			d_str = sprintf('Missing');
		elseif ~ismatrix(dic.data)
			d_str = sprintf('<not a matrix>');
		else
			data = dic.data;
			d_str = sprintf('<matrix of type: {%s} and shape: {%i, %i}>', ...
				class(data), size(data, 1), size(data, 2));
		end
		
		switch level
			% Compact, only data summary
			case 'compact'
				fprintf(out, '%s%s:%s', ilvl0, string(attr), d_str);
				
				% Standard, all keys, only summary for data
			case "standard"
				fprintf(out, '%s%s:', ilvl0, string(attr));
				fprintf(out, '%sdata: %s', ilvl1, d_str);
				% for key, val in dic.items():
				%     if key == "data":
				%         continue
				%         print(ilvl1 + key + ":", val, file=out)
				%     end
				% end
				
				% Full, all keys, full data
			case "full"
				fprintf(out, '%s:', string(attr));
				if isfield(dic, 'data')
					fprintf(out, '%sdata: ', ilvl1, dic.data);
					% for key, val in dic.items():
					%     if key == "data":
					%         continue
					%         print(ilvl1 + key + ":", val, file=out)
					%     end
					% end
				end
		end
		end
		
		function add_field(self, field_name, dic, replace_existing)
		% Add a field to the object.
		%
		% Parameters
		% ----------
		% field_name : str
		%     Name of the field to add to the dictionary of fields.
		% dic : dict
		%     Dictionary contain field data and metadata.
		% replace_existing : bool, optional
		%     True to replace the existing field with key field_name if it
		%     exists, loosing any existing data. False will raise a ValueError
		%     when the field already exists.
		if nargin < 3, replace_existing = false; end
		
		% Check that the field dictionary to add is valid
		if isfield(self.fields, 'field_name') && ~replace_existing
			error('NEXRAD:CORE:CheckData', 'A field with name: %s already exists', field_name);
		end
		if ~isfield(dic, 'data')
			error('NEXRAD:CORE:CheckData', 'dic must contain a "data" field');
		end
		if (size(dic.data) ~= [self.nrays, self.ngates])
			error('NEXRAD:CORE:CheckData',  "'data' has invalid shape, should be (%i, %i)", self.nrays, selft.ngates);
		end
		
		% Add the field
		self.fields.(field_name) = dic;
		end
		
		function add_filter(self, gatefilter, replace_existing, include_fields)
		% Updates the radar object with an applied gatefilter provided
		% by the user that masks values in fields within the radar object.
		%
		% Parameters
		% ----------
		% gatefilter : GateFilter
		%     GateFilter instance. This filter will exclude equal to
		%     the conditions provided in the gatefilter and mask values
		%     in fields specified or all fields if include_fields is None.
		% replace_existing : bool, optional
		%     If True, replaces the fields in the radar object with
		%     copies of those fields with the applied gatefilter.
		%     False will return new fields with the appended 'filtered_'
		%     prefix.
		% include_fields : list, optional
		%     List of fields to have filtered applied to. If none, all
		%     fields will have applied filter.
		if nargin < 2, replace_existing = false; end
		if nargin < 3, include_fields = missing; end
		
		% If include_fields is missing, sets list to all fields to include.
		if ismissing(include_fields)
			% include_fields = [*self.fields.keys()]
		end
		
		% try:
		%     % Replace current fields with masked versions with applied gatefilter.
		%     if replace_existing:
		%         for field in include_fields
		%             self.fields[field]["data"] = np.ma.masked_where(
		%             gatefilter.gate_excluded, self.fields[field]["data"]
		%             )
		%         end
		%             % Add new fields with prefix 'filtered_'
		%         else
		%             for field in include_fields:
		%                 field_dict = copy.deepcopy(self.fields[field])
		%                 field_dict["data"] = np.ma.masked_where(
		%                 gatefilter.gate_excluded, field_dict["data"]
		%                 )
		%                 self.add_field(
		%                 "filtered_" + field, field_dict, replace_existing=True
		%                 )
		%             end
		%         end
		%
		%                 % If fields don't match up throw an error.
		% catch ME
		%                 raise KeyError(
		%                 field + " not found in the original radar object, "
		%                 "please check that names in the include_fields list "
		%                 "match those in the radar object."
		%                 )
		%     end
		
		
			function add_field_like(self, existing_field_name, field_name, data, replace_existing)
			% Add a field to the object with metadata from a existing field.
			%
			% Note that the data parameter is not copied by this method.
			% If data refers to a 'data' array from an existing field dictionary, a
			% copy should be made within or prior to using this method. If this is
			% not done the 'data' key in both field dictionaries will point to the
			% same NumPy array and modification of one will change the second. To
			% copy NumPy arrays use the copy() method. See the Examples section
			% for how to create a copy of the 'reflectivity' field as a field named
			%     'reflectivity_copy'.
			%
			%     Parameters
			%     ----------
			%     existing_field_name : str
			%     Name of an existing field to take metadata from when adding
			%     the new field to the object.
			%     field_name : str
			%     Name of the field to add to the dictionary of fields.
			%     data : array
			%     Field data. A copy of this data is not made, see the note above.
			%     replace_existing : bool, optional
			%     True to replace the existing field with key field_name if it
			%     exists, loosing any existing data. False will raise a ValueError
			%     when the field already exists.
			%
			%     Examples
			%     --------
			%     >>> radar.add_field_like('reflectivity', 'reflectivity_copy',
			%     ...                      radar.fields['reflectivity']['data'].copy())
			if nargin < 4, replace_existing = false; end
			
			if ~isfield(self.fields, existing_field_name)
				error('NEXRAD:CORE:CheckData', "field %s does not exist in object", existing_field_name);
				dic = {}
				% for k, v in self.fields[existing_field_name].items():
				%     if k != "data":
				%         dic[k] = v
				%         dic["data"] = data
				%         return self.add_field(field_name, dic, replace_existing=replace_existing)
				%     end
				% end
			end
			end
		
		
		% function radar = extract_sweeps(self, sweeps)
		%     % Create a new radar contains only the data from select sweeps.
		%     %
		%     % Parameters
		%     % ----------
		%     % sweeps : array_like
		%     %     Sweeps (0-based) to include in new Radar object.
		%     %
		%     % Returns
		%     % -------
		%     % radar : Radar
		%     %     Radar object which contains a copy of data from the selected
		%     %     sweeps.
		%
		%     % Parse and verify parameters
		%     % sweeps = double(sweeps);
		%     if any(sweeps > self.nsweeps)
		%         error("invalid sweeps indices in sweeps parameter");
		%     end
		%     if any(sweeps < 0)
		%         error("only positive sweeps can be extracted");
		%     end
		%
		%     function d = mkdic(dic, select)
		%         % Make a dictionary, selecting out select from data key
		%         if ismissing(dic)
		%             d = missing;
		%         end
		%         d = dic.copy()
		%         if isfield(d, "data") && ~ismissing(select)
		%             d.data = d.data(select).copy()
		%         end
		%     end
		%
		%     % Create array of rays which select the sweeps selected and
		%     % The number of rays per sweep.
		%     ray_count = (
		%     self.sweep_end_ray_index["data"] - self.sweep_start_ray_index["data"] + 1
		%     )[sweeps]
		%     ssri = self.sweep_start_ray_index["data"][sweeps]
		%     rays = np.concatenate(
		%     %     [range(s, s + e) for s, e in zip(ssri, ray_count)]
		%     % ).astype("int32")
		%
		%     # radar location attribute dictionary selector
		%     if len(self.altitude["data"]) == 1:
		%         loc_select = None
		%     else:
		%         loc_select = sweeps
		%     end
		%
		%     # create new dictionaries
		%     time = mkdic(self.time, rays)
		%     _range = mkdic(self.range, None)
		%
		%     fields = {}
		%     for field_name, dic in self.fields.items():
		%         fields[field_name] = mkdic(dic, rays)
		%     end
		%     metadata = mkdic(self.metadata, None)
		%     scan_type = str(self.scan_type)
		%
		%     latitude = mkdic(self.latitude, loc_select)
		%     longitude = mkdic(self.longitude, loc_select)
		%     altitude = mkdic(self.altitude, loc_select)
		%     altitude_agl = mkdic(self.altitude_agl, loc_select)
		%
		%     sweep_number = mkdic(self.sweep_number, sweeps)
		%     sweep_mode = mkdic(self.sweep_mode, sweeps)
		%     fixed_angle = mkdic(self.fixed_angle, sweeps)
		%     sweep_start_ray_index = mkdic(self.sweep_start_ray_index, None)
		%     sweep_start_ray_index["data"] = np.cumsum(
		%     np.append([0], ray_count[:-1]), dtype="int32"
		%     )
		%     sweep_end_ray_index = mkdic(self.sweep_end_ray_index, None)
		%     sweep_end_ray_index["data"] = np.cumsum(ray_count, dtype="int32") - 1
		%     target_scan_rate = mkdic(self.target_scan_rate, sweeps)
		%
		%     azimuth = mkdic(self.azimuth, rays)
		%     elevation = mkdic(self.elevation, rays)
		%     scan_rate = mkdic(self.scan_rate, rays)
		%     antenna_transition = mkdic(self.antenna_transition, rays)
		%
		%     # instrument_parameters
		%     # Filter the instrument_parameter dictionary based size of leading
		%     # dimension, this might not always be correct.
		%     if self.instrument_parameters is None:
		%         instrument_parameters = None
		%     else:
		%         instrument_parameters = {}
		%         for key, dic in self.instrument_parameters.items():
		%             if dic["data"].ndim != 0:
		%                 dim0_size = dic["data"].shape[0]
		%             else:
		%                 dim0_size = -1
		%             end
		%             if dim0_size == self.nsweeps:
		%                 fdic = mkdic(dic, sweeps)
		%             elseif dim0_size == self.nrays:
		%                 fdic = mkdic(dic, rays)
		%             else:  # keep everything
		%                 fdic = mkdic(dic, None)
		%             end
		%             instrument_parameters[key] = fdic
		%         end
		%     end
		%
		%     # radar_calibration
		%     # copy all field in radar_calibration as is except for
		%     # r_calib_index which we filter based upon time.  This might
		%     # leave some indices in the "r_calib" dimension not referenced in
		%     # the r_calib_index array.
		%     if self.radar_calibration is None:
		%         radar_calibration = None
		%     else:
		%         radar_calibration = {}
		%         for key, dic in self.radar_calibration.items():
		%             if key == "r_calib_index":
		%                 radar_calibration[key] = mkdic(dic, rays)
		%             else:
		%                 radar_calibration[key] = mkdic(dic, None)
		%             end
		%         end
		%     end
		%
		%     return Radar(
		%     time,
		%     range,
		%     fields,
		%     metadata,
		%     scan_type,
		%     latitude,
		%     longitude,
		%     altitude,
		%     sweep_number,
		%     sweep_mode,
		%     fixed_angle,
		%     sweep_start_ray_index,
		%     sweep_end_ray_index,
		%     azimuth,
		%     elevation,
		%     altitude_agl=altitude_agl,
		%     target_scan_rate=target_scan_rate,
		%     scan_rate=scan_rate,
		%     antenna_transition=antenna_transition,
		%     instrument_parameters=instrument_parameters,
		%     radar_calibration=radar_calibration,
		%     )
		% end
		
		end
	end
	
end

