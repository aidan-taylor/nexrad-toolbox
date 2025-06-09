function filename = prepareForRead(filename, varargin)
	% PREPAREFORREAD Performs input checks for nexrad.io functions.
	% This is an internal validation function.
	
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
			filename = nexrad.utility.uiget('Title', 'Choose NEXRAD Level II Data Archive(s)', 'MultiSelect', true);
			
			% If uiget returns 0, assume ui was cancelled and error
			if isnumeric(filename), error("NEXRAD:IO:InvalidCode", "No local folder or file selected"); end
		end
	end
	
	% Now we might have a mix of file/folder names, check if a folder(s) has
	% been given and extract files 
	if any(isfolder(filename))
		filename = extractFolder(filename);
	end
	
	% Now we have only file names, check they are all valid
	filename = checkFile(filename);
	
	% Make compulsory final check to ensure there are no duplicates (absolute
	% path only) 
	filename = unique(filename);
	
	% If no files are left then error
	if isempty(filename)
		error("NEXRAD:IO:InvalidFile", "None of the original chosen files are valid");
	end
	
	
	%%
function filename = extractFolder(filename)
	%EXTRACTFOLDER Extract likely NEXRAD Level II archive files from a folder(s)
	
	% Get index of folders
	validFolder = isfolder(filename);
	
	% Make new list and remove entries from filename
	foldername = filename(validFolder);
	filename(validFolder) = [];
	
	% Loop over the folders given
	for sFolder = foldername
		% Get the complete list of files in the folder (this is a recursive
		% check of all sub-folders)
		fileList = dir(fullfile(sFolder, '**', '*'));
		isFile = ~[fileList.isdir];
		
		% Extract the names and locations of the files
		nameList = {fileList(isFile).name};
		pathList = {fileList(isFile).folder};
		
		% Form paths to new files and append to original list
		newFilename = fullfile(pathList, nameList);
		filename = [filename, newFilename]; %#ok<AGROW>
		
		% Perform initial check that files are probably a correct level 2 file
		% (files with no extension may be valid along with .gz compression).
		% This is silent as the folders might contain many spurious files.
		[~, ~, extension] = fileparts(filename);
		validArchive = any([cellfun(@isempty, extension); endsWith(extension, ".gz")], 1);
		
		% Pass only valid archives to output
		filename = filename(validArchive);
	end
	
	
	%%
function filename = checkFile(filename)
	% CHECKFILE Checks that given file(s) are valid and are likely NEXRAD Level
	% II archives.
	
	% Get valid files and give warning for invalid files
	validFile = isfile(filename);
	
	if any(~validFile)
		warning("backtrace", "off")
		for sFile = filename(~validFile)
			warning("NEXRAD:IO:InvalidFile", "'%s' is either not a valid file or not on the path so skipping...",sFile);
		end
		warning("backtrace", "on");
	end
	
	% Pass only valid files to output
	filename = filename(validFile);
	
	% Perform check that the file is probably a correct level 2 file (files with no
	% extension may be valid along with .gz compression and matfiles)
	[~, ~, extension] = fileparts(filename);
	validArchive = any([cellfun(@isempty, extension); endsWith(extension, ".gz")], 1);
	
	if any(~validArchive)
		warning("backtrace", "off")
		for sFile = filename(~validArchive)
			warning("NEXRAD:IO:InvalidFile", "'%s' is not a valid archive, so skipping...", sFile);
		end
		warning("backtrace", "on");
	end
	
	% Pass only valid archives to output
	filename = filename(validArchive);