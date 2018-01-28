/* Purpose: Allow the robotic hand to play rock, paper, scissors
 *  Displays result on screen
 * Paired with Processing Programs FairRockPaperScissors, 
 * UnfairRockPaperScissor, or AlwaysWinRockPaperScissors
 * Created by: Jonathan Hernandez and Ayat Amin
 * Date: 03/17/2016
 */

import fingertracker.*;
import KinectPV2.*;
import processing.serial.*;

FingerTracker fingers;
KinectPV2 kinect;
Serial myPort;

int threshold = 625;
boolean game_state_on = false;

char player = 0;

String win = "You win!";
String lose = "You lose!";
String waiting = "Waiting for your Response";
String tied = "Tie Game!";

String currState = "";

boolean won;
boolean tie;

void setup() {
  size(1024, 848);
  //good: 512, 424 for fingers
  
  // initialize your SimpleOpenNI object
  // and set it up to access the depth image
  kinect = new KinectPV2(this);
  kinect.enableDepthImg(true);
  // mirror the depth image so that it is more natural
  //kinect.setMirror(true);

  // initialize the FingerTracker object
  // with the height and width of the Kinect
  // depth image
  fingers = new FingerTracker(this, 512, 424);
  
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
  // get a depth image and display it
  scale( 2 ); //set scale to 2 when code is faster
  PImage depthImage = kinect.getDepthImage();
  //depthImage.resize();
  image(depthImage, 0, 0);

  // update the depth threshold beyond which
  // we'll look for fingers
  fingers.setThreshold(threshold);
  
  // access the "depth map" from the Kinect
  // this is an array of ints with the full-resolution
  // depth data (i.e. 500-2047 instead of 0-255)
  // pass that data to our FingerTracker
  int[] depthMap = kinect.getRawDepthData();
  fingers.update(depthMap);
  
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
  
  
  int numFinger = GetActualFingerCount();
  if ( !game_state_on &&  numFinger == 1 ) {
    game_state_on = true;    
    myPort.write('d');
  }  
  
  if ( game_state_on && myPort.available() > 0 ) {
    char val = (char)myPort.read();
    if ( val == 'e') {
      if ( numFinger == 5 ) {
        player = '2';
      } else if ( numFinger == 2 ) {
        player = '1';
      } else {
        player = '0';
      }
      myPort.write(player);
    }
    if ( val >= '0' && val <= '2' ) {
      // 0 - rock
      // 1 - scissors
      // 2 - paper
      if ( val == '0' ) {
        if ( player == '0' ) {
          currState = tied;
        } else if ( player == '2') {
          currState = win;
        } else {
          currState = lose;
        }
      } else if ( val == '1' ) {
        if ( player == '1' ) {
          currState = tied;
        } else if ( player == '0') {
          currState = win;
        } else {
          currState = lose;
        }
      } else if ( val == '2' ) {
        if ( player == '2' ) {
          currState = tied;
        } else if ( player == '1') {
          currState = win;
        } else {
          currState = lose;
        }
      }
      game_state_on = false;
      //myPort.clear();
    }
  }

  if ( game_state_on ) {
    currState = waiting;
  }
  
  stroke( 0, 0, 255 );
  textSize(32);
  text( currState, 50, 50 );
}

boolean isWithinBorder( PVector p ) {
  if ( p.x > 128 && p.x < 384 &&
       p.y > 106 && p.y < 318 ) {
    return true;
  }
  return false;
}

int GetActualFingerCount() {
  int numFinger = 0;
  for ( int i = 0;  i < fingers.getNumFingers(); i++ ) {
    PVector curr = fingers.getFinger( i );
    if ( isWithinBorder( curr ) ) {
      numFinger++;
    }
  }
  return numFinger;
}