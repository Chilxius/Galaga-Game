//       Galaga-Style Game        \\
/***********************************
*                                  *
* This game is meant to evoke the  * 
* classic arcade game Galaga. The  *
* player controls a fighter at the *
* bottom of the screen, and shoots *
* down waves of enemies that       *
* approach from the top            *
*                                  *
************************************
*                                  *
* All the classes are here in one  *
* file, but could be moved into    *  
* different tabs.                  *
*                                  *
************************************
*                                  *
* Controls:                        *
* Arrows or A/D to move left/right *
* Z or space to shoot basic shots  *
*                                  *
***********************************/

//Player Data
Player player;

//Enemies Data
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
float enemySpeed = 0.3;
ArrayList<Segment> segments = new ArrayList<Segment>(); //only used for Centipedes

//Projectile Data
ArrayList<Shot> shots = new ArrayList<Shot>();
ArrayList<Missile> missiles = new ArrayList<Missile>();

//Wave Data
int waveSize = 10;  //Size of first wave
float nextFighter = 1000; //must be float to divide correctly
int waveStraights = waveSize, waveSwoops = waveSize; //number of straight/swooping fighters per wave
boolean waveFinished;

//Image Data
PImage enemyPics[] = new PImage[4];

//Background Data
int starCount = 10;
float [][][] starPos = new float[3][2][starCount];

void setup()
{
  size(1200,750);
  imageMode(CENTER);
  rectMode(CENTER);
  
  player = new Player();
  
  loadImages();
  letThereBeLight();
  
  //spawnTestWave();
}

void draw()
{
  drawBackground();
  
  launchWaves();
  
  handleEnemies();
  
  handlePlayer();
  
  handleShots();
  
  cleanUp();
}

void keyPressed()
{
  //Movement
  if( key == 'a' || key == 'A' || keyCode == LEFT )
    player.movingLeft = true;
  if( key == 'd' || key == 'D' || keyCode == RIGHT )
    player.movingRight = true;
    
  //Attacks
  if( key == ' ' || key == 'z' || key == 'Z' )
    player.shooting = true;
    
  //TESTING
  if( key == 'm' )
    missiles.add( new Missile( enemies.get(0), player ) );
}

void keyReleased()
{
  if( key == 'a' || keyCode == LEFT )
    player.movingLeft = false;
  if( key == 'd' || keyCode == RIGHT )
    player.movingRight = false;
  if( key == ' ' || key == 'z' || key == 'Z' )
    player.shooting = false;
}

//Draws starry sky
void drawBackground()
{
  background(0);
  
  //Draw stars in different "layers", with
  //closer stars being bigger and faster
  fill(255,255,150);
  for( int i = 0; i < starCount; i++ )
  {
    //Closest stars
    circle(starPos[0][0][i],starPos[0][1][i],3);
    starPos[0][1][i]+=1.2;
    //Middle stars
    circle(starPos[1][0][i],starPos[1][1][i],2);
    starPos[1][1][i]+=0.8;
    //Farthest stars
    circle(starPos[2][0][i],starPos[2][1][i],1);
    starPos[2][1][i]+=0.5;
    
    //Reset stars
    for( int j = 0; j < 3; j++ )
      if( starPos[j][1][i] > height+3 )
      {
        starPos[j][0][i] = random(width);
        starPos[j][1][i] = -3;
      }
  }
}

//Deal with player and HUD
void handlePlayer()
{
  player.moveAndDraw();
  player.drawHUD();
}

//Deal with enemies
void handleEnemies()
{
  for( Enemy e: enemies )
    e.moveAndDraw();
}

//Deal with shots, friendly and dangerous
void handleShots()
{
  for( Shot s: shots )
  {
    //Move, check if moved off screen
    if( s.moveAndDraw() )
      s.takeDamage();
    
    //Check for enemy hits
    for( Enemy e: enemies )
      if( s.friendly && !e.exploding && s.touched(e) )
      {
        e.takeDamage();
        s.takeDamage();
      }
      
    //Check for segment hits
    if( s.friendly && segments.size() > 0 && segments.get(0).touched(s) )
    {
      s.takeDamage();
      segments.get(0).takeDamage();
    }
      
    //Check for player hits
    if( !s.friendly && s.touched(player) )
    {
      if( player.shielded )
        s.reflect();
      else
        s.takeDamage();
      player.takeDamage();
    }
  }
  
  for( Missile m: missiles )
    m.moveAndDraw();
}

