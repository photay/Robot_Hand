# Robot_Hand

This was a 6-week class project for my Physics 124 class where students were allowed to build anything. The only requirements was that our project had to take an input, process that input, and provide an output as a response. 

My project partner, Jonathan Hernandez, and I decided to build a robot hand that mimics a user's movement. To get the user's movement, we used video from the Kinect 2. We then used Processing to process that information on the computer, which in turn was sent to Arduino Uno controlling 5 servo motors. Each servo motor was attached to a string that was attached to a rubber finger in our 'hand'.

A playlist demonstrating the final product can be found here: https://www.youtube.com/watch?list=PLuWhI7hiwJrijWZoEcejqjgjcz9vXYrVA&v=DrZbAenRlwQ

### Dependencies

#### Fingertracking Library
source: https://github.com/atduskgreg/FingerTracker

This library uses blobs to track the tips of fingers. 


#### KinectPV2
source: https://github.com/ThomasLengeling/KinectPV2
This library was used to input Kinect 2 input into Processing. 
