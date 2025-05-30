import nexradaws
from datetime import datetime # Needed as MATLAB natively converts datetime to numpy.datetime64

# Initialise outputs
availScans = [] 

# If multiple datetimes are given, MATLAB converts to a numpy.ndarray of numpy.datetime64 array
# so need to extract from numpy.ndarray and convert to list of datetime.datetime
if type(startTime) is not datetime:
    startTime = startTime[0].astype(datetime)
    
if type(endTime) is not datetime:
    endTime = endTime[0].astype(datetime)
	
# TODO Handle edge case of 00:00 queries which sometimes fail due to MATLAB-Python conversion.

# Initialise NEXRAD AWS interface
conn = nexradaws.NexradAwsInterface(); 

# If there is only a single radarID
if len(radarID) == 1:
    # If there are not multiple time ranges
    if type(startTime) and type(endTime) is datetime:
        
        try:
            # Check if given parameters match valid AWS entries for the nexrad archive
            # and return filepaths to cloud depository 
            tmpAvailScans = conn.get_avail_scans_in_range(startTime, endTime, radarID[0]);
   
        except:
            # nexradaws associated "NoneType object is not iterable" error is mostly
            # meaningless so throw more useful error 
            print(f"NCDC database is out of record for radarID '{radarID[0]}' at time range specified by '{startTime}' and '{endTime}'")
            tmpAvailScans = [] # To ensure script exits correctly with empty output
        
        # Append to output list
        for iScan in range(len(tmpAvailScans)):
            availScans.append(tmpAvailScans[iScan])
            
    else:
        # Loop over the number of time ranges (both should have same length)
        for tmpStartTime, tmpEndTime in zip(startTime, endTime):
        
            try:
                # Check if given parameters match valid AWS entries for the nexrad archive
                # and return filepaths to cloud depository 
                tmpAvailScans = conn.get_avail_scans_in_range(tmpStartTime, tmpEndTime, radarID[0]);
       
            except:
                # nexradaws associated "NoneType object is not iterable" error is mostly
                # meaningless so throw more useful error 
                print(f"NCDC database is out of record for radarID '{radarID[0]}' at time range specified by '{tmpStartTime}' and '{tmpEndTime}'")
                continue
        
            # Append to output list
            for iScan in range(len(tmpAvailScans)):
                availScans.append(tmpAvailScans[iScan])
            
else:
    # Loop over the number of radarIDs
    for iRadar in range(len(radarID)): 

        # Extract the current loop variables (if times have multiple entries need to extract)
        tmpRadarID = radarID[iRadar] 
    
        if type(startTime) is not datetime:
            tmpStartTime = startTime[iRadar]
        else:
            tmpStartTime = startTime
        
        if type(endTime) is not datetime:
            tmpEndTime = endTime[iRadar]
        else:
            tmpEndTime = endTime
   
        try:
            # Check if given parameters match valid AWS entries for the nexrad archive
            # and return filepaths to cloud depository 
            tmpAvailScans = conn.get_avail_scans_in_range(tmpStartTime, tmpEndTime, tmpRadarID);
       
        except:
            # nexradaws associated "NoneType object is not iterable" error is mostly
            # meaningless so throw more useful error 
            print(f"NCDC database is out of record for radarID '{tmpRadarID}' at time range specified by '{tmpStartTime}' and '{tmpEndTime}'")
            continue
        
        # Append to output list
        for iScan in range(len(tmpAvailScans)):
            availScans.append(tmpAvailScans[iScan])