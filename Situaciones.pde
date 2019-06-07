/* --------------------------------------------------------------------------
 * SimpleOpenNI User3d Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */


//http://stackoverflow.com/questions/11822144/processing-how-to-add-background-music
//https://forum.processing.org/one/topic/adding-music-to-the-code.html
//http://stackoverflow.com/questions/33883123/kinect-play-pause-music-in-processing



//Importem les llimbreries 
import SimpleOpenNI.*;


import ddf.minim.*; 
import ddf.minim.signals.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import ddf.minim.spi.*; 
import ddf.minim.ugens.*; 

SimpleOpenNI context;
Timer timer;
Timer timerFinal;
Timer timerIntruccions;

int instruccionsON = 0;

//Música 
Minim minim; 
AudioSnippet player; 

int ptsW, ptsH;
float        zoomF =0.5f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
// the data from openni comes upside down
float        rotY = radians(0);
boolean      autoCalib=true;

PVector      bodyCenter = new PVector();
PVector      bodyDir = new PVector();
PVector      com = new PVector();                                   
PVector      com2d = new PVector();    

PVector      pinicitir = new PVector();
PVector      pfinaltir = new PVector();
PVector      pinicitir2 = new PVector();
PVector      pfinaltir2 = new PVector();


color[]       userClr = new color[] { 
  color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(255, 0, 255), 
  color(0, 255, 255)
};

//Variable que ens indica si em de mostrar el menu o no. 
int menu = 1;

//Textures dels jugadors
PImage tex;
PImage cara1;
PImage cara2;
PImage cos1;
PImage cos2;


//Textures menu
PImage logo;
PImage play;
PImage instructions;
PImage track; 
PImage fons;

int recogida1 = 0;
int recogida2 = 0;

int enabletir1 = 0;
int enabletir2 = 0;

//Temps del tir 
int inittimetir1;
int finaltimetir1;
int inittimetir2;
int finaltimetir2;
int totaltime1;
int totaltime2;

/*Dos pantalles*/
PGraphics leftViewport;
PGraphics rightViewport;

int w = 1024;
int h = 768;

int numPointsW;
int numPointsH_2pi; 
int numPointsH;

float[] coorX;
float[] coorY;
float[] coorZ;
float[] multXZ;

//Textures Vides 
PImage player1;
PImage player2;
PImage player1vida1;
PImage player1vida2;
PImage player1vida3;
PImage player2vida1;
PImage player2vida2;
PImage player2vida3;

PImage player1vida0;
PImage player2vida0;

PImage player1novida;
PImage player2novida;

PImage p1wins;
PImage p2wins;

PImage audioON;
PImage audioOFF;

PImage instruccions; 

//Inicialització variable tir 
boolean bola_aire1 = false;
boolean bola_aire2 = false;
Mover m;

Mover moverUser1;
Mover moverUser2;

//ArrayList listSnowBalls_user1 = new ArrayList();
//ArrayList listSnowBalls_user2 = new ArrayList();

int createdBall1 = 0;
int createdBall2 = 0;

PVector madreta_user1 = new PVector();
PVector madreta_user2 = new PVector();

PVector maesquerra_user1 = new PVector();
PVector maesquerra_user2 = new PVector();


PVector body_user1 = new PVector();
PVector body_user2 = new PVector();

int vides_jugador1 = 3;
int vides_jugador2 = 3;

int flag_end = 0;

int flag_cop1 = 0;
int flag_cop2 = 0;

int partidaON = 1;
int audio; 

Timer musicTemps;

void setup()
{
  //size(1024, 768, P3D);
  size(displayWidth, displayHeight, P3D);  // strange, get drawing error in the cameraFrustum if i use P3D, in opengl there is no problem

  //Codi per partir la pantalla en dos, el programa va molt lent amb la doble pantalla. 
  //leftViewport = createGraphics(512, 768, P3D);
  //rightViewport = createGraphics(512, 768, P3D);

  context = new SimpleOpenNI(this);
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }

  /***TEXTURES***/
  tex = loadImage("snow_texture.jpg");
  cara1=loadImage("cara-nieve-gorro.jpg");
  cara2=loadImage("cara-nieve-gorro2.jpg");
  cos1=loadImage("cuerpo-nieve1.jpg");
  cos2=loadImage("cuerpo-nieve2.jpg");

  logo = loadImage("snowar.png");
  fons = loadImage("fons.jpg");

  play = loadImage("play.png");
  instructions = loadImage("instructions.png");
  track = loadImage("tracking.png");

  //Vides del jugador
  player1 = loadImage("p1.png");
  player2 = loadImage("p2.png");

  //Vides
  player2vida0 = loadImage("0.png");
  player1vida0 = loadImage("0.png");

  player2vida1 = loadImage("1.png");
  player2vida2 = loadImage("2.png");
  player2vida3 = loadImage("3.png");
  player1vida1 = loadImage("1b.png");
  player1vida2 = loadImage("2b.png");
  player1vida3 = loadImage("3b.png");

  p1wins = loadImage("p1wins.png");
  p2wins = loadImage("p2wins.png");

  audioON = loadImage("audioON.png");
  audioOFF = loadImage("audioOFF.png");

  instruccions = loadImage("instruccions_girat.png");

  textureMode(IMAGE);

  /**************/
  // disable mirror
  context.setMirror(false);

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser();

  stroke(255, 255, 255);
  smooth(); 

  perspective(radians(45), 
  float(width)/float(height), 
  10, 150000);


  ptsW=30;
  ptsH=30;
  // Parameters below are the number of vertices around the width and height
  initializeSphere(ptsW, ptsH);


  //Capturem el temps incial. 
  timer = new Timer(15000);
  timer.start();

  timerFinal = new Timer(7000); 

  timerIntruccions = new Timer(7000);

  musicTemps = new Timer(3000);

  //MÚSICA 
  minim = new Minim(this); 
  player = minim.loadSnippet("sound.wav");  
  audio = 1;
  println("audio       " + audio);
  player.play();
  player.loop();
}


