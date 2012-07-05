######################################################################
#   TTC nextbus data scrape v1.00
#
# Grabs every vehicle location from the nextbus api and adds it to a 
# flat file.  Also includes the basic logic to insert into some db,
# but you'll have to setup your database/tables to fit the data.
#
# runs every x seconds, for x minutes, defined by interval_time
# and total_run_time respectivly.
#
# Be sure to change the output file name, currently it will overwrite 
# the file every time the script is run.
#
# J.Fisher 2012
#######################################################################

require 'net/http'
require 'xmlsimple'
require 'rubygems'

#write to flat file
output = File.new("data/csv_test.csv", 'w')
interval_time = 17 #in seconds
total_run_time = 2 #in minutes
url = 'http://webservices.nextbus.com/service/publicXMLFeed?command=vehicleLocations&a=ttc&t=0'

######################################################################
#if using a database like mysql  
#require 'mysql'
#connect = Mysql.new('localhost', 'username', 'password', 'database')
######################################################################

#other setup
end_time = Time.now + total_run_time*60
row_id = 0
i = 1

puts "Start Time: #{Time.now} - End Time: #{end_time}"

#loop
while Time.now < end_time
  
  #get computer time
  comp_time = Time.new.strftime("%Y-%m-%d %H:%M:%S")
  
  xml = Net::HTTP.get_response(URI.parse(url)).body
  data = XmlSimple.xml_in(xml)
  
  #Gets Unix Time
  lasttime = data['lastTime'][0]['time']

  #iterate over every vehicle
  data['vehicle'].each do |vehicle|
    
    #increment row
    row_id += 1
    
    #get all the vechicle paramaters
    id = vehicle['id']
    rotue = vehicle['routeTag']
    dir = vehicle['dirTag']
    lat = vehicle['lat']
    lon = vehicle['lon']
    ssr = vehicle['secsSinceReport']
    pred = vehicle['predictable']
    heading = vehicle['heading']
    speed = vehicle['speedKmHr']
  
    flat_file = "#{row_id},#{id},#{rotue},#{dir},#{lat},#{lon},#{ssr},\"#{pred}\",#{heading},#{speed},\"#{comp_time}\",#{lasttime}"
    
    #puts query
    output.puts(flat_file)
  
    ######################################################################
    #query = "INSERT INTO nextbus_table VALUES (#{id}, #{rotue}, #{dir}, #{lat}, #{lon}, #{ssr}, #{pred},#{heading}, #{speed}, #{lasttime})"  
    #connect.query(query)
    ######################################################################
  
  end
  
  puts "Fetch number: #{i}, Total Rows inserted: #{row_id}, Rows inserted: #{data['vehicle'].count}, UNIX Time: #{lasttime}, Time: #{comp_time}"
  
  i+=1
  
  sleep interval_time

end

