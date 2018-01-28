/* Purpose: Allow the robotic hand and the user hand to display a total of 5 digits. 
 *  If the user shows more than 5 fingers, robot stays at 0.
 * Paired with Processing Program Adding_to_five
 * Created by: Jonathan Hernandez and Ayat Amin
 * Date: 03/17/2016
 */

//Import the fingertracker, Serial, and Kinect library
import processing.serial.*;
import fingertracker.*;
import KinectPV2.*;

//Declare FignerTracker, Serial and Kinect objects
FingerTracker fingers;
KinectPV2 kinect;
Serial myPort;

// Set a default threshold distance for detecting fingers in fingertrack
// Lower numbers mean more sensitivity
// 625 corresponds to about 2-3 feet from the Kinect
// placing user hand 55 cm to 60 cm is the sweet spot for value 625
int threshold = 625;


void setup() {
  size(640, 480); //size of screen displaying video
  //good: 512, 424 for fingers
  
  // initialize your Kinect
  // set it up to access the depth image
  kinect = new KinectPV2(this);
  kinect.enableDepthImg(true);

  // initialize serial for talking to Arduino
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);

  // initialize the FingerTracker object
  // w/ height and width of the Kinect depth image
  fingers = new FingerTracker(this, 512, 424);
  
  // the "melt factor" smooths out the contour making the finger tracking more robust
  // especially at short distances farther away you may want a lower number
  fingers.setMeltFactor(100);
  
  //initialize kinect
  kinect.init();
}


void draw() {
  // get a depth image and display it
  PImage depthImage = kinect.getDepthImage();
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
  
  //draw red box to show locations fingers will be detected
  stroke( 255, 0, 0 );
  line( 128, 106, 384, 106 );
  line( 128, 106, 128, 318 );
  line( 384, 106, 384, 318 );
  line( 128, 318, 384, 318 );
  
  
  //get the number of fingers
  int numFinger = getActualFingerCount();
  
  //write the number of fingers to string info
  //which is sent to Arduino
  String info;
  if ( numFinger > 5 ) {
    info = "0";
  }
  else { 
    info = Integer.toString(5 - getActualFingerCount());
  }
  
  //send number of fingers to Arduino
  myPort.write( info );
}

//Check if fingers are within the red borders
boolean isWithinBorder( PVector p ) {
  if ( p.x > 128 && p.x < 384 &&
       p.y > 106 && p.y < 318 ) {
    return true;
  }
  return false;
}

//Return the number of fingers detected by the kinect
int getActualFingerCount() {
  int numFingers = 0;
  for(int i = 0; i< fingers.getNumFingers(); i++){    
    if ( isWithinBorder( fingers.getFinger(i) ) ) {
      numFingers++;
    }
  }
  return numFingers;
}