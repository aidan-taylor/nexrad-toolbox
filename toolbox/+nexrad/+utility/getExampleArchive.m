function filename = getExampleArchive
	%GETEXAMPLEARCHIVE Downloads the example NEXRAD Level II archive file used
	% in the gettingStarted guide and returns the absolute path.
	
	exampleFolder = fullfile(nexrad.utility.getRootFolder, "examples");
	filename = fullfile(exampleFolder, "KMHX20180914_111837_V06");
	
	if ~isfile(filename)
		if ~isfolder(exampleFolder), mkdir(exampleFolder); end
		websave(filename, "https://github.com/aidan-taylor/nexrad-toolbox/raw/refs/heads/main/examples/KMHX20180914_111837_V06");
	end