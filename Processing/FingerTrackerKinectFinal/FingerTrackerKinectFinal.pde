/* Purpose: Detect the shape and motion of the user hand, and 
 *  get the robot hand to mimic it. This program acounts for small
 *  translations, but not rotations. 
 * Paired with Arduino Program FingerTrackerKinect
 * Created by: Jonathan Hernandez and Ayat Amin
 * Date: 03/17/2016
 */

// import the fingertracker library
import fingertracker.*;
import KinectPV2.*;
import processing.serial.*;

// declare FignerTracker objects
FingerTracker fingers;
KinectPV2 kinect;
Serial myPort;
// set a default threshold distance:
// 625 corresponds to about 2-3 feet from the Kinect
//55 cm to 60 cm is the sweet spot
int threshold = 625;
boolean calibrated = false; //used once. set to true once recorded initial position of fingers
PVector[] fingerInitialPosition = new PVector[5];  //is updated only when there is finger translation
PVector[] newPos = new PVector[5]; //constantly being updated. currently location of fingers
PVector refPoint;// reference point for whole hand. X value = middle finger's x, y value = thumb's y
PVector curr;//temp value to transition between curr fingers
int[] diff = { 0, 0, 0, 0, 0 }; //stores difference between finger position and ref point
boolean[] flexed = { false, false, false, false, false }; //false if finger is extend. true when finger is flexed. Ie- no point is within the finger box
boolean giving_the_bird = true; //boolean to keep hand from flipping people off

void setup() {
  size(1024, 848);
  //good: 512, 424 for fingers
  
  // initialize the kinect
  // and set it up to access the depth image
  kinect = new KinectPV2(this);
  kinect.enableDepthImg(true);

  // initialize the FingerTracker object
  // with the height and width of the Kinect depth image
  fingers = new FingerTracker(this, 512, 424);
  
  //Declare serial port for communicating with Arduino
  String portName = Serial.list()[0];
  myPort = new Serial(this , portName, 9600);
  
  // the "melt factor" smooths out the contour
  // making the finger tracking more robust
  // especially at short distances
  // farther away you may want a lower number
  fingers.setMeltFactor(100);
  kinect.init();
}

