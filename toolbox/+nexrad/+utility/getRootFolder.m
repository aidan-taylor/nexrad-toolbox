function root = getRootFolder
	%GETROOTFOLDER Returns the top-level folder of the toolbox
	root = fileparts(fileparts(fileparts(mfilename('fullpath'))));