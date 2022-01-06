//Christian Lee
//Mason Lopez
//Mathew Yee
//AP Computer Science Principles
//Game

import ddf.minim.*;
import ddf.minim.effects.*;
Minim minim;
AudioPlayer bruh;
AudioPlayer dude;
int loopcount;
int gameScreen = 0;
Tank tank = new Tank();
ArrayList<Invader> invaders = new ArrayList<Invader>();
boolean shooting = false;
int score = 0;
int highScore = 0;
  
  
void setup() {
    background(0);
    fullScreen(P2D);
    for (float j = 0; j < 10; j++) {
      for (float i = 0; i < 2*PI; i+= 2*PI/25) {
        invaders.add(new Invader(new PVector((250+50*j)*cos(i), (250+50*j)*sin(i)), i, j%2==0));
      }
    }
    minim = new Minim(this);
    bruh = minim.loadFile("bruh.mp3", 2048);
    dude = minim.loadFile("edm.mp3", 2048);
  }
  
void draw() {
    if (gameScreen == 0) {
    initScreen();
  } else if (gameScreen == 1) {
    gameScreen();
    }
  }
  
//Initial Screen(Click to start)  
void initScreen() {
  background(0, 0, 0);
  textAlign(CENTER);
  fill(#EA078C);
  textSize(50);
  text("CLICK TO START", 1000, 550);
}

//When mouse is pressed it starts the game  
public void mousePressed() {
  if (gameScreen==0) {
    startGame();
  }
  dude.loop(); //Plays sound once the mouse is clicked
}

//Increases gameScreen value by 1, starting the game
void startGame(){
  gameScreen = 1;
}

//Screen when the mouse is clicked and the game starts
void gameScreen() {
  background(0); 
    for (int i=invaders.size()-1; i>-1; i--) {
      invaders.get(i).update(); 
      invaders.get(i).show();
      for (Bullet b : invaders.get(i).bullets) {
        if (tank.hit(b))
          reset();
      }
      for (int j=tank.bullets.size()-1; j>-1; j--) {
        if (invaders.get(i).hit(tank.bullets.get(j))) {
          invaders.remove(i);
          tank.bullets.remove(j);
          score += 100;
        }
      }
    }
    //Calls functions of objects
    tank.update(); 
    tank.show();
    showPlanet();
    HUD();
}

//Resets the game once the character is hit
void reset() {
    invaders = new ArrayList<Invader>();
    tank = new Tank();
    score = 0;
    for (float j = 0; j < 10; j++) {
      for (float i = 0; i < 2*PI; i+= 2*PI/25) {
        invaders.add(new Invader(new PVector((150+50*j)*cos(i), (150+50*j)*sin(i)), i, j%2==0));
      }
    }
  }
  
//Planet in the middle  
void showPlanet() {
    pushMatrix();
    translate(width/2, height/2);
    fill(#0087DE);
    stroke(10, 90, 10);
    ellipse(0, 0, 205, 205);
    popMatrix();
  }
 
//Codes for instructions and the score
void HUD() {
    textAlign(CENTER);
    textSize(20);
    fill(255, 255, 255);
    text("A AND D TO MOVE\nSPACE TO SHOOT", width/2, height/2-10);
  
    textAlign(LEFT);
    text("Score : " + nf(score, 6, 0), 20, 20);
    if (score > highScore) {
      highScore = score;
    }
    textAlign(RIGHT);
    text("High Score : " + nf(highScore, 6, 0), width - 20, 20);
  }
  
//Spawns new invaders  
void newInvaders() {
    float mag = invaders.get(invaders.size()-1).pos.mag();
    if (mag < 300) {
      for (float i = 0; i < 2*PI; i+= 2*PI/25) {
        invaders.add(new Invader(new PVector(mag*cos(i), mag*sin(i)), i, !invaders.get(invaders.size()-1).movingClockwise));
      }
    }
  }
  
//Determines behaviors of bullets coming from both the player and the invaders
class Bullet{
    PVector pos,dir;
    float angle;
    boolean hit;
    
    Bullet(PVector pos0, PVector dir0, float a){
      pos = pos0.copy();
      dir = dir0;
      angle = a;
      hit = false;
    }
    
//Appearance of the bullets    
void show(){
      pushMatrix();
      translate(width/2,height/2);
      rotate(angle);
      fill(#7F06D1);
      stroke(#45E302);
      ellipse(pos.x-5,pos.y-5, 10, 10);
      popMatrix(); 
      
    }
    
void update(){
     pos.add(dir);    
    }
  }
  
//Determines how invaders move
class Invader{
    PVector pos;
    float angle;
    boolean movingClockwise = false;
    ArrayList<Bullet> bullets = new ArrayList<Bullet>();
    
    Invader(PVector p0, float a, boolean clock){
      movingClockwise = clock;
      angle = a;
      pos = p0.copy();
    }
    
//Determines where invader bullets will spawn
void shoot(){
      if(random(1) < 0.0005){
        PVector bPos = pos.copy();
        PVector bDir = pos.copy().mult(-1).setMag(2);
        bullets.add(new Bullet(bPos, bDir, angle));
      
      }
    }
    
//Determines appearance of invaders
void show(){
      pushMatrix();
      translate(width/2,height/2);
      rotate(angle);
      fill(#EA078C);
      stroke(#CE8A02);
      ellipseMode(CENTER);
      rect(pos.x, pos.y, 20, 20);
      popMatrix();
    }
//Determines speed of invader bullets
void update(){
       shoot();
       if(movingClockwise){
         angle-=0.015;       
       } else {
         angle +=0.015; 
       }
      
      if(frameCount%600 == 0){
        movingClockwise = !movingClockwise;
        pos.setMag(pos.mag()-10);
      }
      
      if(bullets != null){
       for(int i = bullets.size()-1; i>-1; i--){
        bullets.get(i).update();
        bullets.get(i).show();
        if(bullets.get(i).pos.mag() < 100){
         bullets.remove(i); 
        }
       }
       println(bullets.size());
      }
    }
    
    boolean hit(Bullet b){
     if(PVector.dist(b.pos.copy().rotate(b.angle),pos.copy().rotate(angle))<20){
       return true;
     }
     return false;
       
      
    }
  }

//Appearance of character(tank)
class Tank {
    PVector pos = new PVector(0, -100);
    float angle = 0;
    boolean moving = false;
    boolean movingClockwise = false;
    ArrayList<Bullet> bullets = new ArrayList<Bullet>();
    Tank() {
    }

//Tank shape
void show() {
      pushMatrix();
      translate(width/2, height/2);
      rotate(angle);
      fill(#DE0021);
      noStroke(); 
      beginShape();
      vertex(pos.x-20, pos.y);
      vertex(pos.x-20, pos.y-10);
      vertex(pos.x-10, pos.y-10);
      vertex(pos.x-10, pos.y-20);
      vertex(pos.x+10, pos.y-20);
      vertex(pos.x+10, pos.y-10);
      vertex(pos.x+20, pos.y-10);
      vertex(pos.x+20, pos.y); 
  
      endShape(CLOSE);   
      popMatrix();
    }
    boolean hit(Bullet b) {
      if (PVector.dist(b.pos.copy().rotate(b.angle), pos.copy().rotate(angle))<20) {
        return true;
      }
      return false;
    }
    
//Determines speed of the invaders    
void update() {
      if (moving) {
        if (movingClockwise) {
          angle+=0.05;
        } else {
          angle -=0.05;
        }
      }  
      if (bullets != null) {
        for (int i = bullets.size()-1; i>-1; i--) {
          bullets.get(i).update();
          bullets.get(i).show();
          if (bullets.get(i).pos.mag() > width) {
            bullets.remove(i);
          }
        }
        println(bullets.size());
      }
    }
  }

//Tank will move counterclockwise or clockwise with keys a and d
void keyPressed(){
   if(key == 'a'){
    tank.moving = true;
    tank.movingClockwise = false; 
   }
    if(key == 'd'){
    tank.moving = true;
    tank.movingClockwise = true; 
   }  
   if(key == 'A'){
    tank.moving = true;
    tank.movingClockwise = false; 
   }
    if(key == 'D'){
    tank.moving = true;
    tank.movingClockwise = true; 
   }  
   if(key == ' '){
    if(!shooting){ 
    tank.bullets.add(new Bullet(tank.pos, new PVector(0,-10),tank.angle));
    shooting = !shooting;
    bruh.loop();
    }
   } 
  }
  
//Tank will stop moving once a or d is released
void keyReleased(){
   if(key == 'a'){
    tank.moving = false;
   }
   if(key == 'd'){
    tank.moving = false;
   } 
   if(key == 'A'){
    tank.moving = false;
   }
   if(key == 'D'){
    tank.moving = false;
   } 
   if(key == ' '){
    shooting = !shooting;
    }
  }
