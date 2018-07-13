
/**
 * oscP5message by andreas schlegel
 * example shows how to create osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 
import oscP5.*;
import netP5.*;


import processing.serial.*;

//For Arduino
Serial myPort;  // Create object from Serial class

//For OSC
OscP5 oscP5;
NetAddress myRemoteLocation;

float pRoll = 100;
float pPitch = 100;
float pHead = 100;

void setup() {
  size(400,400);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  
  //JH - AddOSC (blender) default broadcast port is 9002
  oscP5 = new OscP5(this,9002);
  
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 115200);
  smooth();
  frameRate(60);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
   
   //JH - AddOSC (blender) default listening port is 9001
  myRemoteLocation = new NetAddress("127.0.0.1", 9001);
}


void draw() {
  background(0);  
  

  
  while (myPort.available() > 0) {
    String inBuffer = myPort.readString();   
    if (inBuffer != null) {
      String[] list = split(inBuffer, ',');
      if(list.length > 2){
        float roll = float(list[0]) ; // To radians
        float pitch = float(list[1]) * -1 ;
        float heading = float(list[2]);
        
        if(pRoll == 100)
        {
         pRoll = roll;
         pPitch = pitch;
         pHead = heading;
        //}
        //}else if( abs(pRoll - roll) > 1 || abs(pPitch - pitch) > 1  || abs(pHead - heading) > 1 ) //Outlier detection
        //{
        //  //DO nothing
        //  print("OUTLIER");
        }else{
          send(roll, pitch, heading);
          //println("Roll: " , nf(roll, 1, 2), "  Pitch: ", nf(pitch, 1, 2), "Heading: ", nf(heading, 1, 2));
        } 
      }  
    }
  }
  
}

void send(float r, float p, float h) {
  /* in the following different ways of creating osc messages are shown by example */
  OscMessage myMessage = new OscMessage("/test");
  
  //nf used for significant digits
  myMessage.add(float(nf(r, 1, 5))); /* add an int to the osc message */
  myMessage.add(float(nf(p, 1, 5))); /* add a float to the osc message */
  myMessage.add(float(nf(h, 1, 5)));
  
  /* send the message */
  oscP5.send(myMessage, myRemoteLocation); 
}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}