//Remove items from lists when done
void cleanUp()
{
  for( int i = 0; i < enemies.size(); i++ )
    if( enemies.get(i).markedForRemoval )
      enemies.remove(i);
      
  for( int i = 0; i < segments.size(); i++ )
    if( segments.get(i).markedForRemoval )
      segments.remove(i);
      
  for( int i = 0; i < shots.size(); i++ )
    if( shots.get(i).markedForRemoval )
      shots.remove(i);
}

//Creates enemies for each wave
void launchWaves()
{
  if( !waveFinished && millis() > nextFighter )
  {
    nextFighter = millis()+10000/waveSize;
    if( waveStraights > 0 )
    {
      if( waveSize % 2 == 0 )
        enemies.add( new Enemy( 1, waveStraights-1, waveSize ) );
      else
        enemies.add( new Enemy( 1, waveSize-waveStraights, waveSize ) );
      waveStraights--;
    }
    if( waveSwoops > 0 )
    {
      //Left
      if( waveSize % 5 > 2 )
        enemies.add( new Enemy( 2, waveSwoops, waveSize ) );
      //Right
      else if( waveSize % 5 > 0 )
        enemies.add( new Enemy( 3, waveSwoops, waveSize ) );
      //Alternate
      else
      {
        if( waveSwoops%2==0 )
          enemies.add( new Enemy( 2, waveSwoops, waveSize) );
        else
          enemies.add( new Enemy( 3, waveSwoops, waveSize) );
      }
      waveSwoops--;
    }
    else
    {
      if( waveSize % 5 == 0 ) //centipedes on multiples of 5
        enemies.add( new Enemy( 4, 0, waveSize ) );
      waveFinished = true;
    }
  }
  if( waveFinished && enemies.size() == 0 )
  {
    waveSize++;
    waveStraights = waveSize;
    waveSwoops = waveSize;
    waveFinished = false;
  }
}
  
public void loadImages()
{
  enemyPics[0] = loadImage("cobra.png");   enemyPics[0].resize(50,0);
  enemyPics[1] = loadImage("jaguar.png");  enemyPics[1].resize(100,0);
  enemyPics[2] = loadImage("sparrow.png"); enemyPics[2].resize(50,0);
  enemyPics[3] = loadImage("jaguar.png");  enemyPics[3].resize(30,0);
}

//Creates the stars
public void letThereBeLight()
{
  //Array level 1: layers of stars, for a parallax effect
  //Array level 2: x or y position of star
  //Array level 3: value of that position
  //Ex: starPos[1][1][40] -> the 41st y position in the second layer
  for( int i = 0; i < starPos.length; i++ )
    for( int j = 0; j < starPos[0][0].length; j++ )
    {
      starPos[i][0][j] = random(width);
      starPos[i][1][j] = random(height);
    }
}

//*********************** PLAYER ***********************//
//This class will contain the data for the player's ship//

class Player extends MovingThing
{
  //Changes based on key presses/releases
  boolean movingLeft, movingRight;
  boolean shooting;
  
  //Image for player's ship
  PImage playerImage;
  
  //Ship data
  boolean shielded = true;
  int armor = 3;   //ship's "health"
  int damageDelay; //invulnerability frames
  
  //Weapon data
  int nextShot; //when next shot can fire
  int shotDelay; //time between shots
  int shotFork = 1; //how many shots per shot
  
  public Player()
  {
    xPos = width/2;
    yPos = height-100;
    acceleration = 0.5;
    size = 50;
    
    shotDelay = 500;
    
    playerImage = loadImage("sparrow.png");
    playerImage.resize(50,0);
  }
  
