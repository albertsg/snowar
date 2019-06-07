class Mover {
     PVector location;
     PVector locationDisplayTransformed;
      PVector velocity;
      PVector acceleration;
      float mass;
      int id_user;
      
      Mover(float m, float x, float y, float z, int id) {
        location = new PVector(x,y,z);
        velocity = new PVector(0.0, 0.0, 0.0);
        acceleration = new PVector(0, 0, 0);
        locationDisplayTransformed = new PVector(0, 0, 0);
        mass = m;
        id_user = id;
        
      }
      
      void applyForce(PVector force) {
         PVector f = PVector.div(force, mass);
         acceleration.add(f); 
      }
      
      void update() {
         velocity.add(acceleration);
          location.add(velocity);
         acceleration.mult(0); 
        
        
        
      }
      
      void moveBallLocation(float x, float y, float z) {
        location.x = x;
        location.y = y;
        location.z = z;        
      }
      /*
      void display(float cameraX, float cameraY) {
         camera(cameraX, cameraY, (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);
         pushMatrix();
         
         fill(255, 0, 0);
         translate(location.x, location.y, location.z);
         sphere(12);
         popMatrix();
        
        
      }
      */
      
      void display() {
         //camera(cameraX, cameraY, (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);
         pushMatrix();
         

         if (id_user == 1) {
           fill(138, 144, 222);
           translate(0,0,-2000);
            rotateY(PI);
         }
         
         if (id_user == 2) {
           fill(249, 169, 169);
           translate(0,0, 4000);
         }
         noStroke();
         translate(location.x, location.y, location.z);
         locationDisplayTransformed.x = location.x;
         locationDisplayTransformed.y = location.y;
         locationDisplayTransformed.z = location.z;
         sphere(100);
         popMatrix();
        
        
      }
      
      
      void checkBoundaries() {
        if (location.y > height/2 + 82) {
          
          velocity.y = -velocity.y;
          location.y = height/2 + 82;
          
        }
        
        
        if (location.x > width/2 + 440) {
           //location.x =  width/2 + 230;
           velocity.x = -velocity.x;
        }else if (location.x < width/2 - 440) {
           //location.x =  width/2 - 230;
           velocity.x = -velocity.x;
        }
        
        
        if (location.z < -115) {
          velocity.z = -velocity.z;
          //location.z = -115;
        }else if (location.z > 115) {
          velocity.z = -velocity.z;
           //location.z = 115; 
        }
      }
  
      
      void throwBall(PVector throwForce) {
         velocity.x = throwForce.x;
         velocity.y = throwForce.y; 
         velocity.z = throwForce.z;
      }
  
  
  
  
  
  
}
