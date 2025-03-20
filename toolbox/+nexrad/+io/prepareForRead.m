function filename = prepareForRead(filename, varargin)
% PREPAREFORREAD
%

arguments (Input)
	filename (1,:) string = [];
end

arguments (Input, Repeating)
	varargin
end

arguments (Output)
	filename (1,:) string
end

% If filename is empty, execute file gets
if isempty(filename)
	
	% If filename is empty and varargin is not, assume cloud search is desired
	if ~isempty(varargin)
		
		% Read AWS archive for radarID and time range
		filename = nexrad.io.readCloud(varargin{:});
		
	else
		% Promp user to choose a folder(s) and/or file(s) (must be in same folder)
		[file, location] = nexrad.utility.uiget(pwd, 'Title', 'Choose a NEXRAD Level II Data Archive', 'MultiSelect', true);
		
		% If location returns an "empty" string array ("" shows as 1x1 array) assume ui was cancelled and error
		if isempty(location{:}), error('NEXRAD:IO:InvalidID', 'No local folder or file selected'); end
		
		% Form full path to chosen files
		filename = string(fullfile(location, file));
	end
end

% Now we have guaranteed file/folder names, check if a folder has been given and extract files
if any(isfolder(filename))
	filename = checkFolder(filename);
end

% Now we have only file names, check they are all real
if any(~isfile(filename))
	filename = checkFile(filename);
end

% Make compulsory final check to ensure there are no duplicates
filename = checkDuplicate(filename);


%%
function filename = checkFolder(filename)
% CHECKFOLDER
%

% Get idx of folders
validFolder = isfolder(filename);

% Make new list and remove entries from filename
foldername = filename(validFolder);
filename(validFolder) = [];

% Loop over the folders given
for sFolder = foldername
	% Get the complete list of files in the folder -- TODO -- add ability to specify a subset?
	fileList = dir(fullfile(sFolder, '**', '*'));
	
	% Extract the names and locations of the files
	isFile = ~[fileList.isdir];
	nameList = {fileList(isFile).name};
	pathList = {fileList(isFile).folder};
	
	% Form paths to new files and append to original list
	newFilename = fullfile(pathList, nameList);
	filename = [filename, newFilename]; %#ok<AGROW>
end


%%
function filename = checkFile(filename)
% CHECKFILE
%

% Get valid files
validFile = isfile(filename);

% Give warning for invalid files
warning('NEXRAD:IO:InvalidID', '"%s" is either not a valid file or not on the path so skipping...\n\t', filename{~validFile});

% Pass only valid files to output
filename = filename(validFile);


%%
function filename = checkDuplicate(filename)
% CHECKDUPLICATE
%

% Check the files ending in .mat to prevent duplication if the binary is also present
isMat = endsWith(filename, '.mat');
nonMatFilename = filename(~isMat);
matFilename = filename(isMat);

% Ensures that this only happens if the binary is also present
% (prioritise the matfiles for conversion efficiency)
duplicateIdx = zeros(length(matFilename), length(nonMatFilename));

for iFile = 1:length(nonMatFilename)
	% Take fileparts of binary files to remove potential extensions
	[location, name] = fileparts(nonMatFilename(iFile));
	
	% Check if any of the matfile names contain their binary equivalent
	duplicateIdx(:, iFile) = startsWith(matFilename, fullfile(location, name));
end

% Form final array which stores the raw binary to pass through if the
% corresponding .mat file has not also been given
nonDuplicate = nonMatFilename(~any(duplicateIdx, 1));

% Overwrite final list (appends the matfiles given, and
% any binary files that are not duplicates of the corresponding matfile)
filename = [matFilename, nonDuplicate];

% Make unique check (removes any duplicate matfiles, also sorts in alphabetical)
filename = unique(filename);