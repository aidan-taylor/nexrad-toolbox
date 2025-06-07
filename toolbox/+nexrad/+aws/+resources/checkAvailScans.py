import os
from glob import glob # Needed to get files in folder

missingScans = [] # Initialise outputs
presentScans = []

dataFolder = os.path.join(location, "*") # Form path to every file in root folder (no extension)
downloadedFiles = glob(dataFolder) # Get list of files in folder

for iScan in range(len(availScans)): # Loop over the number of scans

    if availScans[iScan].filename.endswith("MDM"): # (short circuit)
        continue # Skip files that end in MPM as this is unreadable by the pyart module (maintenance?)

    if awsStructure: # If AWS folder structure is maintained
        dataFolder = os.path.join(location, availScans[iScan].awspath, "*") # Form current loop datapath (in aws)
        downloadedFiles = glob(dataFolder) # Get list of files in folder (regenerates every loop in case the aws path changes)

    if any(availScans[iScan].filename in s for s in downloadedFiles):
        presentScans.append(availScans[iScan]) # If the scan file is in the local folder, add to present list

    else:
        missingScans.append(availScans[iScan]) # Otherwise, add to missing list