void draw()
{

  // update the cam
  context.update();

  background(224, 255, 255);
  noStroke();
  camera(width/2, -140, 4200, width/2, height/2, 0, 0, 1, 0);  //CÁMARA
  // set the scene pos
  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);

  /*****PLÀ****/
  pushMatrix();
  translate(0, -1000, 0);

  //fill(0,255,0,1);
  //box(5000, 10, 5000); //Terra
  scale(30000, 0, 30000);
  TexturedCube(tex);
  popMatrix();
  /*********/

  /*   Fons     */
  pushMatrix();
  translate(width/2.0, height/2.0, 9000);
  scale(15000, 5000, 5);
  TexturedCube(fons);
  popMatrix();
  
  if(audio==1){
    pushMatrix();
    translate(6500, 4000, 6000);
    scale(300, 300, 5);
    pintaUnaCara(audioON);
    popMatrix();
  }else{
    pushMatrix();
    translate(6500, 4000, 6000);
    scale(300, 300, 5);
    pintaUnaCara(audioOFF);
    popMatrix();
  }

  int[]   depthMap = context.depthMap();
  int[]   userMap = context.userMap();
  int     steps   = 3;  // to speed up the drawing, draw every third point
  int     index;
  PVector realWorldPoint;

  translate(0, 0, -1000);  // set the rotation center of the scene 1000 infront of the camera
  if (instruccionsON == 0) {
    if (menu == 1 ) {

      /*****  Snowar ****/
      pushMatrix();
      translate(0, 1800, 1000);
      scale(3500, 1500, 30);
      pintaUnaCara(logo);
      popMatrix();
      /*********/

      //Draw Boto Play
      pushMatrix();
      translate(-2500, 500, 800);
      scale(1500, 500, 30);
      pintaUnaCara(play);
      popMatrix();

      //Draw Boto Instructions
      pushMatrix();
      translate(1500, 500, 800);
      scale(2000, 500, 30);
      pintaUnaCara(instructions);
      popMatrix();

      if (!timer.isFinished()) {

        //Draw Boto Instructions
        pushMatrix();
        translate(0, -500, -2600);
        scale(1500, 400, 30);
        pintaUnaCara(track);
        popMatrix();
      }

      //Pinta Usuari    
      pushMatrix();

      int user =1; 
      if (user == 1) {
        translate(-200, 0, -2000);
      }

      PVector head = new PVector();
      // put the position of the head into that vector
      context.getJointPositionSkeleton(user, SimpleOpenNI.SKEL_HEAD, head);
      boolean headFound = true;
      PMatrix3D  orientation = new PMatrix3D();
      context.getJointOrientationSkeleton(user, SimpleOpenNI.SKEL_HEAD, orientation);

      // Draw a box around the head joint
      // we'll look for depth points insde this box
      pushMatrix();
      pushStyle();
      noStroke(); 
      //fill(255,255,255,100);
      rectMode(CENTER);
      translate(head.x, head.y, head.z);
      rotateZ(PI);
      applyMatrix(orientation);//rotate box based on head orientation
      //textures segons el jugador. 
      textureMode(IMAGE);
      textureSphere(200, 200, 200, cara2);
      popStyle();
      popMatrix();

      //Cos
      PVector body = new PVector();
      // put the position of the head into that vector
      context.getJointPositionSkeleton(user, SimpleOpenNI.SKEL_TORSO, body);
      boolean bodyFound = true;
      PMatrix3D  orientation2 = new PMatrix3D();
      context.getJointOrientationSkeleton(user, SimpleOpenNI.SKEL_TORSO, orientation2);

      // Draw a box around the head joint
      // we'll look for depth points insde this box
      pushMatrix();
      pushStyle();
      //stroke(255, 0, 0);
      noStroke(); 
      fill(255, 255, 255, 100);
      rectMode(CENTER);
      translate(body.x, body.y, body.z);
      rotateZ(PI);
      applyMatrix(orientation2);//rotate box based on body orientation
      textureMode(IMAGE);
      //textures segons el jugador. 
      if (user == 1) {
        textureSphere(300, 300, 300, cos1);
      }

      popStyle();
      popMatrix();

      //Mà 1
      PVector madreta = new PVector();
      // put the position of the head into that vector
      context.getJointPositionSkeleton(user, SimpleOpenNI.SKEL_RIGHT_HAND, madreta);
      boolean madretaFound = true;
      PMatrix3D  orientation3 = new PMatrix3D();
      context.getJointOrientationSkeleton(user, SimpleOpenNI.SKEL_RIGHT_HAND, orientation3);

      pushMatrix();
      pushStyle();
      noStroke(); 
      fill(255);
      rectMode(CENTER);
      translate(madreta.x, madreta.y, madreta.z);
      applyMatrix(orientation3);//rotate box based on body orientation
      sphere(75);
      popStyle();
      popMatrix();

      //Mà 2
      PVector maesquerra = new PVector();
      context.getJointPositionSkeleton(user, SimpleOpenNI.SKEL_LEFT_HAND, maesquerra);
      boolean maesquerraFound = true;
      PMatrix3D  orientation4 = new PMatrix3D();
      context.getJointOrientationSkeleton(user, SimpleOpenNI.SKEL_LEFT_HAND, orientation4);

      pushMatrix();
      pushStyle();
      noStroke(); 
      fill(255);
      rectMode(CENTER);
      translate(maesquerra.x, maesquerra.y, maesquerra.z);
      applyMatrix(orientation4);//rotate box based on body orientation
      //box(400);
      sphere(75);
      popStyle();
      popMatrix();

      drawLimb(user, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);      
      drawLimb(user, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
      drawLimb(user, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
      drawLimb(user, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

      drawLimb(user, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
      drawLimb(user, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
      drawLimb(user, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

      drawLimb(user, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
      drawLimb(user, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

      drawLimb(user, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
      drawLimb(user, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
      drawLimb(user, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

      drawLimb(user, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
      drawLimb(user, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
      drawLimb(user, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  


      // draw body direction
      getBodyDirection(user, bodyCenter, bodyDir);

      bodyDir.mult(200);  // 200mm length
      bodyDir.add(bodyCenter);

      stroke(255, 200, 200);
      line(bodyCenter.x, bodyCenter.y, bodyCenter.z, 
      bodyDir.x, bodyDir.y, bodyDir.z);

      strokeWeight(1);

      //println("DRETAAAA     " + madreta.x + "  " + madreta.y + "   " + madreta.z);
      //println("ESQUERRA     " + maesquerra.x + "  " + maesquerra.y + "   " + maesquerra.z);

      if (madreta.x > 200 &&  madreta.y > 400 && madreta.z > 1000 && madreta.z > 1000 && madreta.z < 2000 ) {
        //println(" INTRODUCTIONS!!!! ");
        timerIntruccions.start();
        instruccionsON = 1;
      } else {

        if (maesquerra.x < 0 &&  maesquerra.y > 400 && maesquerra.z > 1000) {
          menu = 0;
        }
      }


      if (abs(madreta.x - maesquerra.x) <  30 && madreta.x != 0.0 && maesquerra.x!= 0.0 ) {

        println("                                           AUDIO  val" + audio);

        //parem la musica o l'encenem 
        switch (audio) {
        case 1: 

          player.pause();
          println("STOOOOOOOP MUSIC");

          audio = 0;

          break;

        case 0: 
          player.play();
          println("PLAAAAAAAAY MUSIC" );
          audio = 1; 

          break;
        }
      }        

      popMatrix();
    } else {
      
      drawVida(player1, 200, 880, -1500, 2300);
      drawVida(player2, 200, 880, 1500, 2300);

      if (partidaON == 1) {
        switch(vides_jugador1) {

        case 0: 
          //println("Timer has started");
          timerFinal.start();
          partidaON = 0;
          //println("La partida s'ha acabat");
          break;
        case 1: 
          drawVida(player1vida1, 150, 600, -1500, 1900);
          break;
        case 2: 
          drawVida(player1vida2, 150, 600, -1500, 1900);
          break;
        case 3: 
          drawVida(player1vida3, 150, 600, -1500, 1900); 
          break;
        }
        switch(vides_jugador2) {
        case 0:
          //println("Timer has started");
          timerFinal.start();
          partidaON = 0;
          //println("La partida s'ha acabat");
          break;
        case 1:  
          drawVida(player2vida1, 150, 600, 1500, 1900); 
          break;
        case 2:  
          drawVida(player2vida2, 150, 600, 1500, 1900); 
          break;
        case 3:  
          drawVida(player2vida3, 150, 600, 1500, 1900); 
          break;
        }


        // draw the skeleton if it's available
        int[] userList = context.getUsers();
        for (int i=0; i<userList.length; i++)
        {
          if (context.isTrackingSkeleton(userList[i]))
            drawSkeleton(userList[i]);

          // draw the center of mass
          if (context.getCoM(userList[i], com))
          {
            stroke(100, 255, 0);
            strokeWeight(1);
            beginShape(LINES);
            vertex(com.x - 15, com.y, com.z);
            vertex(com.x + 15, com.y, com.z);

            vertex(com.x, com.y - 15, com.z);
            vertex(com.x, com.y + 15, com.z);

            vertex(com.x, com.y, com.z - 15);
            vertex(com.x, com.y, com.z + 15);
            endShape();

            fill(0, 255, 100);
            text(Integer.toString(userList[i]), com.x, com.y, com.z);
          }
        }
      } else {

        if (vides_jugador2 == 0 ) {
          drawVida(player2vida0, 150, 600, 1500, 1900); 
          pushMatrix();
          translate(0, 700, -3000);
          scale(2500, 800, 30);
          pintaUnaCara(p1wins);
          popMatrix();

          switch(vides_jugador2) {
          case 1:  
            drawVida(player2vida1, 150, 600, 1500, 1900); 
            break;
          case 2:  
            drawVida(player2vida2, 150, 600, 1500, 1900); 
            break;
          case 3:  
            drawVida(player2vida3, 150, 600, 1500, 1900); 
            break;
          }
        }

        if (vides_jugador1 == 0) {

          drawVida(player1vida0, 150, 600, -1500, 1900);
          pushMatrix();
          translate(0, 700, -3000);
          scale(2500, 800, 30);
          pintaUnaCara(p2wins);
          popMatrix();
          switch(vides_jugador2) {
          case 1:  
            drawVida(player2vida1, 150, 600, 1500, 1900); 
            break;
          case 2:  
            drawVida(player2vida2, 150, 600, 1500, 1900); 
            break;
          case 3:  
            drawVida(player2vida3, 150, 600, 1500, 1900); 
            break;
          }
        }

        if (timerFinal.isFinished()) {
          //println("END");
          menu=1;
          partidaON=1;
          vides_jugador1= 3;
          vides_jugador2=3;
        }
      }
    }
  } else {
    //instruccions = 1;
    pushMatrix();
    translate(0, 0, -1000);
    scale(2500, 1000, 5);
    TexturedCube(instruccions);
    popMatrix();
  }
  if (timerIntruccions.isFinished()) {
    instruccionsON = 0;
  } 

  // draw the kinect cam
  context.drawCamFrustum();
}

void TexturedCube(PImage tex) {
  beginShape(QUADS);
  texture(tex);
  textureMode(NORMAL);

  // Given one texture and six faces, we can easily set up the uv coordinates
  // such that four of the faces tile "perfectly" along either u or v, but the other
  // two faces cannot be so aligned.  This code tiles "along" u, "around" the X/Z faces
  // and fudges the Y faces - the Y faces are arbitrarily aligned such that a
  // rotation along the X axis will put the "top" of either texture at the "top"
  // of the screen, but is not otherwised aligned with the X/Z faces. (This
  // just affects what type of symmetry is required if you need seamless
  // tiling all the way around the cube)

  // +Z "front" face
  vertex(-1, -1, 1, 0, 0);
  vertex( 1, -1, 1, 1, 0);
  vertex( 1, 1, 1, 1, 1);
  vertex(-1, 1, 1, 0, 1);

  // -Z "back" face
  vertex( 1, -1, -1, 0, 0);
  vertex(-1, -1, -1, 1, 0);
  vertex(-1, 1, -1, 1, 1);
  vertex( 1, 1, -1, 0, 1);

  // +Y "bottom" face
  vertex(-1, 1, 1, 0, 0);
  vertex( 1, 1, 1, 1, 0);
  vertex( 1, 1, -1, 1, 1);
  vertex(-1, 1, -1, 0, 1);

  // -Y "top" face
  vertex(-1, -1, -1, 0, 0);
  vertex( 1, -1, -1, 1, 0);
  vertex( 1, -1, 1, 1, 1);
  vertex(-1, -1, 1, 0, 1);

  // +X "right" face
  vertex( 1, -1, 1, 0, 0);
  vertex( 1, -1, -1, 1, 0);
  vertex( 1, 1, -1, 1, 1);
  vertex( 1, 1, 1, 0, 1);

  // -X "left" face
  vertex(-1, -1, -1, 0, 0);
  vertex(-1, -1, 1, 1, 0);
  vertex(-1, 1, 1, 1, 1);
  vertex(-1, 1, -1, 0, 1);

  endShape();
}

void drawCylinder(int sides, float r)
{
  float angle = 360 / sides;
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y );
  }
  endShape(CLOSE);
}


// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  strokeWeight(3);

  pushMatrix();


  if (userId == 1) {
    translate(0, 0, -2000);
    rotateY(PI);
  }
  if (userId == 2) {
    translate(0, 0, 4000);
  }
  // to get the 3d joint data
  //drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  /*PMatrix3D  orientation = new PMatrix3D();
   context.getJointOrientationSkeleton(userId,SimpleOpenNI.SKEL_HEAD,orientation);
   pushMatrix();
   //applyMatrix(orientation);//rotate box based on head orientation
   box(40);
   popMatrix(); */

  PVector head = new PVector();
  // put the position of the head into that vector
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, head);
  boolean headFound = true;
  PMatrix3D  orientation = new PMatrix3D();
  context.getJointOrientationSkeleton(userId, SimpleOpenNI.SKEL_HEAD, orientation);

  // Draw a box around the head joint
  // we'll look for depth points insde this box
  pushMatrix();
  pushStyle();
  noStroke(); 
  //fill(255,255,255,100);
  rectMode(CENTER);
  translate(head.x, head.y, head.z);
  rotateZ(PI);
  applyMatrix(orientation);//rotate box based on head orientation
  //textures segons el jugador. 
  textureMode(IMAGE);
  if (userId == 1) {
    textureSphere(200, 200, 200, cara1);
  }
  if (userId == 2) {
    textureSphere(200, 200, 200, cara2);
  }
  popStyle();
  popMatrix();

  //Cos

  PVector body = new PVector();
  // put the position of the head into that vector
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_TORSO, body);
  //En funció del jugador guardem el body al jugador que li toca
  if (userId == 1) {
    body_user1 =  body;
  }
  if (userId == 2) {
    body_user2 = body;
  }

  boolean bodyFound = true;
  PMatrix3D  orientation2 = new PMatrix3D();
  context.getJointOrientationSkeleton(userId, SimpleOpenNI.SKEL_TORSO, orientation2);

  // Draw a box around the head joint
  // we'll look for depth points insde this box
  pushMatrix();
  pushStyle();
  //stroke(255, 0, 0);
  noStroke(); 
  fill(255, 255, 255, 100);
  rectMode(CENTER);
  translate(body.x, body.y, body.z);
  rotateZ(PI);
  applyMatrix(orientation2);//rotate box based on body orientation
  textureMode(IMAGE);
  //textures segons el jugador. 
  if (userId == 1) {
    textureSphere(300, 300, 300, cos2);
  }
  if (userId == 2) {
    textureSphere(300, 300, 300, cos1);
  }


  popStyle();
  popMatrix();

  //Mà 1
  PVector madreta = new PVector();
  // put the position of the head into that vector
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, madreta);

  if (userId == 1) {
    madreta_user1 =  madreta;
  }
  if (userId == 2) {
    madreta_user2 = madreta;
  }

  boolean madretaFound = true;
  PMatrix3D  orientation3 = new PMatrix3D();
  context.getJointOrientationSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, orientation3);

  // Draw a box around the head joint
  // we'll look for depth points insde this box
  pushMatrix();
  pushStyle();
  noStroke(); 
  fill(255);
  rectMode(CENTER);
  translate(madreta.x, madreta.y, madreta.z);
  applyMatrix(orientation3);//rotate box based on body orientation
  //box(400);
  sphere(75);
  popStyle();
  popMatrix();


  //Mà 2
  PVector maesquerra = new PVector();
  // put the position of the head into that vector
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, maesquerra);
    
  boolean maesquerraFound = true;
  PMatrix3D  orientation4 = new PMatrix3D();
  context.getJointOrientationSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, orientation4);

  // Draw a box around the head joint
  // we'll look for depth points insde this box
  pushMatrix();
  pushStyle();
  noStroke(); 
  fill(255);
  rectMode(CENTER);
  translate(maesquerra.x, maesquerra.y, maesquerra.z);
  applyMatrix(orientation4);//rotate box based on body orientation
  //box(400);
  sphere(75);
  popStyle();
  popMatrix();

  drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);      
  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  

  // draw body direction
  getBodyDirection(userId, bodyCenter, bodyDir);

  bodyDir.mult(200);  // 200mm length
  bodyDir.add(bodyCenter);

  stroke(255, 200, 200);
  line(bodyCenter.x, bodyCenter.y, bodyCenter.z, 
  bodyDir.x, bodyDir.y, bodyDir.z);

  strokeWeight(1);
  strokeWeight(1);

  popMatrix();
  
 
  /***RECOGER BOLA***/
  if (madreta_user1.y < -700) {
    if (userId == 1 && recogida1 == 0) {
      recogida1 = 1;
    }
  }

  if (madreta_user2.y < -700) {
    if (userId == 2 && recogida2 == 0) {
      recogida2 = 1;
    }
  }

  if ((recogida1 == 1) && (createdBall1 == 0)) {
    //pushMatrix();
    if (userId == 1) {
      stroke(0, 0, 255);    
      if (bola_aire1 == false) {
        moverUser1 = new Mover(1, madreta_user1.x, madreta_user1.y, madreta_user1.z, 1);
      }
      createdBall1 = 1;
    }
  }
  if (recogida1 == 1) {
    moverUser1.moveBallLocation(madreta_user1.x, madreta_user1.y, madreta_user1.z);
    moverUser1.update();

    moverUser1.display();
  }

  if ((recogida2 == 1) && (createdBall2 == 0)) {
    if (userId == 2) {
      stroke(0, 0, 255); 

      if (bola_aire2==false) {
        moverUser2 = new Mover(1, madreta_user2.x, madreta_user2.y, madreta_user2.z, 2);
      }
      createdBall2 = 1;
    }
  }


  if (recogida2 == 1) {
    moverUser2.moveBallLocation(madreta_user2.x, madreta_user2.y, madreta_user2.z);
    moverUser2.update();

    moverUser2.display();
  }

  if (userId == 1 && recogida1 == 1) {
    if ((madreta_user1.z - body_user1.z) > 300) {
      pinicitir.x = madreta_user1.x;
      pinicitir.y = madreta_user1.y;
      pinicitir.z = madreta_user1.z;
      enabletir1 = 1;
      inittimetir1 = millis();
    }

    if ((body_user1.z - madreta_user1.z) > 340 && enabletir1 == 1) {
      pfinaltir.x = madreta_user1.x;
      pfinaltir.y = madreta_user1.y;
      pfinaltir.z = madreta_user1.z;
      recogida1 = 0; //Tir
      createdBall1 = 0;
      enabletir1 = 0;
      finaltimetir1 = millis();
      totaltime1 = finaltimetir1 - inittimetir1;

      bola_aire1 = true;
      flag_cop1 = 0;

      PVector tirDirNotNormaliz1 = PVector.sub(pfinaltir, pinicitir);
      //println("Vector TIRO:  X : "  + tirDirNotNormaliz.x + " Y :" + tirDirNotNormaliz.y + " Z :" + tirDirNotNormaliz.z);

      float tirX1 = tirDirNotNormaliz1.x;  

      tirDirNotNormaliz1.normalize();
      totaltime1 = totaltime1;

      PVector throwForce1 = new PVector (200*tirDirNotNormaliz1.x, 10*tirDirNotNormaliz1.y, -100000.0/totaltime1);

      moverUser1.throwBall(throwForce1);
    }
  }
  if (userId == 2 && recogida2 == 1) {
    if ((madreta_user2.z - body_user2.z) > 300) {
      pinicitir2.x = madreta_user2.x;
      pinicitir2.y = madreta_user2.y;
      pinicitir2.z = madreta_user2.z;
      enabletir2 = 1;
      inittimetir2 = millis();
    }

    if ((body_user2.z - madreta_user2.z) > 340 && enabletir2 == 1) {
      pfinaltir2.x = madreta_user2.x;
      pfinaltir2.y = madreta_user2.y;
      pfinaltir2.z = madreta_user2.z;

      recogida2 = 0; //Tir
      enabletir2 = 0;
      finaltimetir2 = millis();
      totaltime2 = finaltimetir2 - inittimetir2;

      bola_aire2 = true;
      flag_cop2=0;

      PVector tirDirNotNormaliz2 = PVector.sub(pfinaltir2, pinicitir2);
      tirDirNotNormaliz2.normalize();
      totaltime1 = totaltime1;

      PVector throwForce2 = new PVector (200*tirDirNotNormaliz2.x, 10*tirDirNotNormaliz2.y, -100000.0/totaltime2);

      moverUser2.throwBall(throwForce2);
    }
  }

  if (bola_aire1) {

    //println("BLZBLZBLZ");
    PVector gravity = new PVector(0.0, -0.8);

    gravity.mult(moverUser1.mass);
    moverUser1.applyForce(gravity);
    PVector friction = moverUser1.velocity.get();
    friction.normalize();
    float c = -0.3;
    friction.mult(c);

    moverUser1.applyForce(friction);

    moverUser1.update();
    moverUser1.display();

    if (moverUser1.location.y < -800) {

      //println("Bola ELIMINADA USER 1");
      bola_aire1 = false;
    }

    float izquierda = body_user2.x-400;
    float derecha = body_user2.x+400;

    if ( (moverUser1.location.z < ((-1)*(+4000 + body_user2.z -300))) && (moverUser1.location.z > ((-1)*(+4000 + body_user2.z +300)))) {
      //println("Entra bounding Z - Jugador1");
      if ((moverUser1.location.y >= body_user2.y-350) && (moverUser1.location.y <= body_user2.y+750)) {
        //println("Entra bounding Y - Jugador 1");
        // println("BOLA Location X "+moverUser1.locationDisplayTransformed.x);
        //  println("BODY X LIMIT IZ "+(body_user2.x-300));
        //   println("BODY X LIMIT DER "+(body_user2.x+300));
        //println();
        float tironeg = (-1)*(moverUser1.locationDisplayTransformed.x);

        if ((tironeg > izquierda) && (tironeg < derecha)) {
          println("HIT!!!!!!!**************************************************************************************************");
          if (flag_cop1==0 && bola_aire1 == true) {
            flag_cop1=1;
            bola_aire1=false;
            vides_jugador2 = vides_jugador2 - 1;
            println("VIDES RESTANTS 2 : "+ vides_jugador2);
            println("VIDES RESTANTS 1 : "+ vides_jugador1);
          }
        }
      }
    }
  }


  if (bola_aire2) {

    //println("BLZBLZBLZ");
    PVector gravity = new PVector(0.0, -0.8);

    gravity.mult(moverUser2.mass);
    moverUser2.applyForce(gravity);
    PVector friction = moverUser2.velocity.get();
    friction.normalize();
    float c = -0.3;
    friction.mult(c);

    moverUser2.applyForce(friction);

    moverUser2.update();
    moverUser2.display();

    if (moverUser2.location.y < -800) {

      //println("Bola ELIMINADA USER 2");
      bola_aire2 = false;
    }

    float izquierda = body_user1.x-400;
    float derecha = body_user1.x+400;

    //println("LOCATION BOLA Z:" +moverUser2.location.z);
    //println("LOCATION TORSO Z:" +(-2000 - body_user1.z -300));
    //println("LOCATION BOLA Y:" +moverUser1.location.y);

    if ( (moverUser2.location.z > ((1)*(-2000 - body_user1.z -300))) && (moverUser2.location.z < ((1)*(-2000 - body_user1.z +300)))) {
      println("Entra bounding Z - Jugador2");


      if ((moverUser2.location.y >= body_user1.y-350) && (moverUser2.location.y <= body_user1.y+750)) {


        println("Entra bounding Y - Jugador2");
        //println("BOLA Location X "+moverUser2.locationDisplayTransformed.x);
        //println("BODY X LIMIT IZ "+(body_user1.x-300));
        //println("BODY X LIMIT DER "+(body_user1.x+300));
        //println("LOCATION BOLA X:" +moverUser2.location.x);
        //println("LOCATION X arriba:" +(body_user1.x-300));
        //println("LOCATION X abajo:" +(body_user1.x+300));
        //println();

        float tironeg = (-1)*(moverUser2.locationDisplayTransformed.x);
        //float tironeg = (moverUser2.locationDisplayTransformed.x);


        if ((tironeg > izquierda) && (tironeg < derecha)) {
          println("HIT USUARIIIII 2!!!!!!!**************************************************************************************************");
          if (flag_cop2==0 && bola_aire2 == true) {
            flag_cop2=1;
            bola_aire2=false;
            vides_jugador1 = vides_jugador1 - 1;
            println("VIDES RESTANTS 2 : "+ vides_jugador2);
            println("VIDES RESTANTS 1 : "+ vides_jugador1);
          }

          println();
        }
      }
    }
  }
}


void drawLimb(int userId, int jointType1, int jointType2)
{
  PVector jointPos1 = new PVector();
  PVector jointPos2 = new PVector();
  float  confidence;

  // draw the joint position
  confidence = context.getJointPositionSkeleton(userId, jointType1, jointPos1);
  confidence = context.getJointPositionSkeleton(userId, jointType2, jointPos2);

  stroke(255, 0, 0, confidence * 200 + 55);
  line(jointPos1.x, jointPos1.y, jointPos1.z, 
  jointPos2.x, jointPos2.y, jointPos2.z);

  drawJointOrientation(userId, jointType1, jointPos1, 50);
}

void drawJointOrientation(int userId, int jointType, PVector pos, float length)
{
  // draw the joint orientation  
  PMatrix3D  orientation = new PMatrix3D();
  float confidence = context.getJointOrientationSkeleton(userId, jointType, orientation);
  if (confidence < 0.001f) 
    // nothing to draw, orientation data is useless
    return;

  pushMatrix();
  translate(pos.x, pos.y, pos.z);

  // set the local coordsys
  applyMatrix(orientation);

  // coordsys lines are 100mm long
  // x - r
  stroke(255, 0, 0, confidence * 200 + 55);
  line(0, 0, 0, 
  length, 0, 0);
  // y - g
  stroke(0, 255, 0, confidence * 200 + 55);
  line(0, 0, 0, 
  0, length, 0);
  // z - b    
  stroke(0, 0, 255, confidence * 200 + 55);
  line(0, 0, 0, 
  0, 0, length);
  popMatrix();
}

// -----------------------------------------------------------------
// SimpleOpenNI user events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  context.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


// -----------------------------------------------------------------
// Keyboard events

void keyPressed()
{
  switch(key)
  {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }

  switch(keyCode)
  {
  case LEFT:
    rotY += 0.1f;
    break;
  case RIGHT:
    // zoom out
    rotY -= 0.1f;
    break;
  case UP:
    if (keyEvent.isShiftDown())
      zoomF += 0.01f;
    else
      rotX += 0.1f;
    break;
  case DOWN:
    if (keyEvent.isShiftDown())
    {
      zoomF -= 0.01f;
      if (zoomF < 0.01)
        zoomF = 0.01;
    } else
      rotX -= 0.1f;
    break;
  }
}

void getBodyDirection(int userId, PVector centerPoint, PVector dir)
{
  PVector jointL = new PVector();
  PVector jointH = new PVector();
  PVector jointR = new PVector();
  float  confidence;

  // draw the joint position
  confidence = context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, jointL);
  confidence = context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, jointH);
  confidence = context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, jointR);

  // take the neck as the center point
  confidence = context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_NECK, centerPoint);

  /*  // manually calc the centerPoint
   PVector shoulderDist = PVector.sub(jointL,jointR);
   centerPoint.set(PVector.mult(shoulderDist,.5));
   centerPoint.add(jointR);
   */

  PVector up = PVector.sub(jointH, centerPoint);
  PVector left = PVector.sub(jointR, centerPoint);

  dir.set(up.cross(left));
  dir.normalize();
}

