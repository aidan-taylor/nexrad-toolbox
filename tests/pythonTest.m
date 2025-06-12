classdef pythonTest < matlab.unittest.TestCase
	% PYTHONTEST Performs installation and function checks on the python
	% environment and required modules.
	
	%%
	methods (Test, TestTags={'Python', 'Setup'})
		function pythonEnvironmentSetupTest(testCase)
			% Checks that python environment is setup correctly
			pyEnvironment = pyenv;
			
			testCase.verifyNotEmpty(pyEnvironment.Executable, ['Python Environment Setup Test passes ' ...
				'if the python executable is found by MATLAB']);
		end
		
		function pythonEnvironmentFunctionTest(testCase)
			% Checks that python environment is functioning correctly
			x = pyrun("x = 1 + 1", "x");
			
			testCase.verifyEqual(single(x) , single(2), ['Python Environment Setup Test passes ' ...
				'if the variable x is returned and equals 2']);
		end
	end
	
	%%
	methods (Test, TestTags = {'Python', 'Setup', 'pyart'})
		function pyartImportTest(testCase)
			% Checks that arm_pyart module is correctly installed (importable)
			py.importlib.import_module('pyart');
			
			% If an error occurs, the test will fail with an incomplete message.
			% This is by design.
			testCase.verifyTrue(true, ['Python ARM Radar Toolbox Installation Test passes ' ...
				'if pyart is importable into MATLAB']);
		end
		
		function pyartFunctionTest(testCase)
			% Checks that arm_pyart module is functioning correctly
			location = py.pyart.io.nexrad_common.get_nexrad_location('KABR');
			
			testCase.verifyNotEmpty(location, ['Python ARM Radar Toolbox Functionality Test passes ' ...
				'if the location (lat, lon, elv) of radar ID: KABR is returned']);
		end
	end
	
	%%
	methods (Test, TestTags = {'Python', 'Setup', 'nexradaws'})
		function nexradawsImportTest(testCase)
			% Checks that nexradaws module is correctly installed (importable)
			py.importlib.import_module('nexradaws');
			
			% If an error occurs, the test will fail with an incomplete message.
			% This is by design.
			testCase.verifyTrue(true, ['NEXRADAWS Module Installation Test passes ' ...
				'if nexradaws is importable into MATLAB']);
		end
		
		function nexradawsFunctionTest(testCase)
			% Checks that nexradaws module is functioning correctly
			years = py.nexradaws.NexradAwsInterface().get_avail_years();
			
			testCase.verifyNotEmpty(years, ['NEXRADAWS Module Functionality Test passes ' ...
				'if a non-empty list of the years available in the AWS bucket is returned']);
		end
	end
	
end
