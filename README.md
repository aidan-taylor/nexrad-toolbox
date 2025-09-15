[![View NEXRAD Toolbox on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://uk.mathworks.com/matlabcentral/fileexchange/181267-nexrad-toolbox)

# NEXRAD Toolbox

This toolbox provides a set of tools which interact with NEXRAD Level II archive files. These are wrappers for a Python backend which reads and interprets the binary data through the [Python ARM Radar Toolkit - Py-ART](https://arm-doe.github.io/pyart/). 

AWS interaction with the S3 Level II archive bucket is also provided through the Python module [nexradaws](https://nexradaws.readthedocs.io/en/latest/index.html). 

## Installation

Download the `nexrad-toolbox.mltbx` file from the [GitHub repository releases area](https://github.com/aidan-taylor/nexrad-toolbox/releases). Double-click on the downloaded file to automatically run the MATLAB add-on installer. This will copy the files to your MATLAB add-ons area and add the `nexrad` namespace to your MATLAB search path.

Later, you can use the [MATLAB Add-On Manager](https://www.mathworks.com/help/matlab/matlab_env/get-add-ons.html) to uninstall.

## Getting Started

See the [Getting Started](./toolbox/gettingStarted.mlx) script for more information and instructions on setting up the Python environment.

Copyright &copy; 2025 Aidan Taylor
