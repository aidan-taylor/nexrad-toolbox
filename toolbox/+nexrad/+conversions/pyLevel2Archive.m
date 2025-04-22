function outputFiles = pyLevel2Archive(filename, varargin)
%PYLEVEL2ARCHIVE Converts a NEXRAD Level 2 binary file into a matfile containing the equivalent data.
%

arguments
	filename (1,:) string = [];
end

arguments (Repeating)
	varargin
end

% Validate inputs
filename = nexrad.io.prepareForRead(filename, varargin{:});

% Make tmp folder for storing variables
tempFolder = tempname;
if ~isfolder(tempFolder), mkdir(tempFolder); end

% Intialise output
outputFiles = strings(1, length(filename));

for iFile = 1:length(filename)
	% Get current dataset path (TODO -- could be from cloud? [20/03/2025])
	sFile = filename(iFile);
	
	try
		% Import NEXRAD Level II data
		nexradData = py.pyart.io.read_nexrad_archive(sFile);
		
	catch
		% If python errors, assume invalid archive, give warning and skip
		warning('NEXRAD:IO:InvalidID', '"%s" is not a valid NEXRAD Level II archive, so skipping.', sFile);
		continue
	end
	
	% Get mapping to object fields
	loopFields = fieldnames(nexradData);
	% Get name without extension
	[location, name] = fileparts(sFile);
	
	% Generate matfile to write to
	finalFilename = append(fullfile(char(location), char(name)), '.mat');
	radarFile = matfile(finalFilename, "Writable", true);
	
	for sDictionary = loopFields'
		% Get the current dictionary name and contents
		currentDictionaryName = sDictionary{:};
		currentDictionaryContents = nexradData.(currentDictionaryName);
		
		% Form .mat file name
		currentDictionaryFilename = append(fullfile(tempFolder, currentDictionaryName), '.mat');
		
		if isa(currentDictionaryContents, 'py.dict') || isa(currentDictionaryContents, 'py.pyart.lazydict.LazyLoadDict')
			% Convert the python dictionary to a .mat file and save
			py.scipy.io.savemat(currentDictionaryFilename, currentDictionaryContents, oned_as='column')
			
		elseif isa(currentDictionaryContents, 'py.int')
			% Convert to matlab class
			value = double(currentDictionaryContents);
			% Save value as .mat file
			save(currentDictionaryFilename, 'value')
			
		elseif isa(currentDictionaryContents, 'py.str')
			% Convert to matlab class
			value = string(currentDictionaryContents);
			% Save value as .mat file
			save(currentDictionaryFilename, 'value')
			
		elseif isa(currentDictionaryContents, 'py.NoneType')
			% Skip
			continue
			
		else
			% If we have any unexpected types, error for safety (warning?) (usually means issue with pyart module)
			error('NEXRAD:PYTHON:CONVERSIONS:InvalidClass', '%s is currently an unsupported python class', class(currentDictionaryContents));
		end
		
		% Access matfile as object
		tempVar = load(currentDictionaryFilename);
		
		% If the dataset was not a dictionary, check for value field to extract
		if isfield(tempVar, 'value')
			tempVar = tempVar.value;
		end
		
		% Assign to variable to construct object from
		radarData.(currentDictionaryName) = tempVar;
	end
	
	% Assign object to matfile
	radarFile.radarObject = extractRadar(radarData);
	
	% Append current dataset filename to output
	outputFiles(1, iFile) = finalFilename;
end

% Remove the tmp local folder
if isfolder(tempFolder), rmdir(tempFolder, 's'); end


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