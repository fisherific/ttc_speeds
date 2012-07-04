class Proj{
  
  float x;
  float y;
  
  public Proj(float lat, float lon){
    
//EPSG Guidance Note #7-2 
//Albers - great lakes

float e = 0.08209443803685366;
float a = 6378137;

lat = radians(lat);
lon = radians(lon);
float lat0 = radians(45.568977);
float lat1 = radians(42.122774);
float lat2 = radians(49.015180);
float lon0 = radians(-84.455955);

float alpha   = (1 - sq(e)) * ( (sin(lat) /  (1 - sq(e) * sq(sin(lat )))) - ( (1 / (2 * e)) * log( (1 - e * sin(lat)) /  (1 + e * sin(lat )) ) ) );
float alpha0  = (1 - sq(e)) * ( (sin(lat0) / (1 - sq(e) * sq(sin(lat0)))) - ( (1 / (2 * e)) * log( (1 - e * sin(lat0)) / (1 + e * sin(lat0)) ) ) );
float alpha1  = (1 - sq(e)) * ( (sin(lat1) / (1 - sq(e) * sq(sin(lat1)))) - ( (1 / (2 * e)) * log( (1 - e * sin(lat1)) / (1 + e * sin(lat1)) ) ) );
float alpha2  = (1 - sq(e)) * ( (sin(lat2) / (1 - sq(e) * sq(sin(lat2)))) - ( (1 / (2 * e)) * log( (1 - e * sin(lat2)) / (1 + e * sin(lat2)) ) ) );

float m1 = cos(lat1)/sqrt(1-sq(e)*sq(sin(lat1)));
float m2 = cos(lat2)/sqrt(1-sq(e)*sq(sin(lat2)));

float n   = (sq(m1) - sq(m2)) / (alpha2 - alpha1);

float theta  = n * (lon - lon0);
float C  = sq(m1) +  (n * alpha1);
float rho  = (a * sqrt(C - n * alpha)) / n;
float rho0 = (a * sqrt(C - n * alpha0)) / n;

float x =  1000000 + (rho * sin(theta));
float y =  1000000 + rho0 - (rho * cos(theta));
  
  
  this.x = x;
  this.y = y; 

  }
}