  public void moveAndDraw()
  {
    //Attempt to shoot
    if(shooting && millis() > nextShot )
    {
      nextShot = millis() + shotDelay;
      if( shotFork == 1 )
        shots.add( new Shot( player, true ) );
      else if( shotFork == 2 )
      {
        shots.add( new Shot( player, true ) ); shots.get(shots.size()-1).xPos+=15;
        shots.add( new Shot( player, true ) ); shots.get(shots.size()-1).xPos-=15;
      }
      else if( shotFork == 3 )
      {
        shots.add( new Shot( player, true ) ); shots.get(shots.size()-1).xPos+=15; shots.get(shots.size()-1).xSpd=1;
        shots.add( new Shot( player, true ) );
        shots.add( new Shot( player, true ) ); shots.get(shots.size()-1).xPos-=15; shots.get(shots.size()-1).xSpd=-1;
      }
    }
      
    //Accelerate
    if(movingLeft)  xSpd -= acceleration;
    if(movingRight) xSpd += acceleration;
    
    move();
    applyFriction( 5 );
    
    //Draw
    fill(200);
    circle(xPos,yPos,size); //temporary
    //image(playerImage,xPos,yPos);
    
    //Shield
    if( shielded )
    {
      fill(0,0,200,50); noStroke();
      for(int i = 0; i < 6; i++)
        circle(xPos,yPos, 50+(i*7));
    }
  }
  
  //Called when hit by an enemy shot
  public void takeDamage()
  {
    if( shielded )
      shielded = false;
    else
    {
      armor--;
      if( armor <= 0 )
        exploding = true;
    }
  }
  
  //Draws Heads-Up Display
  public void drawHUD()
  {
    //draw score
    
    //Draw Armor
    fill(200);
    for( int i = 0; i < armor; i++ )
      circle( 50+50*i, 50, 45 );
  }
}


//*********************** Shot ************************//
//This class will contain the data for player and enemy//
//shots.

class Shot extends MovingThing
{
  boolean friendly;
  
  public Shot( MovingThing shooter, boolean f )
  {
    xPos = shooter.xPos;
    yPos = shooter.yPos;
    size = 10;
    
    //Determine if shot is "friendly"
    friendly = f;
    if( friendly )
      ySpd = -15;
    else
      ySpd = shooter.acceleration*20;
  }
  
  //Making this a boolean method allows me to
  //check if it needs to be removed after moving
  public boolean moveAndDraw()
  {
    //Move
    xPos += xSpd;
    yPos += ySpd;
    
    //Check if shot is off screen
    if( yPos > height+size*3 || yPos < -size*3 )
      return true;
    
    //Draw
    fill(255,255,0);
    ellipse(xPos,yPos,size,size*3);
    
    return false;
  }
  
  //Shots are removed after taking damage
  public void takeDamage()
  {
    markedForRemoval = true;
  }
  
  //Shot becomes friendly and reverses direction
  public void reflect()
  {
    friendly = !friendly;
    ySpd = -ySpd*2;
    if( player.xPos < xPos ) xSpd=1;
    else                     xSpd=-1;
  }
}


//*********************** Enemy ************************//
//  This class will contain the data for the enemies.   //
//  Enemies will come in three types:
//    1  - Straight down the scren
//   2/3 - Swoop in from left/right
//    4  - Heavy segmented blaster

class Enemy extends MovingThing
{
  int type; //this will determine appearance and behavior
  float swoopAngle; //only used for swoopers
  
  float rotation;
  
  int nextShot;
  
  public Enemy( int t, int sequence, int groupSize )
  {
    type = t;
    setTraitsByType( sequence, groupSize );
    
    nextShot = millis() + int(random(6000));
  }
  
