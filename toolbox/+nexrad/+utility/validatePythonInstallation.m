function validatePythonInstallation
	% VALIDATEPYTHONINSTALLATION Check Python Environment is set up correctly
	% with the required modules. TODO Hyperlinking of python error isn't
	% functioning correctly.
	%
	% ==========
	% References
	% ==========
	% .. [1] https://uk.mathworks.com/help/matlab/matlab_external/install-supported-python-implementation.html
	% .. [2] https://arm-doe.github.io/pyart/
	% .. [3] https://nexradaws.readthedocs.io/en/latest/
	
	% Set warning counter
	counter = 0;
	
	%% Check python environment is setup correctly
	pythonEnv = pyenv;
	
	if isempty(pythonEnv.Executable)
		% If not set up, raise error and point to documentation [1]
		error('NEXRAD:SETUP:PythonEnvironment', ['Python Environment is not set up (executable not found). ' ...
			'See MATLAB documentation for instructions. ', ...
			'<a href="https://www.mathworks.com/help/matlab/matlab_external/install-supported-python-implementation.html">[Documentation]</a>']);
	end
	
	try
		% Try basic command to check python is working
		pyrun("x = 2 + 2");
		
	catch ME
		error('NEXRAD:SETUP:PythonEnvironment', ['Python Environment is not set up correctly. ' ...
			'See MATLAB documentation for instructions. ', ...
			sprintf('<a href="matlab: disp(''%s'')">[Error]</a> ', ME.message), ...
			'<a href="https://www.mathworks.com/help/matlab/matlab_external/install-supported-python-implementation.html">[Documentation]</a>']);
	end
	
	%% Check python modules are installed correctly
	
	try
		% First pyart [2]
		py.importlib.import_module('pyart');
		py.pyart.io.read_nexrad_archive("examples/KMHX20180914_111837_V06");
		
	catch ME
		warning("NEXRAD:SETUP:PythonModule", ['Python ARM Radar Toolkit is not installed correctly. ' ...
			'See module documentation for instructions or quick install most recent version using pip. ', ...
			sprintf('<a href="matlab: disp(''%s'')">[Error]</a> ', ME.message), ...
			'<a href="https://arm-doe.github.io/pyart/">[Documentation]</a> ', ...
			'<a href="matlab: !python -m pip install arm_pyart">[Install]</a>']);
		counter = counter + 1;
	end
	
	try
		% Now nexradaws [3]
		py.importlib.import_module('nexradaws');
		py.nexradaws.NexradAwsInterface().get_avail_scans('2005', '08', '29', 'KLIX');
		
	catch
		warning("NEXRAD:SETUP:PythonModule", ['nexradaws is not installed correctly. ' ...
			'See module documentation for specific instructions or quick install most recent version using pip. ', ...
			sprintf('<a href="matlab: disp(''%s'')">[Error]</a> ', ME.message), ...
			'<a href="https://nexradaws.readthedocs.io/en/latest/">[Documentation]</a> ', ...
			'<a href="matlab: !python -m pip install nexradaws">[Install]</a>']);
		counter = counter + 1;
	end
	
	if counter == 0
		fprintf(1, "The Python Environment is set up correctly.\n");
	end