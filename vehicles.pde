class car_location {
  
 int id;
 int route;
 int car_id;
 int time;
 String datetime;
 float x;
 float y; 
  
 public car_location(int id, int route, int car_id, String datetime, int time, float x, float y) {
   
   this.id = id;
   this.route = route;
   this.car_id = car_id;
   this.datetime = datetime;
   this.time = time;
   this.x = x;
   this.y = y;   
   
 }
  

  
}

class car_row {
  
 int id;
 int car_id;
 int row;
  
 public car_row(int id, int car_id,  int row) {
   
   this.id = id;
   this.car_id = car_id;
   this.row = row;  
   
 }
  
}


class car_route {
  
 int id;
 int car_id;
 int route;
  
 public car_route(int id, int car_id,  int route) {
   
   this.id = id;
   this.car_id = car_id;
   this.route = route;  
   
 }
 
 public int getRoute(){
   
  return this.route;
   
 }
  
}


