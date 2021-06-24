// CSCI 5611. Project 1
// Ioana Munteanu

static int numBoids = 100;
int numBoidstoGen = 50;
//Inital positions and velocities of masses
Vec2 pos[] = new Vec2[numBoids];
Vec2 vel[] = new Vec2[numBoids];
Vec2 dir[] = new Vec2[numBoids];
int curBoids = 25; //current number of boids

//Set parameters of the simulation
float maxSpeed = 128; // Maximum speed you can manually increase to
float targetSpeed = 16; // Current speed
float maxForce = 5; // Used to generate forces
float genRate = 3; //Generation Rate of the Boids
PImage bg; //Ocean image for background
float randomSize[] = new float[numBoids]; //Array used to generate a random size for fish

//Variables used to turn on/off the features
int pressSep = 0;
int pressCoh = 0;
int pressAli = 0;
int pressFollow = 0;


void setup(){
  size(850,638);
  surface.setTitle("Project 1");
  bg = loadImage("ocean.jpg");

  // Generator for different sizes of the boids
  for (int i = 0; i < numBoids; i++) randomSize[i] = 0.7 + random(0.8);
  
  //Initial boid positions and velocities
  for (int i = 0; i < curBoids; i++){
    pos[i] = new Vec2(200+random(200),-200+random(100));
    vel[i] = new Vec2(-1+random(2),-1+random(2));
    vel[i].normalize();
    vel[i].mul(maxSpeed);
  }
}

float dt = 0.1;

void update(float dt){

  float toGen_float = genRate * dt;
  int toGen = int(toGen_float);
  float fractPart = toGen_float - toGen;
  if (random(1) < fractPart) toGen += 1;
  //Feature that makes the first 10 boids follow the mouse and disappear when they reach the goal
  if (pressFollow == 1)
    for (int i = 0; i < 10; i++){
      dir[i] = new Vec2((mouseX - pos[i].x), (mouseY - pos[i].y));
      if (dir[i].length() > 0) dir[i].normalize();
      vel[i] = dir[i];
      pos[i].add(vel[i]);
      vel[i].normalize();
      vel[i].mul(maxSpeed/4);
      Vec2 mouse = new Vec2(mouseX, mouseY);
      if (pos[i].distanceTo(mouse) <1) {pos[i] = new Vec2(0,0); vel[i] = new Vec2(0,0);}
    }
  for (int i = 0; i < toGen; i++){
    if (curBoids >= numBoidstoGen) break;
    pos[curBoids] = new Vec2(200+random(200),-200+random(100));
    vel[curBoids] = new Vec2(-1+random(2),-1+random(2));
    if ((curBoids >=0 && curBoids <10) & (pressFollow == 1)) {
      dir[curBoids] = new Vec2((mouseX - pos[i].x), (mouseY - pos[i].y));  //Should be vector pointing from pos to MousePos
      if (dir[curBoids].length() > 0) dir[curBoids].normalize();
      vel[curBoids] = dir[curBoids].times(maxSpeed);
      pos[curBoids].add(vel[curBoids]);
      vel[curBoids].normalize();
      vel[curBoids].mul(maxSpeed/4);
  
    }
    curBoids += 1;
  }
  
  
}
  

void drawFish (int i){
  float size =randomSize[i];
  PVector velAux = new PVector (vel[i].x, vel[i].y);
  float theta = velAux.heading() + radians(90);
  pushMatrix();
  translate(pos[i].x, pos[i].y);
  rotate(theta);
  fill(255, 217, 0);
  beginShape(TRIANGLES);
  vertex(0, 7*size);
  vertex(-11*size, 23*size);
  vertex(11*size, 23*size);
  endShape();
  fill(0, 217, 75);
  beginShape(TRIANGLES);
  vertex(0, -3*size);
  vertex(-16*size, 16*size);
  vertex(16*size, 16*size);
  endShape();
  fill(0, 0, 0);
  ellipse (1*size, 5*size, 3*size, 3*size);
  popMatrix();
  pos[i].add(vel[i].times(dt)); 
}

