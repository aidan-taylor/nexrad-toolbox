function opts = toolboxOptions

    toolbox_folder = "toolbox";

    % The following identifier was automatically generated
    % and should remain unchanged for the life of the toolbox.
    identifier = "64eefd5b-2eff-4645-ae06-4aee417054ba";

    opts = matlab.addons.toolbox.ToolboxOptions(toolbox_folder,identifier);

    opts.ToolboxName = "NEXRAD Toolbox";

    % Version number of the toolbox. Use semantic version numbers of the
    % form MAJOR.MINOR.PATCH, such as "2.0.1". Increment the MAJOR version
    % when you make incompatible API changes. Increment the MINOR version
    % when you add functionality in a backward compatible manner. Increment
    % the PATCH version when you make backward compatible bug fixes.
    
    opts.ToolboxVersion = "1.0.0";

    % Folders to add to MATLAB path during toolbox installation, specified
    % as a string vector. When specifying ToolboxMatlabPath, include the
    % relative or absolute paths to the folders.

    opts.ToolboxMatlabPath = "toolbox";

    % Path to the toolbox Getting Started Guide, specified as a string. The
    % Getting Started Guide is a MATLAB code file (.m, .mlx) containing a
    % quick start guide for your toolbox. The path can be a relative path
    % or an absolute path.

    opts.ToolboxGettingStartedGuide = fullfile("toolbox",...
        "gettingStarted.mlx");

    % Path to the toolbox output file, specified as a string. The path can
    % be a relative path or an absolute path. If the file does not have a
    % .mltbx extension, MATLAB appends the extension automatically when it
    % creates the file.

    opts.OutputFile = fullfile("release","nexrad-toolbox");
    
    % Latest MATLAB release that the toolbox is compatible with, specified
    % as a string using the format RXXXXx, for example, "R2023a". If there
    % is no maximum restriction, specify MaximumMatlabRelease as empty
    % ("").

    opts.MaximumMatlabRelease = "";

    % Earliest MATLAB release that the toolbox is compatible with,
    % specified as a string using the format RXXXXx, for example, "R2020a".
    % If there is no minimum restriction, specify MinimumMatlabRelease as
    % empty ("").

    opts.MinimumMatlabRelease = "R2021b";

    % Supported platforms

    platforms.Win64        = true;
    platforms.Glnxa64      = true;
    platforms.Maci64       = true;
    platforms.MatlabOnline = false;
    opts.SupportedPlatforms = platforms; 

    opts.Description = sprintf("The toolbox frontend is organised within the nexrad namespace " + ...
		"in the style of a Python module. The two key top-level functions are:\n\n" + ...
		"    nexrad.io.readArchive\n    nexrad.io.loadArchive\n\n" + ...
		"Both functions take identical inputs. The first is designed for small-scale queries and " + ...
		"returns an array of nexrad.core.Radar objects. The second is designed for large-scale " + ...
		"queries and returns a matlab.io.datastore.FileDatastore object (any remote files will " + ...
		"be downloaded before the datastore is created). Currently, the only built-in data " + ...
		"visualisation is as a point cloud object.\n");

    opts.Summary = "A set of MATLAB tools which interact with NEXRAD Level 2 data.";

    opts.AuthorName = "Aidan Taylor";

    % opts.AuthorEmail =

    % opts.AuthorCompany =

    % Path to the toolbox image file. Can be specified as a relative or
    % absolute path.
    %
    opts.ToolboxImageFile = fullfile("images", "hurricane-katrina-ptcloud.jpg");

    % Files to be packaged in the toolbox, string vector. By default,
    % ToolboxFiles contains the list of all files in toolboxFolder.
    %
    % When specifying ToolboxFiles, include the relative or absolute paths
    % to the files. If you specify a folder, MATLAB adds all of the files
    % in the folder to ToolboxFiles.
    %
    % opts.ToolboxFiles = 

    % Toolbox apps gallery files, specified as a string vector. Apps
    % gallery files are MATLAB executable files (.m, .mex, .mlx, .mlapp,
    % .p) to add to apps gallery during toolbox installation. When
    % specifying AppGalleryFiles, include the relative or absolute paths to
    % the files.
    %
    % Files included in AppGalleryFiles must also be included in
    % ToolboxFiles.
    %
    % opts.AppGalleryFiles = 

    % Files to add to the Java class path during toolbox installation,
    % specified as a string vector. When specifying ToolboxJavaPath,
    % include the relative or absolute paths to the files.

    % opts.ToolboxJavaPath = 

    % Required add-ons to be downloaded and installed during toolbox
    % installation, specified as a struct vector. See the doc for
    % matlab.addons.toolbox.ToolboxOptions for more information.

    % opts.RequiredAddons = 

    % Additional required software packages to be downloaded and installed
    % during toolbox installation, specified as a struct vector. See the
    % doc for matlab.addons.toolbox.ToolboxOptions for more information.

    % opts.RequiredAdditionalSoftware = 
end
