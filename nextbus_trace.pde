/********************************************************
 
 Nextbus realtime vehicle location data animation script
 
 Version 1.00
 J.Fisher - December 20th, 2011
 
 *********************************************************/

/***************************************
 *Declare variables
 ***************************************/

PFont font;

import processing.video.*;

MovieMaker mm;  // Declare MovieMaker object
int frames, vid_frames;

DateFormat df;
Date DTmindate;

int delta_t;
int routenum;
int combonum;
int R;
double totaldist;

String vid_on;
String starttime;
String data_name;
String output_name;
String movie_name;
float jump_factor;
int unique_size;

car_location[] car_dat;
car_location[] car_last;
car_location[] car_last_2;

car_row[] car_lookup;
car_row[] car_lookup_2;

ArrayList car_route_uniques;
ArrayList car_route_all  ;

int placeCount;
int[] car_codes;
int[] unique_cars;

int[] route_codes;
int[] unique_routes;
float minX, maxX;
float minY, maxY;
PImage mapImage;
int t, t_min, t_max;

float mapX1, mapY1;
float mapX2, mapY2;
float testlat, testlon;

float boundsX1, boundsX2;
float boundsY1, boundsY2;

public void setup() {

  /***************************************
   *All the setup you need to customize your 
   *output
   ***************************************/

  //Name of the csv data file you want to plot
  //Has to follow the format xxx
  //and be in the sketch "data" folder
  data_name = "jan6_7_8.csv";  //jan6_6_12  jan6_7_8
  
  output_name = "jan6_7_8_120s_3.png";
  movie_name = "jan6_7_8_120s_3.mov";
 
  //Lat/Lon map bounds.  Default is an area arount Toronto, On.
  //Openstreetmap.org has a useful tool for determining the bounds
  
  //Lon
  minX = -79.85; //.81
  maxX = -78.96; //.00
  //Lat
  minY = 43.55; //.59
  maxY = 43.96; //.92
  
  Proj Albersboundsmin = new Proj(minY,minX);  
  Proj Albersboundsmax = new Proj(maxY,maxX);  
  
  minX = Albersboundsmin.x;
  maxX = Albersboundsmax.x;
  minY = Albersboundsmin.y;
  maxY = Albersboundsmax.y;
  
  float delta_x = maxX - minX;
  float delta_y = maxY - minY;
  
  int scale = 40; //15
  
  int size_x = (int) delta_x / scale;
  int size_y = (int) delta_y / scale;
  
  
  size(size_x,size_y,P2D);
  
  println(size_x + "x" + size_y);
  
   //Creating the margins for the output
  mapX1 = 30;
  mapX2 = width - mapX1;
  mapY1 = 30;
  mapY2 = height - mapY1;
  
  vid_on = "y";
  
  if(vid_on == "y"){
    
    mm = new MovieMaker(this, width, height, movie_name, 120, MovieMaker.ANIMATION, MovieMaker.LOSSLESS);//, 30, MovieMaker.H264,MovieMaker.HIGH);

   frames = 0;
  vid_frames = 10;    
  
  }

  
  //Background Colour 
  background(#242424);
  //background(#ffffff);

  //sampling time (s)
  //Time in seconds between each time interval (t).  delta_t = 200 means 200 seconds between checking car locations.
  //Higher numbers will cause the script to run faster, but have less detail

  delta_t = 120;

  //Don't need to touch this stuff (at the moment)
  frameRate(500);   
  routenum = 0;
  totaldist = 0;
  starttime = hour() + ":" + minute() + ":" + second();

  //Font?
  font = createFont("HelveticaNeue-Light", 46, true);
  textFont(font);

  //Trying to eliminate large jumps in car location, won't plot any movement with a distance greater than jump_factor (in kms)
  jump_factor = 3;//14

  //Gets the data from a preformatted csv file.  See readme for file description
  readData();

  //Get min/max time bounds from the data provided in readdata()
  time_set();

  //Get all the unique cars in the data
  distinct_cars();

  //Get all the unique routes in the data
  distinct_routes();

  //Get all unique route/car combinations - used for plotting by route
  car_route_setup();
  
  unique_size = car_route_uniques.size();
  
}



void draw() {

  //Loop through each unique route.  Plots in numerical order of route ID
  
  if (combonum < unique_size){

    //get new object for the current iteration
    car_route current_car = (car_route) car_route_uniques.get(combonum);

    //printing some stuff for progress checking
    //println(combonum + " - " + current_car.route + " - " + current_car.car_id + " - " + t);

      if (t <= t_max) {

        //Getting last two location based on time t and t - delta_t
        car_last[combonum] = get_latest(combonum, current_car.car_id, t);
        car_last_2[combonum] = get_latest_2(combonum, current_car.car_id, t - delta_t);
        
        float x1 = car_last[combonum].x; 
        float y1 = car_last[combonum].y; 
        float x2 = car_last_2[combonum].x; 
        float y2 = car_last_2[combonum].y;

        //Mapping from lat/lon to sketch pixels (functions TX, TY)
        int xx1 = (int) TX(x1); 
        int yy1 = (int) TY(y1); 
        int xx2 = (int) TX(x2); 
        int yy2 = (int) TY(y2); 
        
        //simple Equirectangular distance calc. (ok cause the distances are so short) in kms
        float distance = sqrt(sq(x1 - x2) + sq(y1 - y2)) / 1000;

        //Bunch of criteria to actuall plot a line, I'm picky

        if (
        (xx1 != xx2 || yy1 != yy2)                                  //There has been some movement since the last delta_t
        && t - car_last[combonum].time < 300                        //There has been less than 5 mins between last reported GPS time and the time we're plotting
        && (car_last[combonum].car_id == current_car.car_id)        //Still the same car
        && distance < jump_factor                                   //If the movement is bigger then the jum_factor, skip

        ) {
          
          totaldist = totaldist + distance;
          
          int update_time = car_last[combonum].time - car_last_2[combonum].time;
          
          //Calculate the avg speed between the last 2 points
          //double time = (double) delta_t / 3600;
          double speed = distance/ ((double) update_time / 3600);
                 
          
          //Change line colour based on speed  
          
          if (speed <= 7) {
            stroke(#CF1313, 80);
            
          }else if (speed <= 14) {
            stroke(#CF6713, 80);
            
          }else if (speed <= 21) {  
            stroke(#ECE632,80);
            
          }else if (speed <= 28) {
            stroke(#13CF83, 80);
            
          }else if (speed <= 35) {
            stroke(#13BCCF, 80);
            
          }else {
            stroke(#136DCF, 80);      
          }
          
          /*
          if (speed <= 10) {
            stroke(#CF1313, 100);
          }else if (speed <= 25) {
            stroke(#CFC813, 100);
          }else {
            stroke(#136DCF, 100);
          }
          
          */
          
          //plot the line on the sketch   
          line(xx1, yy1, xx2, yy2);  
          
         // String route_number = new java.text.SimpleDateFormat("hh:mm a").format(new java.util.Date (t*1000L));
          
         
          
          if(vid_on == "y")
          {
            
           fill(#242424);
          //fill(#ffffff);
          stroke(#242424);
          rect(1250, 875, 350, 100);
          fill(#E7E7E7);
          text("Route: " + current_car.route, 1250, 925);
            
          
           if (frames == vid_frames)
          {

            mm.addFrame();
            frames = 1;
          }
          else {

            frames++;
          }
          
          }

          //let the user know you're drawing something
         println("Drawing: " + combonum + "/" + unique_size + " - Total Distance (kms): " + totaldist + " - Spot Distance (kms): " + distance + " - Speed (km/h): " + speed + " - Route: " + current_car.route + " - CarID: " + current_car.car_id + " - Time: " + t + " Update Time: " + update_time);

        }

        t = t + delta_t;
      }
      else if (t >= t_max) {

        combonum++;
        t = t_min;
      }

  }
  else {

    //Ending stuff

    println("t_min: " + t_min);
    println("t_max: " + t_max);
    println("placecount: " + placeCount);
    println("unique_cars: " + unique_cars.length); 
    println("car_dat: " + car_dat.length); 
    println("car_last: " + car_route_uniques.size()); 
    println("starttime: " + starttime + "endtime: " + hour() + ":" + minute() + ":" + second());

    noLoop();
    

          
          if(vid_on == "y"){
            
           fill(#242424);
          //fill(#ffffff);
          stroke(#242424);
          rect(1250, 875, 350, 100);
            
                      
          mm.addFrame();
          mm.addFrame();
               mm.finish();
          
          }
    save(output_name);
    

  }
}



//Load in all the lines of raw csv
void readData() {

  String[] all_lines = loadStrings(data_name);//fullday
  car_dat = new car_location[all_lines.length];

  for (int i = 1; i < all_lines.length; i++) {

    car_dat[placeCount] = parse_data(all_lines[i], i); 
    placeCount++;
  }
}

//Parse each comma seperated value into a new car object
car_location parse_data(String line, int id) {

  //Split every line on a comma (using .csv files
  String pieces[] = split(line, ",");

  //id is the unique row number, a key
  int code = id;

  //initialize car_id
  int car_id = int(pieces[1]);
  int time;

  //time_long is 13 digit unix time, need to shorten
  String time_long = pieces[11];
  if (time_long.length() >= 6) {

    time = int(time_long.substring(0, 10));
  } 
  else {

    time = int(time_long);
  }

  //get lat and lon
  int route = int(pieces[2]);
  float y = float(pieces[4]);
  float x = float(pieces[5]);
  int timesincereport = int(pieces[6]);
  String datetime = pieces[10];
  
  Proj albers = new Proj(y,x);
  //println(albers.x + " - " + albers.y);

  time = time - timesincereport;

  //puts all info into new object
  return new car_location(code, route, car_id, datetime, time, albers.x, albers.y);
} 

//Get the t_min and t_max based on the data
void time_set() {

  t_min = MAX_INT;
  t_max = 0;

  for (int i = 0; i < placeCount; i++) {

    if (car_dat[i].time > t_max && car_dat[i].time > 0) {

      t_max = car_dat[i].time;
    }
    if (car_dat[i].time < t_min && car_dat[i].time > 0) {

      t_min = car_dat[i].time;
    }
  }

  //println(t_min + "-" + t_max + "-" + placeCount);

  t = t_min;
}

//Get all the unique car IDs
void distinct_cars() {

  car_codes = new int[placeCount];
  unique_cars = new int[1];

  for (int i = 0; i < placeCount; i++) {

    car_codes[i] = car_dat[i].car_id;
  } 

  car_codes = sort(car_codes);

  unique_cars[0] = car_codes[0];

  int i = 0;
  int j = 0;

  while (i < placeCount) {

    if (car_codes[i] == unique_cars[j]) {

      i++;
      continue;
    } 
    else if (car_codes[i] != unique_cars[j]) {

      unique_cars = append(unique_cars, car_codes[i]);
      i++;
      j++;
      continue;
    }
  }

  car_lookup = new car_row[unique_cars.length];
  car_lookup_2 = new car_row[unique_cars.length];


  //Prepopulate car_last with 0s
  for (int k = 0; k < unique_cars.length; k++) {

    car_lookup[k] = prepop_row(k, unique_cars[k]);
    car_lookup_2[k] = prepop_row(k, unique_cars[k]);
  }
}

//Get all the distinct route IDs
void distinct_routes() {

  route_codes = new int[placeCount];
  unique_routes = new int[1];

  for (int i = 0; i < placeCount; i++) {

    route_codes[i] = car_dat[i].route;
  } 

  route_codes = sort(route_codes);

  //set first unique value to compare
  unique_routes[0] = route_codes[0];

  int i = 0;
  int j = 0;

  while (i < placeCount) {

    if (route_codes[i] == unique_routes[j]) {

      i++;
      continue;
    } 
    else if (route_codes[i] != unique_routes[j]) {

      unique_routes = append(unique_routes, route_codes[i]);
      i++;
      j++;
      continue;
    }
  }
}


//Get unique car_id and route combos
void car_route_setup() {

  car_last = new car_location[5000];
  car_last_2 = new car_location[5000];  

  //Prepopulate car_last with 0s
  for (int k = 0; k < 5000  ; k++) {

    car_last[k] = prepop(1, unique_cars[0], "0", t_min); 
    car_last_2[k] = prepop(1, unique_cars[0], "0", t_min);
  }


  int combo = 0;
  int r = 0;
  int z = 0;

  car_route_all = new ArrayList();

  for (int i = 0; i < car_dat.length - 1; i++) {

    car_route_all.add( new car_route(i, car_dat[i].car_id, car_dat[i].route));
  }

  car_route_uniques = new ArrayList();

  //Add first line
  car_route init_car = (car_route) car_route_all.get(0);
  car_route_uniques.add( new car_route(combo, init_car.car_id, init_car.route));

  while (z < car_route_all.size ()) {

    car_route current_car = (car_route) car_route_all.get(z);

    int match = 0;

    while (r < car_route_uniques.size ()) {

      car_route current_unique = (car_route) car_route_uniques.get(r);

      if (current_car.car_id == current_unique.car_id && current_car.route == current_unique.route) {

        match = 0;
        break;
      }
      else if (current_car.car_id != current_unique.car_id || current_car.route != current_unique.route) {

        match++;
        r++;
        continue;
      }
      else {
        r++; 
        continue;
      }
    }

    if (match >= 1) {

      car_route_uniques.add( new car_route(combo, current_car.car_id, current_car.route));
      combo++;
      //println(z + " - " + match);
    }

    r = 0;
    z++;
  }

  Collections.sort(car_route_uniques, new RouteComparator());
  
}

//set initial car data to zeroes
car_location prepop(int id, int car_id, String datetime, int time) {

  int route = 0;
  float x = 0;
  float y = 0;

  //puts all info into new object
  return new car_location(id, route, car_id, datetime, time, x, y);
} 

car_row prepop_row(int id, int car_id) {

  //puts all info into new object
  return new car_row(id, car_id, 0);
} 


//Get the latest info for a car at a specific time
car_location get_latest(int id, int car_id, int time) {

  int route = 0;
  float x = 0;
  float y = 0;
  String datetime = "0";
  int move = 0;
  int lookup_row = 0;
  int index_row = 0;
  int update_time = 0;

  while (index_row < unique_cars.length) {

    if (car_lookup[index_row].car_id == car_id) {

      lookup_row = car_lookup[index_row].row;
      break;
    }

    index_row++;
  }

  for (int i = lookup_row; i < placeCount; i++) {

    if (car_dat[i].car_id == car_id && car_dat[i].time <= time) {

      x = car_dat[i].x;
      y = car_dat[i].y;
      route = car_dat[i].route;
      datetime = car_dat[i].datetime;
      update_time = car_dat[i].time;

      move = 1;

      car_lookup[index_row].row = i;

      continue;
    }
  }

  if (move == 0) {

    x = car_last[id].x;
    y = car_last[id].y;
    route = car_last[id].route;
    datetime = car_last[id].datetime;
    update_time = car_last[id].time;
    
  }

  //puts all info into new object
  return new car_location(id, route, car_id, datetime, update_time, x, y);
} 


//Get the latest info for a car at a specific time
car_location get_latest_2(int id, int car_id, int time) {

  int route = 0;
  float x = 0;
  float y = 0;
  String datetime = "0";
  int move = 0;
  int lookup_row = 0;
  int index_row = 0;
  int update_time = 0;

  while (index_row < unique_cars.length) {

    if (car_lookup_2[index_row].car_id == car_id) {

      lookup_row = car_lookup_2[index_row].row;
      break;
    }

    index_row++;
  }

  for (int i = lookup_row; i < placeCount; i++) {

    if (car_dat[i].car_id == car_id && car_dat[i].time <= time) {

      x = car_dat[i].x;
      y = car_dat[i].y;
      route = car_dat[i].route;
      datetime = car_dat[i].datetime;
      update_time = car_dat[i].time;

      move = 1;

      car_lookup_2[index_row].row = i;

      continue;
    }
  }

  if (move == 0) {

    x = car_last_2[id].x;
    y = car_last_2[id].y;
    route = car_last_2[id].route;
    datetime = car_last_2[id].datetime;
    time = car_last_2[id].time;
    update_time = car_last_2[id].time;
    
  }

  //puts all info into new object
  return new car_location(id, route, car_id, datetime, update_time, x, y);
} 

//Mapping Lat/Lon to pixels
float TX(float x) {

  return map(x, minX, maxX, mapX1, mapX2);
}

float TY(float y) {

  return map(y, minY, maxY, mapY2, mapY1);
}

class RouteComparator implements Comparator {
 int compare(Object o1, Object o2) {
        int route1 = ((car_route)o1).route;        
        int route2 = ((car_route)o2).getRoute();
        
         if(route1 > route2)
            return 1;
        else if(route1 < route2)
            return -1;
        else
            return 0;    
 }
}
