//       Galaga-Style Game
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
*
* Controls:
* Arrows or A/D to move left/right
*
*/

//Player Data
Player player;

//Enemies Data
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
float enemySpeed = 0.3;
ArrayList<Segment> segments = new ArrayList<Segment>(); //only used for Centipedes

void setup()
{
  size(1200,750);
  imageMode(CENTER);
  rectMode(CENTER);
  
  player = new Player();
  
  spawnTestWave();
}

void draw()
{
  background(0);
  
  for( Enemy e: enemies )
    e.moveAndDraw();
  
  player.moveAndDraw();
  
  text( segments.size(), 100,100);
}

void keyPressed()
{
  if( key == 'a' || keyCode == LEFT )
    player.movingLeft = true;
  if( key == 'd' || keyCode == RIGHT )
    player.movingRight = true;
}

void keyReleased()
{
  if( key == 'a' || keyCode == LEFT )
    player.movingLeft = false;
  if( key == 'd' || keyCode == RIGHT )
    player.movingRight = false;
}

void spawnTestWave()
{
  for( int i = 0; i < 1; i++ )
    enemies.add( new Enemy(4,i,10) );
}

//*********************** PLAYER ***********************//
//This class will contain the data for the player's ship//
class Player extends MovingThing
{
  //Changes based on key presses/releases
  boolean movingLeft, movingRight;
  
  //Image for player's ship
  PImage playerImage;
  
  public Player()
  {
    xPos = width/2;
    yPos = height-100;
    acceleration = 0.5;
    size = 50;
  }
  
  public void moveAndDraw()
  {
    //Accelerate
    if(movingLeft)  xSpd -= acceleration;
    if(movingRight) xSpd += acceleration;
    
    move();
    applyFriction( 5 );
    
    //Draw
    circle(xPos,yPos,size); //temporary
    //image(playerImage,xPos,yPos);
  }
}

//*********************** Enemy ************************//
//This class will contain the data for the enemies.     //
//Enemies will come in three types:
// 1 - Straight down the scren
// 2 - Swoop in from left or right
// 3 - Heavy segmented blaster
class Enemy extends MovingThing
{
  int type; //this will determine appearance and behavior
  float swoopAngle; //only used for swoopers
  
  public Enemy( int t, int sequence, int groupSize )
  {
    type = t;
    setTraitsByType( sequence, groupSize );
  }
  
  public void moveAndDraw()
  {
    //Straight flying enemies
    if( type == 1 ) ySpd += acceleration;
    
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
      if( yPos < 0 ) ySpd += acceleration;// else ySpd -= acceleration;
      if( xPos < player.xPos ) xSpd += acceleration; else xSpd -= acceleration;
      for( Segment s: segments ) s.chase();
    }
    
    move();
    applyFriction(5);
    
    wrap();
    
    //Draw segments for centipedes
    for( Segment s: segments )
      s.drawSegment();
    
    //Draw (TEMP COLORS)
    if( type == 1 ) fill(0,0,200);
    if( type == 2 || type == 3 ) fill(0,200,0);
    if( type == 4 ) fill(200,0,0);
    circle(xPos,yPos,size);
  }
  
  //Enemies will "wrap" around the screen - easier than formations
  private void wrap()
  {
    if( type == 4 ) return; //ends the funciton early or centipedes
    
    if     ( ySpd > 0 && yPos > height+size ) yPos = -height;
    else if( xSpd > 0 && xPos > width+size  ) xPos = -width;
    else if( xSpd < 0 && xPos < 0           ) xPos = width*2;
  }
  
  private void setTraitsByType( int current, int max )
  {
    switch( type )
    {
      case 1: //Fly straight forward
        xPos = width / (max+1) * (current+1);
        xSpd = 0;
        yPos = -height;
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
        segments.add( new Segment(this,max-1) );
      break;
    }
  }
}

//****************************SEGMENT***************************//
//This is a simple class used to track the segments of the      //
//centipede. Each one will chase the one ahead of it.           //
//Each will be 10% smaller than its parent, and when the        //
//centipede takes damage it will destroy the smallest child.    //
class Segment extends MovingThing
{
  int explodeTimer; //for explosion animation
  MovingThing parent; //since Segments and Enemies are both MovingThings, this can track either one
  
  public Segment( MovingThing p, int max )
  {
    parent = p;
    xPos = p.xPos;
    yPos = p.yPos;
    acceleration = p.acceleration;
    size = p.size*0.95;
    if( max > 0 )
      segments.add( new Segment( this, max-1 ) );
  }
  
  public void chase()
  {
    if( parent.xPos > xPos ) xSpd += acceleration;
    if( parent.xPos < xPos ) xSpd -= acceleration;
    if( parent.yPos > yPos ) ySpd += acceleration;
    if( parent.yPos < yPos ) ySpd -= acceleration;
    
    move();
    applyFriction(5);
  }
  
  public void drawSegment()
  {
    fill(100);
    noStroke();
    circle(xPos,yPos,size);
    stroke(200,0,0);
    strokeWeight(size*.75);
    line(xPos,yPos,parent.xPos,parent.yPos);
    noStroke();
  }
}

//************************MOVING THING**************************//
//This is an ABSTRACT CLASS. It cannot be used to create objects//
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
}
