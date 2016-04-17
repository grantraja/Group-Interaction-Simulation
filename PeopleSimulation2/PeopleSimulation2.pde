//sets the size of the stage
int sizeX = 800;
int sizeY = 800;
int GAP = 20;
boolean go = false;
int pSpace = 25; //Personal Space
float pSpeed = 0.6; //Personal Speed
int wThreshold = 40; //Distance from wall required to be effected by boundaries
int pop = 20; // number of initial people
int pReflex = 5;
int pWidth = 20;
int lineSight = 150;
int wallSight = 50;
int debugger = 0;
int debugger2 = 0;
int mouseUse = 0;
String mouseTools[] = {"debug","debug 2","spawn"};
//creates a central list of people
ArrayList<Person> people;
//this creates a new instance of the object person
void spawn(boolean rand, int X, int Y) {
  if(rand){
    Person e = new Person(round(random(GAP, sizeX-GAP)), round(random(GAP, sizeY-GAP)));
    //Person e = new Person(300,300);
    people.add(e);  
  } else {
    Person e = new Person(X,Y);
    people.add(e);
  }
}
//this simply runs spawn multiple times, I made it a separate function so that the setup up is cleaner
void spawnMulti(int num) {
  for (int i = 0; i<num; i++) {
    spawn(true,0,0);
  }
}
//THIS IS THE FUNCTION THAT COMPARES TWO DIFFERENT PEOPLE TO GET THEIR LEVEL OF ATTRACTION ARGUABLY THE MOST IMPORTANT
float relation(int me, int other) {
  boolean myValue = people.get(me).blue;
  boolean otherValue = people.get(other).blue;
  boolean debug = people.get(me).debug;
  float attraction = 0;
  if (myValue) {
    if (otherValue) {
      attraction = 1;
    }
    else {
      attraction = 0-1;    
    }
  } 
  else {
    if (otherValue) {
      attraction = 0-1;
    }
    else {
      attraction = 1;  
    }
  }
  //debugging
  if (debug){
    if (attraction >= 0){
      stroke(255, 0, 0);
      line(people.get(me).X, people.get(me).Y, people.get(other).X, people.get(other).Y); 
    } else {
      stroke(0, 0, 255);
      line(people.get(me).X, people.get(me).Y, people.get(other).X, people.get(other).Y); 
    }
  }
  //final result
  return attraction;
}

