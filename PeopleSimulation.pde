//sets the size of the stage
int sizeX = 400;
int sizeY = 400;
int GAP = 20;
int pSpace = 25; //Personal Space
float pSpeed = 0.4; //Personal Speed
int wThreshold = 40; //Distance from wall required to be effected by boundaries
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
//this is the meat of the program, this is the definition for the person object, it contains 4 sections
//the first section is a definitions section that estabilishes all the universal variables for each person
class Person{
  float X;
  float Y;
  int R;
  int G;
  int B;
  int att;
  PVector direc, mome;
//this is the initialization, here is where each person recieves the input on what position they are in
//then they randomize their traits, for now the only traits are color and attractiveness.
  Person(int posX, int posY){
    X = posX;
    Y = posY;
    R = round(random(0,255));
    G = round(random(0,255));
    B = round(random(0,255));
    att = round(random(0,255));
    direc = new PVector(0,0);
  }  
  //this simply puts the person on the screen
  void display(){
    fill(R,G,B);
    fill(att,att,att);
    ellipse(round(X),round(Y),20,20); 
  }
  void move(){
  //This cycles through all the possible people inorder to check their qualities.
    for(int i=0;i<people.size();i++){
      float oX = people.get(i).X;
      float oY = people.get(i).Y;
      int oatt = people.get(i).att;
      float mg = 5-pow((dist(X,Y,oX,oY)/20),3);
      if(mg<0){mg=0.1;}
      mome = new PVector(0,0);
      if(oatt > 125 && att > 125){
        if(dist(X,Y,oX,oY)<pSpace){
          mome.set(X-oX,Y-oY);
        }else{
          mome.set(oX-X,oY-Y);
        }
      }else if(oatt < 125 && att < 125){
        if(dist(X,Y,oX,oY)<pSpace){
          mome.set(X-oX,Y-oY);
        }else{
          mome.set(oX-X,oY-Y);
        }      
      }else{
        mome.set(X-oX,Y-oY);        
      }
      println(mg);
      mome.setMag(5/(mg));
      direc.add(mome);
      //From here establish attraction in the form of a vector
      //Add to movement vector
    }
    direc.setMag(pSpeed);
    dist
    X = X+direc.x;
    Y = Y+direc.y;
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
int distW(int wid, int position){
  int prop = 0;
  int dis = (wid/2)-abs((wid/2) - position);
  if(dis<50){
    prop = 1.1-(x(1.1/50));
  }
  return prop;
}
void setup(){ 
  people = new ArrayList();
  size(sizeX,sizeY);
  spawnMulti(10);
  display();
}
void draw(){
  display();
  move();
}