void draw() {

  scale( 2 ); //set scale to 2 when code is faster
  
  // get a depth image and display it
  PImage depthImage = kinect.getDepthImage();
  image(depthImage, 0, 0); //display depth data

  // update the depth threshold beyond which
  // we'll look for fingers
  fingers.setThreshold(threshold);
  
  // access the "depth map" from the Kinect
  // this is an array of ints with the full-resolution
  // depth data (i.e. 500-2047 instead of 0-255)
  // pass that data to our FingerTracker
  int[] depthMap = kinect.getRawDepthData();
  fingers.update(depthMap);

  //
  calibrate();
  
  // iterate over all the fingers found
  // and draw them as a red circle
  noStroke();
  fill(255,0,0);
  for (int i = 0; i < fingers.getNumFingers(); i++) {
    PVector position = fingers.getFinger(i);
    if ( isWithinBorder( position ) ) {
      ellipse(position.x - 5, position.y -5, 10, 10);
    }
  }
  
  // border the user is allowed to play in
  stroke( 255, 0, 0 );
  line( 128, 106, 384, 106 );
  line( 128, 106, 128, 318 );
  line( 384, 106, 384, 318 );
  line( 128, 318, 384, 318 );

  // Thumb box
  if ( fingerInitialPosition[0] != null ) {
    line(fingerInitialPosition[0].x - 30, fingerInitialPosition[0].y - 25, fingerInitialPosition[0].x + 30, fingerInitialPosition[0].y - 25);
    line(fingerInitialPosition[0].x - 30, fingerInitialPosition[0].y - 25, fingerInitialPosition[0].x - 30, fingerInitialPosition[0].y + 25);
    line(fingerInitialPosition[0].x - 30, fingerInitialPosition[0].y + 25, fingerInitialPosition[0].x + 30, fingerInitialPosition[0].y + 25);
    line(fingerInitialPosition[0].x + 30, fingerInitialPosition[0].y - 25, fingerInitialPosition[0].x + 30, fingerInitialPosition[0].y + 25);
  }
  
  stroke( 0, 0, 255 );
  
  if ( fingerInitialPosition[1] != null ) {
    line(fingerInitialPosition[1].x - 10, fingerInitialPosition[1].y - 50, fingerInitialPosition[1].x + 10, fingerInitialPosition[1].y - 50);
    line(fingerInitialPosition[1].x - 10, fingerInitialPosition[1].y - 50, fingerInitialPosition[1].x - 10, fingerInitialPosition[1].y + 50);
    line(fingerInitialPosition[1].x - 10, fingerInitialPosition[1].y + 50, fingerInitialPosition[1].x + 10, fingerInitialPosition[1].y + 50);
    line(fingerInitialPosition[1].x + 10, fingerInitialPosition[1].y - 50, fingerInitialPosition[1].x + 10, fingerInitialPosition[1].y + 50);
  }
  
  stroke( 255, 0, 0 );
  
  if ( fingerInitialPosition[2] != null ) {
    line(fingerInitialPosition[2].x - 11, fingerInitialPosition[2].y - 50, fingerInitialPosition[2].x + 11, fingerInitialPosition[2].y - 50);
    line(fingerInitialPosition[2].x - 11, fingerInitialPosition[2].y - 50, fingerInitialPosition[2].x - 11, fingerInitialPosition[2].y + 50);
    line(fingerInitialPosition[2].x - 11, fingerInitialPosition[2].y + 50, fingerInitialPosition[2].x + 11, fingerInitialPosition[2].y + 50);
    line(fingerInitialPosition[2].x + 11, fingerInitialPosition[2].y - 50, fingerInitialPosition[2].x + 11, fingerInitialPosition[2].y + 50);
  }
  
  stroke( 0, 0, 255 );
  
  if ( fingerInitialPosition[3] != null ) {
    line(fingerInitialPosition[3].x - 10, fingerInitialPosition[3].y - 40, fingerInitialPosition[3].x + 10, fingerInitialPosition[3].y - 40);
    line(fingerInitialPosition[3].x - 10, fingerInitialPosition[3].y - 40, fingerInitialPosition[3].x - 10, fingerInitialPosition[3].y + 40);
    line(fingerInitialPosition[3].x - 10, fingerInitialPosition[3].y + 40, fingerInitialPosition[3].x + 10, fingerInitialPosition[3].y + 40);
    line(fingerInitialPosition[3].x + 10, fingerInitialPosition[3].y - 40, fingerInitialPosition[3].x + 10, fingerInitialPosition[3].y + 40);
  }
  
  stroke( 255, 0, 0 );
  
  if ( fingerInitialPosition[4] != null ) {
    
    float m = -1 * (refPoint.y + 11.0 - fingerInitialPosition[4].y)/100.0;
    int x0 = (int)fingerInitialPosition[4].x - 10;
    
    int x =(int)(m * (refPoint.y + 11 - fingerInitialPosition[4].y) + x0);
    
    line(fingerInitialPosition[4].x - 10, fingerInitialPosition[4].y - 10, fingerInitialPosition[4].x + 20, fingerInitialPosition[4].y - 10);
    line(fingerInitialPosition[4].x - 10, fingerInitialPosition[4].y - 10, x, refPoint.y + 1);
    line(x, refPoint.y + 1, fingerInitialPosition[4].x + 20, refPoint.y + 1);
    line(fingerInitialPosition[4].x + 20, fingerInitialPosition[4].y - 10, fingerInitialPosition[4].x + 20, refPoint.y + 1);
  }
  
  // Useful for following the refpoint
  if ( refPoint != null ) {
    stroke( 255, 0, 0 );
    line( refPoint.x, 0, refPoint.x, 423 );
    line( 0, refPoint.y, 511, refPoint.y );
    /*noStroke();
    fill( 0, 0, 255 );
    for ( int i = 0; i < fingerInitialPosition.length; i++ ) {
      ellipse( fingerInitialPosition[i].x, fingerInitialPosition[i].y, 10, 10);
    }*/
  }
  if ( calibrated ) {
    sendData();    
  }
  // show the threshold on the screen
  /*fill(255,0,0);
  text(threshold, 10, 20);  */ 
}

void sendData() {
  //String data = "";
  if ( (flexed[0] && (flexed[1] || ( !flexed[1] && diff[1] < 7 ) ) && !flexed[2] && flexed[3] &&
       flexed[4]) || 
       (flexed[0] && (flexed[1] || ( !flexed[1] && diff[1] < 7 ) ) && !flexed[2] && 
       (flexed[3] || ( !flexed[3] && diff[3] < 7 ) ) && flexed[4]) ) { 
    giving_the_bird = true; 
    print("I present the bird!");
  }
  else {
    giving_the_bird = false;
  }
  for ( int i = 0; i < flexed.length; i++ ) {
    if ( flexed[ i ] ) {
      if ( i == 1 && giving_the_bird ) {
        //data = data + "A";
        myPort.write('A');
      } else {
        //data = data + "Z";
        myPort.write('Z');
      }
    } else if ( diff[i] >= 26 ) {
      //data = data + "A";
      myPort.write('A');
    } else {
      //data = data + (char)('Z' -  diff[i]);
      if ( i == 1 && giving_the_bird ) {
        //data = data + "A";
        myPort.write('A');
      } else {
        myPort.write((char)('Z' -  diff[i]));
      }
    } 
  }
  //println(data);
}