//this is the meat of the program, this is the definition for the person object, it contains 4 sections
//the first section is a definitions section that estabilishes all the universal variables for each person
class Person {
  private float X;
  private float Y;
  private int adress;
  private int R;
  private int G;
  private int B;
  private int atract;
  private int attractions;
  private int repulsions;
  private boolean blue = false;
  private boolean debug = false;
  private boolean debug2 = false;
  private float significance = 0;
  private PVector personalMomentum, push, netForce, buffer;
  //this is the initialization, here is where each person recieves the input on what position they are in
  //then they randomize their traits, for now the only traits are color and attractiveness.
  Person(int posX, int posY) {
    adress = people.size();
    println(adress);
    X = posX;
    Y = posY;
    R = round(random(0, 255));
    G = round(random(0, 255));
    B = round(random(0, 255));
    atract = round(random(0, 255));
    if (round(random(0, 1))==1) {
      blue = true;
    }
    push = new PVector(0, 0);
    netForce = new PVector(0, 0);
    personalMomentum = new PVector(random((0-1), 1), random((0-1), 1));
    //personalMomentum.set(0-1,0);
    personalMomentum.setMag(pSpeed);
    buffer = new PVector(0, 0);
  }
  void debugData(){
    fill(0,0,0);
    text(adress,50,50); text(X,100,50); text(Y,200,50);
    text(attractions,50,60);
    text(repulsions,50,70);
    text(buffer.x,50,80);
    text(buffer.y,50,90);
    text(personalMomentum.x,50,100);
    text(personalMomentum.y,50,110);
  }  
  //this simply puts the person on the screen
  void display() {
    stroke(0, 0, 0);
    fill(R, G, B);
    ellipse(round(X), round(Y), pWidth, pWidth); 
    if (blue) {
      fill(0, 0, 255);
    } 
    else {
      fill(255, 0, 0);
    }
    //fill(atract,0,255-atract);
    ellipse(round(X), round(Y), (pWidth/2), (pWidth/2));
    stroke(0, 0, 0);
    float lineX = X+(personalMomentum.x*50);
    float lineY = Y+(personalMomentum.y*50);
    line(X, Y, lineX, lineY);
    if (debug){
      stroke(0,0,0);
      noFill();
      ellipse(round(X), round(Y), lineSight*2, lineSight*2);
      debugData();
    }
    if (debug2){
      noFill();
      stroke(0,0,0);
      rect((round(X)-(pWidth/2)),(round(Y)-(pWidth/2)),pWidth,pWidth);
    }
  }
  void localAttraction() {
    attractions = 0;
    repulsions = 0;
    for (int i=0;i<people.size();i++) {
      if(i!=adress){
      float oX = people.get(i).X;
      float oY = people.get(i).Y;
      //Push = myloc - people(i).loc;
      push.set(oX-X, oY-Y);
      if (push.mag()<= lineSight && push.mag()>pSpace) {
        float pull = relation(adress, i);
        significance = (1+(0-(1/(lineSight-pSpace))*push.mag())+((1/(lineSight-pSpace)*pSpace)));
        push.setMag(pReflex*pull);
        //push.setMag(pReflex*pull*significance);
        //
        push.setMag(abs(pull));
        if (pull<0) {
          repulsions++;
          push.x = push.x*(1);
          push.y = push.y*(1);
        } else {
          attractions++;
        }
        //
        float nX=netForce.x;
        float nY=netForce.y;
        netForce.set(nX+push.x, nY+push.y);
        netForce.setMag(pSpeed/pReflex);
        if(debug){
          if(i==debugger2){
            text(significance,675,75);
          }
        }
      }
    }
    }
    personalMomentum.add(netForce);
    personalMomentum.setMag(pSpeed);
  }
  void walls() {
    int GAP = 12;
    if ((X+personalMomentum.x+GAP)>=sizeX) {
      personalMomentum.x = sizeX - (X+GAP);
    }
    if ((Y+personalMomentum.y+GAP)>=sizeY) {
      personalMomentum.y = sizeY - (Y+GAP);
    }
    if ((X+personalMomentum.x)<=GAP) {
      personalMomentum.x = GAP - X;
    }  
    if ((Y+personalMomentum.y)<=GAP) {
      personalMomentum.y = GAP - Y;
    }
  }
  void wallPush() {
    if (X<wallSight) {
      buffer.set((pSpeed-(X*(pSpeed/wallSight))), 0);
      //line(X,Y,buffer.x*10,buffer.y*10); 
      personalMomentum.add(buffer);
    }
    if (Y<wallSight) {
      buffer.set(0, (pSpeed-(Y*(pSpeed/wallSight)))); 
      personalMomentum.add(buffer);
    }
    if (X>(sizeX-wallSight)) {
      float bufX = abs(X-sizeX);
      buffer.set((pSpeed-(bufX*(pSpeed/wallSight))), 0); 
      personalMomentum.sub(buffer);
    }    
    if (Y>(sizeY-wallSight)) {
      float bufY = abs(Y-sizeY);
      buffer.set((pSpeed-(bufY*(pSpeed/wallSight))), 0); 
      personalMomentum.sub(buffer);
    }
    //personalMomentum.setMag(pSpeed);
  }
  void move() {
    localAttraction();
    //wallPush();
    walls();
    X = X+personalMomentum.x;
    Y = Y+personalMomentum.y;
  }
}
void display() {
  for (int i=0;i<people.size();i++) {
    people.get(i).display();
  }
  text(mouseTools[mouseUse],700,30);
}
void move() {
  for (int i=0;i<people.size();i++) {
    people.get(i).move();
  }
}
void setup() { 
  people = new ArrayList();
  size(sizeX, sizeY);
  spawnMulti(pop);
  display();
}
void mousePressed() {
  if(mouseUse == 0){
    for (int i=0;i<people.size();i++) {
      if(dist(mouseX, mouseY, people.get(i).X, people.get(i).Y)<pWidth){
        people.get(debugger).debug = false;
        debugger = i;
        people.get(i).debug = true;
        return;
      }
    }
  } else if(mouseUse == 1){
    for (int i=0;i<people.size();i++) {
      if(dist(mouseX, mouseY, people.get(i).X, people.get(i).Y)<pWidth){
        people.get(debugger2).debug2 = false;
        debugger2 = i;
        people.get(i).debug2 = true;
        return;
      }
    }  }else if (mouseUse == 2){
    spawn(false, mouseX, mouseY);
  }  
}
void keyPressed(){
  if (key == 'p'){
     go = !go;
  }
  if(key == 's'){
    background(255, 255, 255);  
    move();
    display();
    noFill();
    rect(wallSight, wallSight, (sizeX-(2*wallSight)), (sizeY-(2*wallSight)));
  }
  if (key == 'o'){
    mouseUse++;
    if(mouseUse > 2){
      mouseUse = 0;
    }
  }
}
void draw() {
  background(255, 255, 255);  
  if (go) {
    move();
  }
  if(debugger != debugger2){
    float X = people.get(debugger).X;
    float Y = people.get(debugger).Y;
    float oX = people.get(debugger2).X;
    float oY = people.get(debugger2).Y;
    text(debugger2,600,50);
    text(oX,650,50);
    text(oY,700,50);
    text(dist(X,Y,oX,oY),675,65);
    //text(people.get(debugger).significance,675,75);
    //text(people.get(debugger2).significance,675,75);    
  }
  display();  
  noFill();
  rect(wallSight, wallSight, (sizeX-(2*wallSight)), (sizeY-(2*wallSight)));
}

