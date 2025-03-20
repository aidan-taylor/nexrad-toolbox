function radar = readArchive(filename, varargin)
%READARCHIVE
%

arguments (Input)
	filename (1,:) string = [];
end

arguments (Input, Repeating)
	varargin
end

arguments (Output)
	radar (1,:) nexrad.core.Radar;
end

% Validate inputs
filename = nexrad.io.prepareForRead(filename, varargin{:});

for iFile = 1:length(filename)
	% Extract current file (assume ending in .mat)
	sFile = filename(1, iFile);
	
	if ~endsWith(sFile, '.mat')
		% If not already ending in .mat, form path to possible matfile (assumes same directory)
		[location, name] = fileparts(sFile);
		sMatFile = fullfile(location, [char(name), '.mat']);
		
		if ~isfile(sMatFile)
			% If .mat does not exist, do conversion to matlab friendly format (assumes NEXRAD Level 2 binary)
			sMatFile = nexrad.conversions.pyLevel2Archive(sFile);
		end
		
		% Pass matfile through
		sFile = sMatFile;
	end
	
	% Load data from matfile
	radarData = load(sFile);
	% Initialise Radar class with data
	radar(1, iFile) = extractRadar(radarData); %#ok<AGROW>
end

%%
function radar = extractRadar(radarData)
%EXTRACTRADAR Extract variables and initialise nexrad.core.Radar class
%

% Initialise optional inputs cell
optionalInputs = cell.empty(1,0);

% For each optional field, append the value to optionalInputs if it is given
if isfield(radarData, 'altitude_agl'), optionalInputs = [optionalInputs, 'altitude_agl', radarData.altitude_agl]; end
if isfield(radarData, 'target_scan_rate'),  optionalInputs = [optionalInputs, 'target_scan_rate', radarData.target_scan_rate]; end
if isfield(radarData, 'rays_are_indexed'),  optionalInputs = [optionalInputs, 'rays_are_indexed', radarData.rays_are_indexed]; end
if isfield(radarData, 'ray_angle_res'),  optionalInputs = [optionalInputs, 'ray_angle_res', radarData.ray_angle_res]; end
if isfield(radarData, 'scan_rate'),  optionalInputs = [optionalInputs, 'scan_rate', radarData.scan_rate]; end
if isfield(radarData, 'antenna_transition'),  optionalInputs = [optionalInputs, 'antenna_transition', radarData.antenna_transition]; end
if isfield(radarData, 'instrument_parameters'),  optionalInputs = [optionalInputs, 'instrument_parameters' radarData.instrument_parameters]; end
if isfield(radarData, 'radar_calibration'),  optionalInputs = [optionalInputs, 'radar_calibration', radarData.radar_calibration]; end
if isfield(radarData, 'rotation'),  optionalInputs = [optionalInputs, 'rotation', radarData.rotation]; end
if isfield(radarData, 'tilt'),  optionalInputs = [optionalInputs, 'tilt', radarData.tilt]; end
if isfield(radarData, 'roll'),  optionalInputs = [optionalInputs, 'roll', radarData.roll]; end
if isfield(radarData, 'drift'),  optionalInputs = [optionalInputs, 'drift', radarData.drift]; end
if isfield(radarData, 'heading'),  optionalInputs = [optionalInputs, 'heading', radarData.heading]; end
if isfield(radarData, 'pitch'),  optionalInputs = [optionalInputs, 'pitch', radarData.pitch]; end
if isfield(radarData, 'georefs_applied'),  optionalInputs = [optionalInputs, 'georefs_applied', radarData.georefs_applied]; end

% Initialise radar object with all inputs
radar = nexrad.core.Radar(...
	radarData.time, ...
	radarData.range, ...
	radarData.fields, ...
	radarData.metadata, ...
	radarData.scan_type, ...
	radarData.latitude, ...
	radarData.longitude, ...
	radarData.altitude, ...
	radarData.sweep_number, ...
	radarData.sweep_mode, ...
	radarData.fixed_angle, ...
	radarData.sweep_start_ray_index, ...
	radarData.sweep_end_ray_index, ...
	radarData.azimuth, ...
	radarData.elevation, ...
	optionalInputs{:} ...
	);