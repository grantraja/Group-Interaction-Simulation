//inputs
int pop = 100; // number of people in the simulation
int sizeX = 800; // the width of the Room
int sizeY = 800; // the length of the Room
int pReflex = 10; // how quickly people react to each other
int pWidth = 20; // the diameter of an average person
int lineSight = 150; //the distance an average person can see
int wallSight = 50;  //how far from the wall a person must be before they try to return to the center of the room
int spawnBuffer = 20; // how close to the walls people can spawn
float centerPullMag = 0.05; // how attracted each person is to the center
float pSpeed = 0.6; //how many pixels each person travels per step


//internal variables
int pSpace = pWidth+5; //Personal Space
ArrayList<Person> people;


//debugging variables
int debugger = 0;
int debugger2 = 0;
int mouseUse = 0;
boolean go = false;
String mouseTools[] = {
  "debug", "debug 2"
};



//this is the meat of the program, this is the definition for the person object, it contains 4 sections
//the first section is a definitions section that estabilishes all the universal variables for each person
class Person {
  private float X;
  private float Y;
  private int adress;
  private int R;
  private int G;
  private int B;
  private int attractions;
  private int repulsions;
  private int [] qualities = new int [10];
  private int [] status = new int [3];
  private boolean debug = false;
  private boolean debug2 = false;
  private float significance = 0;
  private PVector personalMomentum, push, netForce, buffer;
  private ArrayList <relationship> relations;
  Person(int posX, int posY) {
    X = posX;
    Y = posY;
    adress = people.size();    
    R = round(random(0, 255));
    G = round(random(0, 255));
    B = round(random(0, 255));
    push = new PVector(0, 0);
    netForce = new PVector(0, 0);
    personalMomentum = new PVector(random((0-1), 1), random((0-1), 1));
    personalMomentum.setMag(pSpeed);
    buffer = new PVector(0, 0);
    relations = new ArrayList();
    for (int i = 0; i<pop; i++) {
      relationship e = new relationship(adress, i, random(-0.5, 1));
      relations.add(e);
    }
  }
  void dispDebugData() {
    if (debug) {
      blackText(adress, 50, 50); 
      text(X, 100, 50); 
      text(Y, 200, 50);
      text(attractions, 50, 60);
      text(repulsions, 50, 70);
      text(buffer.x, 50, 80);
      text(buffer.y, 50, 90);
      text(personalMomentum.x, 50, 100);
      text(personalMomentum.y, 50, 110);
      stroke(0, 0, 0);
      noFill();
      ellipse(round(X), round(Y), lineSight*2, lineSight*2);
    }
    if (debug2) {
      noFill();
      stroke(0, 0, 0);
      rect((round(X)-(pWidth/2)), (round(Y)-(pWidth/2)), pWidth, pWidth);
      float oX = people.get(debugger2).X;
      float oY = people.get(debugger2).Y;
      blackText(debugger2, 600, 50);
      text(oX, 650, 50);
      text(oY, 700, 50);
      text(dist(X, Y, oX, oY), 675, 65);
    }
  }  
  //this simply puts the person on the screen
  void display() {
    stroke(0, 0, 0);
    fill(R, G, B);
    ellipse(round(X), round(Y), pWidth, pWidth); 
    stroke(0, 0, 0);
    float lineX = X+(personalMomentum.x*50);
    float lineY = Y+(personalMomentum.y*50);
    line(X, Y, lineX, lineY);
    dispDebugData();
  }
  void localAttraction() {
    attractions = 0;
    repulsions = 0;
    for (int i=0;i<people.size();i++) {
      if (i!=adress) {
        float oX = people.get(i).X;
        float oY = people.get(i).Y;
        //Push = myloc - people(i).loc;
        push.set(oX-X, oY-Y);
        significance = 1-((push.mag()-pSpace)/(lineSight-pSpace));
        if (push.mag()<= lineSight && push.mag()>pSpace) {
          float pull = relations.get(i).totalValue;
          if (debug) {
            if (pull >= 0) {
              stroke(255, 0, 0);
              line(people.get(adress).X, people.get(adress).Y, people.get(i).X, people.get(i).Y);
            } 
            else {
              stroke(0, 0, 255);
              line(people.get(adress).X, people.get(adress).Y, people.get(i).X, people.get(i).Y);
            }
          }
          significance = (1+(0-(1/(lineSight-pSpace))*push.mag())+((1/(lineSight-pSpace)*pSpace)));
          push.setMag(pReflex*pull*significance);
          //push.setMag(pReflex*pull*significance);
          //
          push.setMag(abs(pull));
          if (pull<0) {
            repulsions++;
            push.x = push.x*(1);
            push.y = push.y*(1);
          } 
          else {
            attractions++;
          }
          //
          float nX=netForce.x;
          float nY=netForce.y;
          netForce.set(nX+push.x, nY+push.y);
          netForce.setMag(pSpeed/pReflex);
          if (debug) {
            if (i==debugger2) {
              text(significance, 675, 75);
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
  void centerPull(){
    buffer.set(X-(sizeX/2),Y-(sizeY/2));
    buffer.setMag(centerPullMag);
    personalMomentum.sub(buffer);
  }
  void move() {
    localAttraction();
    //wallPush();
    walls();
    centerPull();
    X = X+personalMomentum.x;
    Y = Y+personalMomentum.y;
  }
}


void display() {
  for (int i=0;i<people.size();i++) {
    people.get(i).display();
  }
}


void move() {
  for (int i=0;i<people.size();i++) {
    people.get(i).move();
  }
}
class relationship {
  float totalValue = 0;
  int me = 0;
  int other = 0;
  relationship(int myadress, int otheradress, float input) {
    me = myadress;
    other = otheradress;
    totalValue = input;
  }
}


//this creates a new instance of the object person
void spawn(int X, int Y) {
  Person e = new Person(round(random(spawnBuffer, sizeX-spawnBuffer)), round(random(spawnBuffer, sizeY-spawnBuffer)));
  people.add(e);
}
void spawnMulti(int num) {
  for (int i = 0; i<num; i++) {
    spawn(0, 0);
  }
}
void blackText(int text, int posX, int posY){
  fill(0,0,0);
  text(text, posX, posY);
}


void mousePressed() {
  if (mouseUse == 0) {
    for (int i=0;i<people.size();i++) {
      if (dist(mouseX, mouseY, people.get(i).X, people.get(i).Y)<pWidth) {
        people.get(debugger).debug = false;
        debugger = i;
        people.get(i).debug = true;
        return;
      }
    }
  } 
  else if (mouseUse == 1) {
    for (int i=0;i<people.size();i++) {
      if (dist(mouseX, mouseY, people.get(i).X, people.get(i).Y)<pWidth) {
        people.get(debugger2).debug2 = false;
        debugger2 = i;
        people.get(i).debug2 = true;
        return;
      }
    }
  }
}
void keyPressed() {
  if (key == 'p') {
    go = !go;
  } 
  else if (key == 'l') {
    background(255, 255, 255);  
    move();
    display();
    noFill();
    rect(wallSight, wallSight, (sizeX-(2*wallSight)), (sizeY-(2*wallSight)));
  } 
  else  if (key == 'o') {
    mouseUse++;
    if (mouseUse > 1) {
      mouseUse = 0;
    }
  }
}


void setup() { 
  people = new ArrayList();
  size(sizeX, sizeY);
  spawnMulti(pop);
}
void draw() {
  background(255, 255, 255);  
  if (go) {
    move();
  }
  display();  
  fill(0,0,0);
  text(mouseTools[mouseUse], 700, 30);
  noFill();
  rect(wallSight, wallSight, (sizeX-(2*wallSight)), (sizeY-(2*wallSight)));
}

