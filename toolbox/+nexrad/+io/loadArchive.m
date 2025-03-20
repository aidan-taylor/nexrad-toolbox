function ds = loadArchive(filename, varargin, nameValueArgs)
%LOADARCHIVE
%

arguments
	filename (1,:) string
end

arguments (Repeating)
	varargin
end

arguments
	nameValueArgs.fieldname (1,1) string = 'reflectivity';
	nameValueArgs.sweep (1,:) double = 1;
end

% Validate inputs (assume any varargin inputs relate to cloud settings)
filename = nexrad.io.prepareForRead(filename, varargin{:});

% Initialise file data storage object with custom read function
ds = fileDatastore(filename, 'ReadFcn', nexrad.io.extractArchive(nameValueArgs.fieldname, nameValueArgs.sweep));