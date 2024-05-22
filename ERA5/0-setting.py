#
# this script make sure ERA5 CDS API is installed and runs fine
# if you have not yet set up cdsapi, rememver to install cdsapi from conda-forge channel
#     conda install -c conda-forge cdsapi
# then you need to save the portal url and your key in ~/.cdsapirc
#

import cdsapi

client = cdsapi.Client()
