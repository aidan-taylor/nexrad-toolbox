function radar = readArchive(filename, varargin)
%READARCHIVE Read NEXRAD Level 2 Archive file(s) and return radar object(s).
% Takes either binary file (internal conversion) or matfile with each field
% representing the radar data. Returns nexrad.core.Radar object(s) with radar
% data as fields.
%
% ==============================================
% INPUTS (Local Search) (Required, can be empty)
% ==============================================
%
% filename (1,N) string
%		Absolute or relative path to desired NEXRAD Level 2
%		Archive File. Can include file(s) or folder(s). When a folder is given,
%		a recursive check will grab every file below irrespective of content
%		(duplicates will be filtered). When this is empty (must still be
%		passed), allows either manual selection of file(s) or folder(s) or cloud
%		based search. 
%
% The files hosted by at the NOAA National Climate Data Center [1]_ as well as
% on the UCAR THREDDS Data Server [2]_ have been tested. Other NEXRAD Level 2
% Archive files may or may not work. Message type 1 file and message type 31
% files are supported.
%
% ============================================
% INPUTS (Cloud Search, replaces Local Search)
% ============================================
%
% The following inputs operate the cloud search executed by nexrad.io.readCloud.
% The inputs should be entered as normal to the call, ensuring that filename is
% passed an empty string.
%
% =================================
% INPUTS  (Cloud Search) (Required)
% =================================
%
% radarID (1,1) string
%		Four letter ICAO name of the NEXRAD station from which the scans are
%		desired. For a mapping of ICAO to station name, see
%		https://www.roc.noaa.gov/branches/program-branch/site-id-database/site-id-network-sites.php. 
%
% startTime (1,1) datetime
%		Start of the time range between which scans are desired. 
%
% endTime (1,1) datetime
%		End of the time range between which scans are desired. 
%
% ================================
% INPUTS (Cloud Search) (Optional)
% ================================
%
% saveLocation (1,1) string
%		Local folder to save downloaded scans to. Also provides the location to
%		check whether any scans are already downloaded.
%		(tempdir/NEXRAD-Database, default).
%
% ==================================
% INPUTS (Cloud Search) (Name-Value) 
% ==================================
%
% awsStructure (1,1) logical
%		Maintain AWS bucket folder structure (true, default). Download all
%		files into same folder (false).
%
% =======
% OUTPUTS
% =======
%
% radar (1,N) nexrad.core.Radar
%		Radar object containing all moments and sweeps/cuts in the volume.
%
% ==========
% References
% ==========
% .. [1] http://www.ncdc.noaa.gov/
% .. [2] http://thredds.ucar.edu/thredds/catalog.html

arguments (Input)
	filename (1,:) string = string.empty(1,0);
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
		% If not already ending in .mat, form path to possible matfile (assumes
		% same directory) 
		[location, name] = fileparts(sFile);
		sMatFile = fullfile(location, [char(name), '.mat']);
		
		if ~isfile(sMatFile)
			% If .mat does not exist, do conversion to matlab friendly format
			% (assumes NEXRAD Level 2 binary) 
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
if isfield(radarData, 'altitude_agl')
	optionalInputs = [optionalInputs, 'altitude_agl', radarData.altitude_agl]; end
if isfield(radarData, 'target_scan_rate')
	optionalInputs = [optionalInputs, 'target_scan_rate', radarData.target_scan_rate]; end
if isfield(radarData, 'rays_are_indexed')
	optionalInputs = [optionalInputs, 'rays_are_indexed', radarData.rays_are_indexed]; end
if isfield(radarData, 'ray_angle_res')
	optionalInputs = [optionalInputs, 'ray_angle_res', radarData.ray_angle_res]; end
if isfield(radarData, 'scan_rate')
	optionalInputs = [optionalInputs, 'scan_rate', radarData.scan_rate]; end
if isfield(radarData, 'antenna_transition')
	optionalInputs = [optionalInputs, 'antenna_transition', radarData.antenna_transition]; end
if isfield(radarData, 'instrument_parameters')
	optionalInputs = [optionalInputs, 'instrument_parameters' radarData.instrument_parameters]; end
if isfield(radarData, 'radar_calibration')
	optionalInputs = [optionalInputs, 'radar_calibration', radarData.radar_calibration]; end
if isfield(radarData, 'rotation')
	optionalInputs = [optionalInputs, 'rotation', radarData.rotation]; end
if isfield(radarData, 'tilt')
	optionalInputs = [optionalInputs, 'tilt', radarData.tilt]; end
if isfield(radarData, 'roll')
	optionalInputs = [optionalInputs, 'roll', radarData.roll]; end
if isfield(radarData, 'drift')
	optionalInputs = [optionalInputs, 'drift', radarData.drift]; end
if isfield(radarData, 'heading')
	optionalInputs = [optionalInputs, 'heading', radarData.heading]; end
if isfield(radarData, 'pitch')
	optionalInputs = [optionalInputs, 'pitch', radarData.pitch]; end
if isfield(radarData, 'georefs_applied')
	optionalInputs = [optionalInputs, 'georefs_applied', radarData.georefs_applied]; end

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