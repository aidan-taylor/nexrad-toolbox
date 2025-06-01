function ds = loadArchive(filename, varargin)
	%LOADARCHIVE Load NEXRAD Level 2 Archive file(s) and return datastore object.
	% Takes either binary file (internal conversion) or matfile with each field
	% representing the radar data. Returns datastore of each file with
	% nexrad.io.readArchive as the custom read function. The output of the
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
	% radarID (1,N) string
	%		Four letter ICAO name of the NEXRAD station from which the scans are
	%		desired. For a mapping of ICAO to station name, see
	%		https://www.roc.noaa.gov/branches/program-branch/site-id-database/site-id-network-sites.php.
	%
	% startTime (1,N) datetime
	%		Start of the time range between which scans are desired. If not
	%		specified, timezone is assumed UTC.
	%
	% endTime (1,N) datetime
	%		End of the time range between which scans are desired. If not
	%		specified, timezone is assumed UTC.
	%
	% ==================================
	% INPUTS (Cloud Search) (Name-Value)
	% ==================================
	%
	% saveLocation (1,1) string
	%		Local folder to save downloaded scans to. Also provides the location
	%		to check whether any scans are already downloaded.
	%		(tempdir/NEXRAD-Database, default).
	%
	% awsStructure (1,1) logical
	%		Maintain AWS bucket folder structure (true, default). Download all
	%		files into same folder (false).
	%
	% nThreads (1,1) double
	%		The number of processor threads used to concurrently download
	%		files. This is the number of physical cores of a system rather than
	%		virtual threads.
	%
	% =======
	% OUTPUTS
	% =======
	%
	% ds (1,1) matlab.io.datastore.FileDatastore
	%		Radar object containing all moments and sweeps/cuts in the volume.
	%
	% ========
	% Examples
	% ========
	%
	% ds = nexrad.io.loadArchive("C:/Data");
	%		Returns a datastore containning each Level 2 archive file in the
	%		folder. 
	%
	% ds = nexrad.io.loadArchive([], "KABR", datetime([2025 01 01 00 00 00]), datetime([2025 01 01 01 00 00]));
	%		Downloads the available Level 2 archive files from AWS for KABR on
	%		1st January 2025 between 00:00 and 01:00 and returns a datastore
	%		containing the filenames.
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
	filename = nexrad.core.prepareForRead(filename, varargin{:});
	
	% Initialise file data storage object with custom read function
	ds = fileDatastore(filename, 'ReadFcn', @nexrad.io.readArchive);
end