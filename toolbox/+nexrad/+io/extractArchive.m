function fcnHandle = extractArchive(fieldName, sweep)
%EXTRACTARCHIVE
%

arguments
	fieldName (1,1) string = "reflectivity";
	sweep (1,:) double = 1;
end

% Output function handle (nested function handle will pass the values of fieldName and sweep)
fcnHandle = @extractData;

% Custom fileDatastore read function
	function dataOut = extractData(filename)
	
	% Read the given file and return radar object
	radar = nexrad.io.readArchive(filename);
	
	% Extract point cloud data
	ptCloud = radar.pointCloud(fieldName, sweep);
	
	% TODO -- make categories for neural network properly?
	label = categorical("Hurricane");
	
	% Assign output
	dataOut = {ptCloud, label};
	end
end