// keyPressed event:
// pressing the '-' key lowers the threshold by 10
// pressing the '+/=' key increases it by 10 
void keyPressed(){
  if(key == '-'){
    threshold -= 10;
  }
  
  if(key == '='){
    threshold += 10;
  }
  
}

boolean isWithinBorder( PVector p ) {
  if ( p.x > 128 && p.x < 384 &&
       p.y > 106 && p.y < 318 ) {
    return true;
  }
  return false;
}

int getActualFingerCount() {
  int numFingers = 0;
  for(int i = 0; i< fingers.getNumFingers(); i++){    
    if ( isWithinBorder( fingers.getFinger(i) ) ) {
      numFingers++;
    }
  }
  return numFingers;
}

//Purpose: To set values for PVector array for Initial Finger Position once
//         & constantly updated PVector array newPos for current finger position
//         calls function calls GetCurrFingerPos
void calibrate() {  
  // First Calibration
  if( !calibrated && getActualFingerCount() == 5 ){
    //Get all the 5 finger locations
    if ( GetCurrFingerPos( fingerInitialPosition ) ) {
      println( "First calibration complete." );
    }        
    refPoint = new PVector(fingerInitialPosition[2].x, fingerInitialPosition[0].y);
    calibrated = true;
  }//end of if(numOfFingers == 5)
  // All Other calibrations
  else if ( calibrated ) {
    GetCurrFingerPos( newPos );
  }
}

//Purpose: Determine if a finger is missing. 
//         returns true if finger is missing
boolean FingerIsMissing( int i, int uFingers ) {
  
  boolean result = true; //assume finger is there
  //i reference what box to look at.  0 = thumb ... 4 = pinky
  //uFingers is num of fingers detected
  
  // Edge Case: 0 - hand is flexed. all fingers are missing
  // Edge Case: 5 - hand is flat. all fingers are present
  if ( uFingers == 0 ) {
    return true;
  } else if ( uFingers == 5 ) {
    return false;
  }
  
  //See if curr finger position is present in a box size.
  //Different sizes for different fingers.
  //Note- Pinky is a trapezoid, not a rectangle
  switch ( i ) {
    case 0: //thumb
      //look through all the possible fingers
      //see if they are located within current box
      for (int j = 0; j < uFingers && j < 5; j++) {
        if ( newPos[j] != null && abs(fingerInitialPosition[0].x - newPos[j].x) < 30 &&
             abs(fingerInitialPosition[0].y - newPos[j].y) < 25 ) {
          result = false;
          break;
        }
      }
      break;
    case 1: //index
      for (int j = 0; j < uFingers && j < 5; j++) {
        if ( newPos[j] != null && abs(fingerInitialPosition[1].x - newPos[j].x) < 11 &&
             abs(fingerInitialPosition[1].y - newPos[j].y) < 50 ) {
          result = false;
          break;
        }
      }
      break;
    case 2: //middle
      for (int j = 0; j < uFingers && j < 5; j++) {
        if ( newPos[j] != null && abs(fingerInitialPosition[2].x - newPos[j].x) < 10 &&
             abs(fingerInitialPosition[2].y - newPos[j].y) < 50 ) {
          result = false;
          break;
        }
      }
      break; 
    case 3: //ring
      for (int j = 0; j < uFingers && j < 5; j++) {
        if ( newPos[j] != null && abs(fingerInitialPosition[3].x - newPos[j].x) < 10 &&
             abs(fingerInitialPosition[3].y - newPos[j].y) < 40 ) {
          result = false;
          break;
        }
      }
      break;
    case 4: //pinky
      // trapezoid, not a rectangle
      for (int j = 0; j < uFingers && j < 5; j++) {
        float m = -1 * (refPoint.y + 11.0 - fingerInitialPosition[4].y)/100.0;
        int x0 = (int)fingerInitialPosition[4].x - 10;
        int x =(int)(m * (newPos[j].y + 11 - fingerInitialPosition[4].y) + x0);
        if ( newPos[j] != null && newPos[j].y >= fingerInitialPosition[4].y - 10 &&
             newPos[j].y <= refPoint.y + 1 && newPos[j].x <= fingerInitialPosition[4].x + 20 &&
             newPos[j].x >= x) {
          result = false;
          break;
        }
      }
      break;
  }
  return result;
}