void initializeSphere(int numPtsW, int numPtsH_2pi) {

  // The number of points around the width and height
  numPointsW=numPtsW+1;
  numPointsH_2pi=numPtsH_2pi;  // How many actual pts around the sphere (not just from top to bottom)
  numPointsH=ceil((float)numPointsH_2pi/2)+1;  // How many pts from top to bottom (abs(....) b/c of the possibility of an odd numPointsH_2pi)

  coorX=new float[numPointsW];   // All the x-coor in a horizontal circle radius 1
  coorY=new float[numPointsH];   // All the y-coor in a vertical circle radius 1
  coorZ=new float[numPointsW];   // All the z-coor in a horizontal circle radius 1
  multXZ=new float[numPointsH];  // The radius of each horizontal circle (that you will multiply with coorX and coorZ)

  for (int i=0; i<numPointsW; i++) {  // For all the points around the width
    float thetaW=i*2*PI/(numPointsW-1);
    coorX[i]=sin(thetaW);
    coorZ[i]=cos(thetaW);
  }

  for (int i=0; i<numPointsH; i++) {  // For all points from top to bottom
    if (int(numPointsH_2pi/2) != (float)numPointsH_2pi/2 && i==numPointsH-1) {  // If the numPointsH_2pi is odd and it is at the last pt
      float thetaH=(i-1)*2*PI/(numPointsH_2pi);
      coorY[i]=cos(PI+thetaH); 
      multXZ[i]=0;
    } else {
      //The numPointsH_2pi and 2 below allows there to be a flat bottom if the numPointsH is odd
      float thetaH=i*2*PI/(numPointsH_2pi);

      //PI+ below makes the top always the point instead of the bottom.
      coorY[i]=cos(PI+thetaH); 
      multXZ[i]=sin(thetaH);
    }
  }
}

