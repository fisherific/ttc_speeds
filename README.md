# Toronto Transit Speeds

The processing sketch above takes a .csv file of NextBus location data and translates that into a visual 
representation of the vehicle movement.  The project is based around the Toronto Transit Commission, but 
can be relatively easily modified to suit any city that uses the NextBus service.  You would have to edit 
the lat/lng boundaries, as well as the map projection.  Currently based on the Great Lakes Albers (NAD83) projection. 

## CSV file format

The current csv format is as follows:

RowID(unique), Unique Vehicle ID, Route Number, Route Detail, Lat, Lng, Seconds from Last Position Update, Predictable?, Heading, Speed, Time, Unix Time

Check out the data folder for a sample set.

## Get your own data set

I've also included a simple ruby script that pulls data from the Nextbus API and adds it to a new csv file.

## Processing

You will need a version of Processing for the desktop to run the .pde files.  Can be downloaded here: http://processing.org/download/