//Purpose: Constantly get the current finger position
//         returns boolean if entire array is sorted
boolean GetCurrFingerPos( PVector[] vec ) {
  int userFingers = getActualFingerCount();
  int numFinger = 0;
  //loop through all dots detected inside border. stop when reach 5 fingers
  for ( int i = 0; i < fingers.getNumFingers() && numFinger < 5; i++ ) {
    PVector currFinger = fingers.getFinger(i);
    if ( isWithinBorder( currFinger ) ) {
      vec[numFinger] = currFinger;
      numFinger++;
    }
  }
  
  //when a finger is flexed, fill the values with null
  if ( userFingers != 5 ) {
    for (int i = userFingers; i < vec.length; i++ ) {
      vec[ i ] = null;
    }
  }
  
  //Sort the fingers. thumb is most left, pinky is most right
  boolean sorted = Sort( vec );
  
  //Determines whether there is a finger within each box
  for ( int i = 0; i < flexed.length; i++ ) {
    flexed[ i ] = FingerIsMissing( i, userFingers );
  }
  
  CalcDiff();    
  
  return sorted;
}

boolean adjustRefX( float x , int j) {
  //j is the current finger we are calling the function from
  //x is current x position of finger
  
  //calculate change in x
  float dx = x - fingerInitialPosition[j].x; 
   
  //shift all the fingers when there is a change
  for (int i = 0; i < fingerInitialPosition.length; i++) {
    fingerInitialPosition[i].x += dx;
  }
  
  //set new value for ref
  refPoint.x = fingerInitialPosition[2].x;
  return true;
}

boolean adjustRefY( float y , int j) {
  //j is the current finger we are calling the function from
  //y is current y position of finger

  //calculate shift in y
  float dy = y - fingerInitialPosition[j].y;

  //shift all the fingers when there is a change
  for (int i = 0; i < fingerInitialPosition.length; i++) {
      fingerInitialPosition[i].y += dy;
  }
  
  //set new value for ref
  refPoint.y = fingerInitialPosition[0].y;
  return true;
}