  public void moveAndDraw()
  {
    if( exploding )
    {
      drawExplosion();
      return;
    }
    
    //Straight flying enemies
    if( type == 1 ) ySpd += acceleration/3;
    
    //Swooping enemies
    if( type == 2 || type == 3 )
    {
      ySpd += acceleration;
      if( type == 2 ) xSpd += acceleration;
      if( type == 3 ) xSpd -= acceleration;
      if( yPos > 0 )  swoopAngle+= acceleration/100;
      ySpd -= swoopAngle;
    }
    
    //Centipedes
    if( type == 4 )
    {
      if( yPos < 0 ) ySpd += acceleration;
      if( xPos < player.xPos ) xSpd += acceleration; else xSpd -= acceleration;
      for( Segment s: segments ) s.chase();
    }
    
    move();
    applyFriction(5);
    
    wrap();
    
    //Charge up shot
    if( millis() >= nextShot )
    {
      nextShot = millis()+3000;
      if( type != 4 )
        shots.add( new Shot( this, false ) );
      if( type == 4 )
      {
        missiles.add( new Missile( this, player ) );
        for( int i = 0; i < segments.size(); i+=5 )
          missiles.add( new Missile( segments.get(i), player ) );
      }
    }
    
    //Draw segments for centipedes
    for( int i = 0; i < segments.size(); i++ )
      if( i == 0 )
        segments.get(i).drawSegment(true);
      else
        segments.get(i).drawSegment(false);
    
    //Draw (TEMP COLORS)
    if( type == 1 ) image( enemyPics[0], xPos, yPos );
    if( type == 2 || type == 3 ) image( enemyPics[2], xPos, yPos );
    if( type == 4 )
    {
      push();
      translate(xPos,yPos);
      rotation = atan2( player.yPos-yPos, player.xPos-xPos );
      rotate(rotation-HALF_PI);
      image( enemyPics[1], 0, 0 );
      pop();
    }
    
    //Flicker yellow if about to shoot    
    if( nextShot - millis() < 1000 && millis() % 100 < 50 )
    {
      fill( 255,255,0,75 ); //flicker if about to shoot
      //circle(xPos,yPos,size);
      for( int i = 0; i < 10; i++ )
        arc( xPos,yPos,size,size, HALF_PI-(0.2+i*0.1),HALF_PI+(0.2+i*0.1), OPEN );
    }
  }
  
  //Centipedes lose segments first
  public void takeDamage()
  {
    //if( type == 4 && segments.size()>0 )
    //{
    //  for( Segment s: segments )
    //    if( !s.exploding )
    //    {
    //      s.exploding = true;
    //      return;
    //    }
    //}
    if( type != 4 || segments.size() == 0 )
      exploding = true;
  }
  
  //Enemies will "wrap" around the screen - easier than formations
  private void wrap()
  {
    if( type == 4 ) return; //ends the funciton early for centipedes
    
    if     ( ySpd > 0 && yPos > height+size ) yPos = -height;
    else if( xSpd > 0 && xPos > width+size  ) { xPos = yPos = -height; ySpd=xSpd=swoopAngle=0; }
    else if( xSpd < 0 && xPos < 0           ) { xPos = width+height; yPos = -height; ySpd=xSpd=swoopAngle=0; }
  }
  
  private void setTraitsByType( int current, int max )
  {
    switch( type )
    {
      case 1: //Fly straight forward
        xPos = width / (max+1) * ( current+1);
        xSpd = 0;
        yPos = -height/3;
        ySpd = 3;
        acceleration = enemySpeed;
        size = 50;
      break;
      
      case 2: //Swooper, from left
        xPos = -height;
        xSpd = enemySpeed;        
        yPos = -height;
        ySpd = enemySpeed;
        acceleration = enemySpeed;
        size = 50;
      break;
      
      case 3: //Swooper, from right
        xPos = width+height;
        xSpd = -enemySpeed;
        yPos = -height;
        ySpd = enemySpeed;
        acceleration = enemySpeed;
        size = 50;
      break;
      
      case 4: //Centipede
        xPos = width/2;
        xSpd = 0;
        yPos = -height;
        ySpd = 0;
        acceleration = enemySpeed*0.75;
        size = 100;
        //Instead of adding more enemies for a larger wave, adds
        //more segments to the "tail"
        segments.add( new Segment(this, max-1) );
      break;
    }
  }
}


//*********************** SEGMENT **************************//
//This is a simple class used to track the segments of the  //
//centipede. Each one will chase the one ahead of it.       //
//Each will be 10% smaller than its parent, and when the    //
//centipede takes damage it will destroy the smallest child.//

class Segment extends MovingThing
{
  MovingThing parent; //since Segments and Enemies are both MovingThings, this can track either one
  
