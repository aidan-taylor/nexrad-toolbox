 function radarObject = readArchive(filename, varargin)
	%READARCHIVE Read NEXRAD Level 2 Archive file(s) and return radar object(s).
	% Takes either binary file (internal conversion) or matfile with the object.
	% Returns nexrad.core.Radar object(s) with radar data as fields.
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
	% radarObject (1,M) nexrad.core.Radar
	%		Radar object containing all moments and sweeps/cuts in the volume.
	%
	% ========
	% Examples
	% ========
	%
	% radarObject = nexrad.io.readArchive("KABR20250207_093329_V06");
	%		Returns an object corresponding to the radar moments observed by
	%		KABR on 2nd July 2025. The archive file is found on the current
	%		MATLAB path.  
	%
	% radarObject = nexrad.io.readArchive("C:/Data");
	%		Returns a list of objects corresponding to the radar moments
	%		observed within each Level 2 archive file in the folder. 
	%
	% radarObject = nexrad.io.readArchive(["C:/Data", "C:/Data_2/KABR20250207_093329_V06"]); 
	%		Returns a list of objects corresponding to the radar moments
	%		observed within each Level 2 archive file in the Data folder and the
	%		specified archive folder within the Data_2 folder.
	%
	% radarObject = nexrad.io.readArchive([], "KABR", datetime([2025 01 01 00 00 00]), datetime([2025 01 01 01 00 00]));
	%		Downloads the available Level 2 archive files from AWS for KABR on
	%		1st January 2025 between 00:00 and 01:00 and returns a list of radar
	%		moment objects.
	%
	% ==========
	% References
	% ==========
	% .. [1] http://www.ncdc.noaa.gov/
	% .. [2] http://thredds.ucar.edu/thredds/catalog.html
	
	arguments (Input)
		filename (1,:) string = string.empty(1,0);
	end
	
	arguments (Input, Repeating)
		varargin
	end
	
	arguments (Output)
		radarObject (1,:) nexrad.core.Radar;
	end
	
	% Validate inputs
	filename = nexrad.io.resources.prepareForRead(filename, varargin{:});
	
	% Generate radar objects
	radarObject = nexrad.core.Radar(filename);