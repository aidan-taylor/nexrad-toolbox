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
	% radarObject (1,N) nexrad.core.Radar
	%		Radar object containing all moments and sweeps/cuts in the volume.
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
	filename = nexrad.io.prepareForRead(filename, varargin{:});
	
	count = 1;
	for sFile = filename
		
		if ~endsWith(sFile, '.mat')
			% If not already ending in .mat, form path to possible matfile (assumes
			% same directory)
			[location, name] = fileparts(sFile);
			sMatFile = fullfile(location, [char(name), '.mat']);
			
			if ~isfile(sMatFile)
				% If .mat does not exist, do conversion to matlab friendly format
				% (assumes NEXRAD Level 2 binary)
				sMatFile = nexrad.conversions.pyLevel2Archive(sFile);
				
				% Check if the conversion has been a success (if not, will
				% return an empty but initialised string)
				if isempty(sMatFile{:}), continue, end
			end
			
			% Pass matfile through
			sFile = sMatFile; %#ok<FXSET>
		end
		
		% Open matfile and check if radarObject is present
		oMatFile = matfile(sFile);
		
		try
			% Load Radar object from matfile and index counter
			radarObject(1, count) = oMatFile.radarObject; %#ok<AGROW>
			count = count + 1;

		catch
			warning('NEXRAD:IO:InvalidID', "Required variable 'radarObject' does not exist in '%s'", sFile);
		end
	end