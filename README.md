# Toronto Transit Speeds

The processing sketch above takes a .csv file of nextbus location data, and translates that into a visual representation
of the movement of all of the vehicles.

The current csv format is as follows:

SQL_ID, Unique Vehicle Number, Route Number, Route Detail, Lat, Lng, Seconds from Last Position, Valid?, Heading, Speed, Time, Unix Time

An example:

431631,8084,49,"49_1_49",43.638718,-79.549286,17,"true",252,"","2012-01-06 07:00:09",1325851574343

The data folder contains a sample set of data.  For your own projects, check out the nextbus api.

I'll add the script I used to scrape the data in the future.