function ds = loadArchive(filename, varargin)
	%LOADARCHIVE Load NEXRAD Level 2 Archive file(s) and return datastore object.
	% Takes either binary file (internal conversion) or matfile with each field
	% representing the radar data. Returns datastore of each file with
	% nexrad.io.extractArchive as the custom read function. The output of the
	% datastore is the nexrad.core.Radar object(s) with radar data as fields.
	%
	% ==============================================
	% INPUTS (Local Search) (Required, can be empty)
	% ==============================================
	%
	% filename (1,N) string
	%		Absolute or relative path to desired NEXRAD Level 2
	%		Archive File. Can include file(s) or folder(s). When a folder is given,
	%		a recursive check will grab every file below irrespective of content
	%		(duplicates will be filtered). When this is empty (must still be
	%		passed), allows either manual selection of file(s) or folder(s) or cloud
	%		based search.
	%
	% The files hosted by at the NOAA National Climate Data Center [1]_ as well as
	% on the UCAR THREDDS Data Server [2]_ have been tested. Other NEXRAD Level 2
	% Archive files may or may not work. Message type 1 file and message type 31
	% files are supported.
	%
	% ============================================
	% INPUTS (Cloud Search, replaces Local Search)
	% ============================================
	%
	% The following inputs operate the cloud search executed by nexrad.io.readCloud.
	% The inputs should be entered as normal to the call, ensuring that filename is
	% passed an empty string.
	%
	% =================================
	% INPUTS  (Cloud Search) (Required)
	% =================================
	%
	% radarID (1,1) string
	%		Four letter ICAO name of the NEXRAD station from which the scans are
	%		desired. For a mapping of ICAO to station name, see
	%		https://www.roc.noaa.gov/branches/program-branch/site-id-database/site-id-network-sites.php.
	%
	% startTime (1,1) datetime
	%		Start of the time range between which scans are desired.
	%
	% endTime (1,1) datetime
	%		End of the time range between which scans are desired.
	%
	% ================================
	% INPUTS (Cloud Search) (Optional)
	% ================================
	%
	% saveLocation (1,1) string
	%		Local folder to save downloaded scans to. Also provides the location to
	%		check whether any scans are already downloaded.
	%		(tempdir/NEXRAD-Database, default).
	%
	% ==================================
	% INPUTS (Cloud Search) (Name-Value)
	% ==================================
	%
	% awsStructure (1,1) logical
	%		Maintain AWS bucket folder structure (true, default). Download all
	%		files into same folder (false).
	%
	% =======
	% OUTPUTS
	% =======
	%
	% radar (1,N) nexrad.core.Radar
	%		Radar object containing all moments and sweeps/cuts in the volume.
	%
	% ==========
	% References
	% ==========
	% .. [1] http://www.ncdc.noaa.gov/
	% .. [2] http://thredds.ucar.edu/thredds/catalog.html
	
	arguments
		filename (1,:) string
	end
	
	arguments (Repeating)
		varargin
	end
	
	% Validate inputs (assume any varargin inputs relate to cloud settings)
	filename = nexrad.io.prepareForRead(filename, varargin{:});
	
	% Initialise file data storage object with custom read function
	ds = fileDatastore(filename, 'ReadFcn', extractArchive);
end


%%
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