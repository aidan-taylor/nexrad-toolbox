function fcnHandle = extractArchive
%EXTRACTARCHIVE Extract radar data from datastore entry
% Returns nexrad.core.Radar object

% Output function handle
fcnHandle = @extractData;

% Custom fileDatastore read function
	function dataOut = extractData(filename)
	
	% Read the given file and return radar object
	radar = nexrad.io.readArchive(filename);
	
	% Assign output
	dataOut = radar;
	end
end