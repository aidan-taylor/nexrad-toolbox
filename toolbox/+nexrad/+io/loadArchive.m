function ds = loadArchive(filename, fieldname, sweep)
%LOADARCHIVE
%

arguments
	filename (1,:) string
	fieldname (1,1) string = "reflectivity";
	sweep (1,:) double = 1;
end

% Validate inputs
filename = nexrad.io.prepareForRead(filename);

% Initialise file data storage object with custom read function
ds = fileDatastore(filename, 'ReadFcn', nexrad.io.extractArchive(fieldname, sweep));