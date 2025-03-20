function matlabStruct = pyAwsNexradFile(pythonList)
%PYAWSNEXRADFILE Converts a Python List variable containing AwsNexradFile object(s) into a Matlab Structure
%

% Check if the list is empty; if so, return empty structure
if isempty(pythonList), matlabStruct = struct.empty(1,0); return, end

% Pre-convert python list to cell array
tmp = cell(pythonList);

% Get object field names (assumes all entries have same object fields)
loopFields = fieldnames(tmp{1});

% Remove 'last_modified' field as it is not relevent
loopFields(strcmp(loopFields, 'last_modified')) = [];

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
			[timeStr, zoneStr] = pyrun({'time = input.scan_time', ...
				'timeStr = f"{time:%d-%m-%Y %H:%M:%S}.{time.microsecond // 1000:03d}"', ...
				'zoneStr = time.tzinfo.zone'}, ["timeStr", "zoneStr"], input=currentEntry);
			
			% Convert to datetime
			value = datetime(string(timeStr), 'InputFormat', 'dd-MM-yyyy HH:mm:ss.SSS', 'TimeZone', string(zoneStr));
			value.Format = 'dd-MM-yyyy HH:mm:ssZ';

		else
			% Otherwise can just convert python str directly to matlab string
			value = string(currentEntry.(currentField));
		end
		
		% Assign to output structure in correct position
		matlabStruct.(currentField)(1, iEntry) = value;
	end
end