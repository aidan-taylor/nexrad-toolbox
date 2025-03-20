function matlabStruct = pyAwsNexradFile(pythonList)
%PYAWSNEXRADFILE Converts a Python List variable containing AwsNexradFile object(s) into a Matlab Structure
%

% Check if the list is empty; if so, return empty structure
if isempty(pythonList), matlabStruct = struct.empty(1,0); return, end

% Pre-convert python list to cell array
tmp = cell(pythonList);

% Get object field names (assumes all entries have same object fields)
loopFields = fieldnames(tmp{1});

% Initialise output struct
matlabStruct = cell2struct(cell(length(loopFields),1), loopFields);

% Loop over entries to convert string
for iEntry = 1:length(tmp)
	% Get current entry
	currentEntry = tmp{iEntry};
	
	% Loop over the fields
	for sField = loopFields'
		%Get current field
		currentField = sField{:};
		
		% If querying datetime info
		if strcmp(currentField, 'scan_time')
			% Need to convert within python to a str so can be read by matlab as a datetime
			[value, zone] = pyrun({'from datetime import datetime', 'import pytz', 'import nexradaws', 'time = input.scan_time', ...
				'output = f"{time:%d-%m-%Y %H:%M:%S}.{time.microsecond // 1000:03d}"', 'zone = time.tzinfo.zone'}, ["output", "zone"], input=currentEntry);
			% Convert to datetime
			value = datetime(string(value), 'InputFormat', 'dd-MM-yyyy HH:mm:ss.SSS', 'TimeZone', string(zone));
			value.Format = 'dd-MM-yyyy HH:mm:ssZ';
			
		elseif strcmp(currentField, 'last_modified')
			% This isn't really relevent, so skip
			continue
		else
			% Otherwise can just convert python str dirently to matlab string
			value = string(currentEntry.(currentField));
		end
		
		% Assign to output structure in correct position
		matlabStruct.(currentField)(1, iEntry) = value;
	end
end

% Remove last_modified field as it is not used
matlabStruct = rmfield(matlabStruct, 'last_modified');