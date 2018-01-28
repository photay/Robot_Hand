/* Purpose: Allow the robotic hand and the user hand to display a total of 5 digits. 
 *  If the user shows more than 5 fingers, robot stays at 0.
 * Paired with Processing Program Adding_to_five
 * Created by: Jonathan Hernandez and Ayat Amin
 * Date: 03/17/2016
 */
 
#include <Servo.h>
#include <stdio.h>

//Declaring the 5 servomotors for our 5 fingers
Servo index;
Servo middle;
Servo ring;
Servo pinky;
Servo thumb;

char val; //tmp value to read characters from serial

int numFingers = 0; //the total number of fingers the user
                    //is holding out. determined from kinectt

// 0 -> index
// 1 -> middle
// 2 -> ring
// 3 -> pinky
// 4 -> thumb 
bool flex[5]; //boolean to detect which fingers are flexed


void setup() {

  //Attach the 5 servomotors
  index.attach( 9, 650, 2350 );
  middle.attach( 6, 650, 2350 );
  ring.attach( 5, 650, 2350);
  pinky.attach( 3, 450, 3000);
  thumb.attach( 10, 650, 2350 );
  
  Serial.begin( 9600 );

  //set all fingers to 0. ie- hand is open
  index.write( 0 );
  middle.write( 0 );
  ring.write( 0 );
  pinky.write( 0 );
  thumb.write( 0 );

  //initial all values in flex to false
  //false => finger is straight, true => finger is bent
  for ( int i = 0; i < 5; i++) {
    flex[i] = false;  
  }
}

void loop() {

  //Open Serial and get data from Processing via Serial
  if ( Serial.available() ) {
    val = Serial.read();
    numFingers = (int)( val - '0' );

    //Reset all the values to flex to true
    //Default - hand is closed
    for ( int i = 0; i < 5; i++ ) {
      flex[i] = true;  
    }

    //Based on the numFingers, set values in flex to false
    switch( numFingers ) {
      case 1: 
        flex[0] = false;
        break;
      case 2: 
        flex[0] = flex[1] = false;
        break;
      case 3: 
        flex[0] = flex[1] = flex[2] = false;
        break;
      case 4: 
        flex[0] = flex[1] = flex[2] = flex[3] = false;
        break;
      case 5:
        flex[0] = flex[1] = flex[2] = flex[3] = flex[4] = false; 
        break;
      default: 
        break;
    }
  }

  //Write the proper value to the servomotor. 
  if ( flex[0] ) {
    index.write( 180 );
  } else { index.write( 0 ); }
  if ( flex[1] ) {
    middle.write( 180 );  
  } else { middle.write( 0 ); }
  if ( flex[2] ) {
    ring.write( 180 );  
  } else { ring.write( 0 ); }
  if ( flex[3] ) {
    pinky.write( 180 );  
  } else { pinky.write( 0 ); }
  if ( flex[4] ) {
    thumb.write( 130 );  
  } else{ thumb.write(0); }
  delay( 10 );
}
