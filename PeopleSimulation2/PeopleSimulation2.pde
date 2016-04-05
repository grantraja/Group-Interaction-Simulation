//


//sets the size of the stage
int sizeX = 800;
int sizeY = 800;
int GAP = 20;
boolean go = false;
int pSpace = 25; //Personal Space
float pSpeed = 0.6; //Personal Speed
int wThreshold = 40; //Distance from wall required to be effected by boundaries
int pop = 50; // number of initial people
int pReflex = 10;
int lineSight = 300;
//creates a central list of people
ArrayList<Person> people;
//this creates a new instance of the object person at a random location and adds them to the list
void spawn(){
  Person e = new Person(round(random(GAP,sizeX-GAP)), round(random(GAP,sizeY-GAP)));
  people.add(e); 
}
//this simply runs spawn multiple times, I made it a separate function so that the setup up is cleaner
void spawnMulti(int num){
  for(int i = 0; i<num; i++){
    spawn();
  }
}
//THIS IS THE FUNCTION THAT COMPARES TWO DIFFERENT PEOPLE TO GET THEIR LEVEL OF ATTRACTION ARGUABLY THE MOST IMPORTANT
float relation(int me, int other){
  int myValue = people.get(me).atract;
  int otherValue = people.get(other).atract;
  float attraction = 0;
  if(myValue<= 127){
    if(otherValue<= 127){
      //we're both blue
        atract = 1;
    } else {
      //I'm Blue and You're red
      attract = 0-1;
    }    
  } else {
    if(otherValue<= 127){
      //I'm red and You're blue
      attract = 1;
    } else {
      //we're both red
      attract = 0-1;
    }     
  }
  return attraction
}

//this is the meat of the program, this is the definition for the person object, it contains 4 sections
//the first section is a definitions section that estabilishes all the universal variables for each person
class Person{
  float X;
  float Y;
  int adress;
  int R;
  int G;
  int B;
  int atract;
  PVector personalMomentum, push, netForce;
//this is the initialization, here is where each person recieves the input on what position they are in
//then they randomize their traits, for now the only traits are color and attractiveness.
  Person(int posX, int posY){
    adress = people.size()+1;
    X = posX;
    Y = posY;
    R = round(random(0,255));
    G = round(random(0,255));
    B = round(random(0,255));
    atract = round(random(0,255));
    push = new PVector(0,0);
    netForce = new PVector(0,0);
    personalMomentum = new PVector(random(0,1),random(0,1));
    personalMomentum.setMag(pSpeed);
  }  
  //this simply puts the person on the screen
  void display(){
    fill(R,G,B);
    ellipse(round(X),round(Y),20,20); 
    fill(att,0,255-att);
    ellipse(round(X),round(Y),10,10); 
  }
  void localAttraction(){
    for(int i=0;i<people.size();i++){
      float oX = people.get(i).X;
      float oY = people.get(i).Y;
      push.set(X-oX,Y-oY);
      if(push.mag()<= lineSight){
        pull = relation(adress,i);
        push.setMag(pReflex*pull);
        nX=netForce.x;
        nY=netForce.y;
        netForce.set(nX+push.x, nY+push.y);
      }
    }
    personalMomentum.add(netForce);
    personalMomentum.setMag(pSpeed);  
  }
  void WALLS(){ //OUT DATED
    float bufferX = 0;
    float bufferY = 0;
    if(X>(sizeX-wThreshold)){
       
    }
    if(X<wThreshold){
      bufferX = (pSpeed-(X*(pSpeed/wThreshold)));
      println(bufferX);
    }
    if(Y>(sizeY-wThreshold)){
      //bufferY = (pSpeed-((wThreshold-(Y-(Y-wThreshold )))*(pSpeed/wThreshold)));  
    }
    if(Y<wThreshold){
      bufferY = (pSpeed-(Y*(pSpeed/wThreshold)));     
      println(bufferY);
    }
    bufferX = move.x+bufferX;
    bufferY = move.y+bufferY;
    direc.setMag(pSpeed/pReflex);
    move.add(direc);//for momentum change to add;
    move.setMag(pSpeed);
    move.set(bufferX,bufferY);  
  }
  void move(){
    localAttraction();
    WALLS();
    X = X+personalMomentum.x;
    Y = Y+personalMomentum.y;
  }
}
void display(){
  background(255,255,255);  
  for(int i=0;i<people.size();i++){
    people.get(i).display();
  }
}
void move(){
  for(int i=0;i<people.size();i++){
    people.get(i).move();
  }
}
void setup(){ 
  people = new ArrayList();
  size(sizeX,sizeY);
  spawnMulti(pop);
  display();
}
void mousePressed(){
  go = true;
}
void draw(){
  display();
  if(go){
    move();
  }
}
