function filename = getExampleArchive
	%GETEXAMPLEARCHIVE Downloads the example NEXRAD Level II archive file used
	% in the gettingStarted guide and returns the absolute path.
	
	filename = fullfile(nexrad.utility.getRootFolder, "examples/KMHX20180914_111837_V05");
	
	if ~isfile(filename)
		websave(filename, "https://github.com/aidan-taylor/nexrad-toolbox/raw/refs/heads/main/examples/KMHX20180914_111837_V06");
	end