//Purpose: To determine how flexed a finger is
void CalcDiff() {
  int difference = 0; //assume finger is not flexed
  int numFlexed = 0; //assume 0 fingers are flexed
  
  //thumb
  if ( flexed[0] ) { 
    println("THUMB missing...");
    numFlexed++;
  } //determine how flexed the thumb is
  //for thumb, difference is along x axis. rest is along y
  else if ( newPos[0] != null ) {
    curr = newPos[0];
    
    //store the diference
    difference = (int)abs( refPoint.x - curr.x - 25);// range goes from 26 to 5 roughly
    println( "thumb diff: " + difference );
    diff[0] = difference;
    
    //adjusting for translations
    /*if ( (diff[0] >= 26  && curr.x < fingerInitialPosition[0].x) ||
          (diff[0] <= 6 && curr.x > fingerInitialPosition[0].x) ) { 
      adjustRefX( curr.x, 0 );
      println("x adjust");
    }
    if ( (int)( refPoint.y - curr.y ) > 15 || refPoint.y < curr.y ) {
      adjustRefY( curr.y, 0 );
      println("y adjust");
    }*/
  }
  
  //index
  if ( flexed[1] ) { 
    println("INDEX missing..."); 
    numFlexed++;
  }
  //calculate how flexed index is
  else if ( (newPos[1] != null && numFlexed == 0) ||  //null check
            (newPos[0] != null && numFlexed == 1) ) {
    
              //if thumb is flexed, shift index of index finger in newPos array
    if ( numFlexed == 1 ) { 
      curr = newPos[0];
    } else {
      curr = newPos[1];
    }
    
    //calculate the difference
    difference = (int)abs(refPoint.y - curr.y - 20);
    println( "index diff: " + difference );
    diff[1] = difference;
    difference = (int)abs( refPoint.x - curr.x );
    
    //adjust for translation
    /*if ( (diff[1] >= 26 &&  //finger is fully extended
         fingerInitialPosition[1].y > curr.y) ||  //above the finger initial position y
       ( curr.y <= refPoint.y && 
         curr.y >= refPoint.y - 10 ) ) {
      adjustRefY( curr.y, 1 );        
    }
    if ( difference > 8 ) {
      adjustRefX( curr.x, 1 );
    }*/
  }
  
  //Middle Finger
  if ( flexed[2] ) { 
    println("MIDDLE missing..."); 
    numFlexed++;
  }
  
  else if ( (newPos[2] != null && numFlexed == 0) || 
            (newPos[1] != null && numFlexed == 1) ||
            (newPos[0] != null && numFlexed == 2) ) {
    if ( numFlexed == 1 ) {
      curr = newPos[1];
    } else if ( numFlexed == 2 ) {
      curr = newPos[0];
    }
    else {
      curr = newPos[2];
    }
    difference = (int)abs(refPoint.y - curr.y - 26);
    println( "middle diff: " + difference );
    diff[2] = difference;
    difference = (int)abs( refPoint.x - curr.x );
    /*if ( (diff[2] >= 26 && fingerInitialPosition[2].y > curr.y) || 
           ( curr.y <= refPoint.y && curr.y >= refPoint.y - 10 ) ) {
      adjustRefY( curr.y, 2 );       
    }
    if ( difference > 6 ) {
      adjustRefX( curr.x, 2 );
    }*/
  }
  if ( flexed[3] ) { 
    println("Ring missing..."); 
    numFlexed++;
  }
  else if ( (newPos[3] != null && numFlexed == 0) || 
            (newPos[2] != null && numFlexed == 1) ||
            (newPos[1] != null && numFlexed == 2) || 
            (newPos[0] != null && numFlexed == 3) ) {
    if ( numFlexed == 1 ) {
      curr = newPos[2];
    } else if ( numFlexed == 2 ) {
      curr = newPos[1];
    } else if ( numFlexed == 3 ) {
      curr = newPos[0];
    } else {
      curr = newPos[3];
    }
    difference = (int)abs( refPoint.y - curr.y - 20 );
    println( "ring diff: " + difference );
    diff[3] = difference;
    difference = (int)abs( refPoint.x - curr.x );
    /*if ( (diff[3] >= 26 && fingerInitialPosition[3].y > curr.y) ||
            ( curr.y <= refPoint.y && curr.y >= refPoint.y - 10 ) ) {
      adjustRefY( curr.y, 3 );        
    }
    if ( difference > 8 ) {
      adjustRefX( curr.x, 3 );
    }*/
  }
  if ( flexed[4] ) { println("Pinky missing..."); }
  else if ( (newPos[4] != null && numFlexed == 0) || 
            (newPos[3] != null && numFlexed == 1) ||
            (newPos[2] != null && numFlexed == 2) || 
            (newPos[1] != null && numFlexed == 3) ||
            (newPos[0] != null && numFlexed == 4) ) {
    if ( numFlexed == 1) {
      curr = newPos[3];
    }
    else if ( numFlexed == 2 ) {
      curr = newPos[2];
    }
    else if ( numFlexed == 3 ) {
      curr = newPos[1];
    }
    else if ( numFlexed == 4 ) {
      curr = newPos[0];
    }
    else {
      curr = newPos[4];
    }
    difference = (int)abs( refPoint.y - curr.y + 2 );
    println( "pinky diff: " + difference );
    diff[4] = difference;
    //difference = (int)abs( refPoint.x - curr.x );
    /*if ( (diff[4] >= 26 && fingerInitialPosition[4].y > curr.y) ) {
      adjustRefY( curr.y, 4 );        
    }
    if ( curr.x > fingerInitialPosition[4].x + 8) {
      adjustRefX( curr.x, 4 );
    }*/
  }
  for ( int i = 0; i < newPos.length && newPos[i] != null; i++ ) {
    if ( newPos[i].x < fingerInitialPosition[0].x - 8 || 
         newPos[i].x > fingerInitialPosition[4].x + 25 ||
         (newPos[i].x < fingerInitialPosition[1].x - 15 && 
          newPos[i].y < fingerInitialPosition[0].y - 26) || 
          (newPos[i].x > fingerInitialPosition[3].x + 15 && 
          newPos[i].y < fingerInitialPosition[4].y - 26)) {
      adjustRefX( newPos[i].x, i );
    }
    if ( newPos[i].y > fingerInitialPosition[0].y + 20 || 
         newPos[i].y < fingerInitialPosition[2].y - 15) {
      adjustRefY( newPos[i].y, i );
    }
  }
}

boolean Sort(PVector[] toSort){
  //Sort our array based on x value
    //Thumb is 0,  index is 1, Middle = 2, Ring = 3, Pinky = 4;
    boolean swapped = false;
    int i = 0;
    while ( true ) {
      if ( toSort[i] != null && toSort[i + 1] != null && 
           toSort[i].x > toSort[i+1].x ) {
        PVector temp = toSort[i];
        toSort[i] = toSort[i+1];
        toSort[i+1] = temp;
        swapped = true;
      }
      i++;
      if ( i == toSort.length - 1) {
        if ( swapped ) {
          swapped = false;
          i = 0;
        }
        else {
          return true;
        }
      }
    }//end of bubble sort while
}