/* Purpose: Allow the robotic hand to play rock, paper, scissors
 *  This version has the robot hand always win
 * Paired with Processing Program RockPaperScissorGeneral
 * Created by: Jonathan Hernandez and Ayat Amin
 * Date: 03/17/2016
 */
#include <Servo.h>
#include <stdio.h>

Servo thumb;
Servo index;
Servo middle;
Servo ring;
Servo pinky;

char val = 'a';
int maxThumbPos = 100;
int maxFingerPos = 160;
bool flexed[5] = { false, false, false, false, false };


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
  // put your main code here, to run repeatedly:
  if ( Serial.available() > 0 ) {
     val = Serial.read(); 
  }
  if ( val == 'd' ) {
    reset();
    delay(3000);
    Serial.print('e');
  }
  if ( val >= '0' && val <= '2' ) {
    Serial.print( Cheat( val ) );
  }
  val = 'a';
}

void reset () {
  flexed[0] = flexed[4] = flexed[2] = flexed[3] = true;
  flexed[1] = false;
  rotateThumb();
  rotateServo( 1, index );
  rotateServo( 2, middle );
  rotateServo( 3, ring );
  rotateServo( 4, pinky );
}

int Cheat( char player ) { 
  int hand = 0;
  if ( player == '2' ) {
    flexed[0] = flexed[3] = flexed[4] = true;
    flexed[1] = flexed[2] = false;
    hand = 1;
  } else if ( player == '1' ) {
    flexed[0] = flexed[1] = flexed[2] = flexed[3] = flexed[4] = true;
    hand = 0;
  } else {
    flexed[0] = flexed[1] = flexed[2] = flexed[3] = flexed[4] = false;  
    hand = 2;
  }
  rotateThumb();
  rotateServo( 1, index );
  rotateServo( 2, middle );
  rotateServo( 3, ring );
  rotateServo( 4, pinky );
  return hand;
}

void rotateServo( int i, Servo & servo ) {
  if ( flexed[ i ] ) { 
    servo.write( maxFingerPos );
  } else {
    servo.write( 0 );  
  }  
}

void rotateThumb() {
  if ( flexed[ 0 ] ) {
    thumb.write( maxThumbPos );
  } else {
    thumb.write( 0 );  
  } 
}
