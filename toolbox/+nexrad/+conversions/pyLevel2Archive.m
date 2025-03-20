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

% Get tmp local path
tempFolder = fullfile(tempdir, 'tmp_convert_nexrad');

% Intialise output
outputFiles = strings(1, length(filename));

for iFile = 1:length(filename)
	% Get current dataset path (TODO -- could be from cloud? [20/03/2025])
	sFile = filename(iFile);
	
	% Import NEXRAD Level II data
	nexradData = py.pyart.io.read_nexrad_archive(sFile);
	
	% Get mapping to object fields
	loopFields = fieldnames(nexradData);
	% Get name without extension
	[location, name] = fileparts(sFile);
	
	% Generate .mat file to write to
	finalFilename = append(fullfile(char(location), char(name)), '.mat');
	radarData = matfile(finalFilename, "Writable", true);
	
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
		
		% Access .mat file as object
		tempVar = load(currentDictionaryFilename);
		
		% If the dataset was not a dictionary, check for value field to extract
		if isfield(tempVar, 'value')
			tempVar = tempVar.value;
		end
		
		% Assign to final .mat file
		radarData.(currentDictionaryName) = tempVar;
	end
	
	% Append current dataset filename to output
	outputFiles(1, iFile) = finalFilename;
end

% Remove the tmp local folder
rmdir(tempFolder, 's');