  public Segment( MovingThing p, int max )
  {
    parent = p;
    xPos = p.xPos;
    yPos = p.yPos;
    acceleration = p.acceleration;
    size = p.size*0.95;
    
    //Will continue to generate segments until max gets to 0
    if( max > 0 )
      segments.add( new Segment( this, max-1 ) );
  }
  
  public void chase()
  {
    if(exploding)
    {
      drawExplosion();
      return;  
    }
    
    //Causes segment to follow parent segment
    if( parent.xPos > xPos ) xSpd += acceleration;
    if( parent.xPos < xPos ) xSpd -= acceleration;
    if( parent.yPos > yPos ) ySpd += acceleration;
    if( parent.yPos < yPos ) ySpd -= acceleration;
    
    move();
    
    //Keeps the segments from separating
    while( parent.xPos > xPos+size/2 ) xPos++;
    while( parent.xPos < xPos-size/2 ) xPos--;
    while( parent.yPos > yPos+size/2 ) yPos++;
    while( parent.yPos < yPos-size/2 ) yPos--;
    
    applyFriction(10);
  }
  
  public void drawSegment( boolean last )
  {
    if(exploding) return;
    
    fill(100);
    if( last ) fill(200,0,0);
    //noStroke();
    circle(xPos,yPos,size);
  }
  
  public void takeDamage()
  {
    exploding = true;
  }
}

//*********************** MISSILE **************************//
//This will control the seeker missiles. Each missile will  //
//be given a target when created, and will only register a  //
//hit against that target. They will seek only for a short  //
//while, not forever.                                       //

class Missile extends MovingThing
{
  MovingThing target;
  float rotation;
  int seekTime;
  
  public Missile( MovingThing origin, MovingThing t )
  {
    target = t;
    xPos = origin.xPos;
    yPos = origin.yPos;
    acceleration = 0.1;
    seekTime = waveSize*10;
  }
  
  public void moveAndDraw()
  {
    move();
    if(seekTime > 0)
    {
      if( target.xPos > xPos ) xSpd += acceleration;
      if( target.xPos < xPos ) xSpd -= acceleration;
      if( target.yPos > yPos ) ySpd += acceleration;
      if( target.yPos < yPos ) ySpd -= acceleration;

      seekTime--;
    }
    
    
    rotation = atan2( target.yPos-yPos, target.xPos-xPos ) - HALF_PI;
    push();
    translate(xPos,yPos);
    rotate(rotation);
    image( enemyPics[3], 0, 0 );
    pop();
  }
}

//*********************** MOVING THING *************************//
//This is an ABSTRACT CLASS. It can't be used to create objects.//
//Its purpose is to be inherited by other classes. Since so many//
//of the objects in this program will be moving objects that use//
//xPosition and yPosition, I have decided to inherit these and  //
//other traits instead of re-writing them for every object that //
//moves.                                                        //

abstract class MovingThing
{
  float xPos, yPos;
  float xSpd, ySpd;
  float acceleration;
  float size;
  
  //For when it gets blown up
  boolean exploding;
  int explosionTimer = 150;
  
  //For when the item should be removed from the list
  boolean markedForRemoval;
  
  //Change position by current speed
  protected void move()
  {
    xPos += xSpd;
    yPos += ySpd;
  }
  
  //Reduce speeds by reduction%
  protected void applyFriction( float reduction )
  {
    xSpd *= ( 1 - reduction/100 );
    ySpd *= ( 1 - reduction/100 );
  }
  
  //Return true if two MovingThings make contact
  protected boolean touched( MovingThing m )
  {
    return dist( xPos, yPos, m.xPos, m.yPos ) < (size+m.size)/2;
  }
  
  //This method is for destroyed objects that explode.
  //It will mark those objects for removal when the explosion ends
  protected void drawExplosion()
  {
    fill(200,0,0,explosionTimer); //Fade out as timer runs out
    circle( xPos, yPos, 300-(explosionTimer*2) ); //Grow as timer runs out
    
    explosionTimer -= 3;
    
    if( explosionTimer <= 0 )
      markedForRemoval = true;
  }
  
  
  public void takeDamage()
  {
    println("METHOD NOT DEFINED");
  }
}