void draw(){
  update(1.0/frameRate);
  
  background(bg); //Ocean background
  
  for (int i = 0; i < curBoids; i++) drawFish(i);
  //Used to turn the features on/off
  for (int i = 0; i < curBoids; i++){
    if (pressSep == 1) vel[i] = vel[i].plus(separation(i).times(0.05));
    if (pressCoh == 1) vel[i] = vel[i].plus(coheision(i).times(4));
    if (pressAli == 1) vel[i] = vel[i].plus(allignment(i).times(3));
    
  }
  for (int i = 0; i < curBoids; i++){
  Vec2 targetVel = vel[i];
  targetVel.setToLength(targetSpeed);
  Vec2 goalSpeedForce = targetVel.minus(vel[i]);
  goalSpeedForce.times(1);
  goalSpeedForce.clampToLength(maxForce);    
  }
   
  for (int i = 0; i < curBoids; i++){
    //Update Position 
    pos[i] = pos[i].plus(vel[i].times(dt));
    //Max speed
    if (vel[i].length() > maxSpeed){
      vel[i] = vel[i].normalized().times(maxSpeed);
    }
    
    // Loop the world if agents fall off the edge
    if (pos[i].x < 0) pos[i].x += width;
    if (pos[i].x > width) pos[i].x -= width;
    if (pos[i].y < 0) pos[i].y += height;
    if (pos[i].y > height) pos[i].y-= height;
  }

}

Vec2 separation (int i){
  Vec2 curVel = new Vec2 (0, 0);
  float neighDist = 40;
  for  (int j = 0; j < curBoids; j++){ //Go through neighbors
    float dist = pos[i].distanceTo(pos[j]);
    if ((dist > 0) && (dist < neighDist)) {
      curVel =  curVel.plus(pos[i].minus(pos[j]));}}
   return curVel;
}
      
Vec2 allignment (int i){
  float neighDist = 50;
  Vec2 avgVel = new Vec2(0,0);
  Vec2 curVel = new Vec2(0,0);

    for  (int j = 0; j <  curBoids; j++){ //Go through neighbors
      float dist = pos[i].minus(pos[j]).length();
      if (dist < neighDist && dist > 0){
        curVel = vel[j];
        curVel.normalize();
        avgVel.add(curVel);
      }
    }
  return avgVel;
}

Vec2 coheision (int i){
  float neighDist = 15;
  Vec2 avgPos = new Vec2(0,0); 
  Vec2 newPos = new Vec2(0,0);
  int count = 0;
  for  (int j = 0; j < curBoids; j++){
    float dist = pos[i].distanceTo(pos[j]);
    if ((dist > 0) && (dist < neighDist)) {
      avgPos.add(pos[j]); 
      count++;
    }
  }
    if (count > 0) {
      avgPos.mul(1.0/count);
      newPos = avgPos.minus(pos[i]);
      newPos.setToLength(0.01);
    }
   return newPos;
}

//Generate new boid when you press the mouse
void mousePressed(){
  pos[curBoids] = new Vec2(mouseX,mouseY);
  vel[curBoids] = new Vec2(-1+random(2),-1+random(2));  
  vel[curBoids-1].normalize();
  vel[curBoids-1].mul(targetSpeed);
  curBoids++;
}


void keyPressed(){
  if (key == 's'){
    pressSep = 0;
    println("Separation off");
  }
  if (key == 'S'){
    pressSep = 1;
    println("Separation on");
  }
  if (key == 'a'){
    pressAli = 0;
    println("Allgnment off");
  }
  if (key == 'A'){
    pressAli = 1;
    println("Allgnment on");
  }
  if (key == 'c'){
    pressCoh = 0;
    println("Coheision off");
  }
  if (key == 'C'){
    pressCoh = 0;
    println("Coheision on");
  }
  if (key == 'f'){
    pressFollow = 0;
    println("Follow mouse on");
  }
  if (key == 'F'){
    pressFollow = 1;
    println("Follow mouse off");
  }
  if (key == 'd'){
    if (targetSpeed *2 <= maxSpeed){
      targetSpeed *= 2;
      println("Doubling fish speed");
    }
    else println("Maximum speed reached");
  }
  if (key == 'h'){
    targetSpeed /= 2;
    println("Halving fish speed");
  }
}