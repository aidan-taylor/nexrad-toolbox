import nexradaws
from datetime import datetime # Needed as MATLAB natively converts datetime to numpy.datetime64

# Initialise outputs
availScans = [] 

# Extract datetime array from MATLAB converted list
startTime = startTime[0].astype(datetime)
endTime = endTime[0].astype(datetime)

# Initialise NEXRAD AWS interface
conn = nexradaws.NexradAwsInterface(); 

# Loop over the number of radarIDs
for iRadar in range(len(radarID)): 

    # Extract the current loop variables
    tmpRadarID = radarID[iRadar] 
    tmpStartTime = startTime[iRadar]
    tmpEndTime = endTime[iRadar]
   
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