void textureSphere(float rx, float ry, float rz, PImage t) { 
  // These are so we can map certain parts of the image on to the shape 
  float changeU=t.width/(float)(numPointsW-1); 
  float changeV=t.height/(float)(numPointsH-1); 
  float u=0;  // Width variable for the texture
  float v=0;  // Height variable for the texture

  beginShape(TRIANGLE_STRIP);
  texture(t);
  for (int i=0; i< (numPointsH-1); i++) {  // For all the rings but top and bottom
    // Goes into the array here instead of loop to save time
    float coory=coorY[i];
    float cooryPlus=coorY[i+1];

    float multxz=multXZ[i];
    float multxzPlus=multXZ[i+1];

    for (int j=0; j<numPointsW; j++) { // For all the pts in the ring
      normal(-coorX[j]*multxz, -coory, -coorZ[j]*multxz);
      vertex(coorX[j]*multxz*rx, coory*ry, coorZ[j]*multxz*rz, u, v);
      normal(-coorX[j]*multxzPlus, -cooryPlus, -coorZ[j]*multxzPlus);
      vertex(coorX[j]*multxzPlus*rx, cooryPlus*ry, coorZ[j]*multxzPlus*rz, u, v+changeV);
      u+=changeU;
    }
    v+=changeV;
    u=0;
  }
  endShape();
}

void pintaUnaCara(PImage tex) {
  beginShape(QUADS);
  texture(tex);
  textureMode(NORMAL);

  // +Z "front" face
  vertex(-1, -1, 1, 0, 0);
  vertex( 1, -1, 1, 1, 0);
  vertex( 1, 1, 1, 1, 1);
  vertex(-1, 1, 1, 0, 1);

  endShape();
}

void drawVida(PImage player, int amplada, int llargada, int x, int y) {
  //Draw Boto Play
  pushMatrix();
  translate(x, y, -1000);
  scale(llargada, amplada, 30);
  pintaUnaCara(player);
  popMatrix();
}


//MUSIIIC 
void stop() {
  player.close();
  minim.stop();
  super.stop();
}

