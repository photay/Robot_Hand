/* Purpose: Mimic the motions of the user hand with the robot hand
 * Paired with Processing Program FingerTrackerKinectFinal
 * Created by: Jonathan Hernandez and Ayat Amin
 * Date: 03/17/2016
 */

#include <Servo.h>
#include <stdio.h>

Servo index;
Servo middle;
Servo ring;
Servo pinky;
Servo thumb;
String a;
unsigned int currFinger = 0;
char val = 'A';
int maxThumbPos = 100;
int maxFingerPos = 160;


void setup() {
  // put your setup code here, to run once:
  index.attach( 9, 650, 2350 ); // 650, 2350
  middle.attach( 6, 650, 2350 );
  ring.attach( 5, 650, 2350);
  pinky.attach( 3, 500, 3350);
  thumb.attach( 10, 650, 2350 );
  Serial.begin( 9600 );
  index.write( 0 );
  middle.write( 0 );
  ring.write( 0 );
  pinky.write( 0 );
  thumb.write( 0 );
}

void loop() {
  if( Serial.available() ) {
    val = Serial.read();
    if ( val >= 'A' && val <='Z' ) {  
      if( currFinger == 0 ) {
        rotateThumb( val );
      } else if ( currFinger == 1 ) {
        rotateServo( val, index );
      } else if ( currFinger == 2 ) {
        rotateServo( val, middle );
      } else if ( currFinger == 3 ) {
        rotateServo( val, ring );
      } else if ( currFinger == 4 ) {
        rotateServo( val, pinky );
      }
    }
    currFinger++;
    if ( currFinger == 5 ) {  
      currFinger = 0;
    }
  }
}

void rotateServo( char input, Servo & servo ) {
  if ( input == 'Z' ) { 
    servo.write( maxFingerPos );
  } else if ( input == 'A' ) {
    servo.write( 0 );  
  } else {
    servo.write( maxFingerPos * ( input - 'A' ) / ( 'Z' - 'A' ) );  
  }  
}

void rotateThumb( char input ) {
  if ( input == 'Z' ) {
    thumb.write( maxThumbPos );
  } else if ( input == 'A' ) {
    thumb.write( 0 );  
  } else {
    thumb.write( maxThumbPos * ( input - 'A' ) / ( 'Z' - 'A' ) );  
  } 
}
