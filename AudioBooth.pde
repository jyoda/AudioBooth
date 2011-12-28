/**
 * AudioBooth.pde
 */ 

import processing.video.*;
import ddf.minim.*;

BufferedReader textreader;
String line;
int id;
PrintWriter textoutput;

Capture cam;
Boolean active = false;

Minim minim;
AudioInput input;
AudioRecorder recorder;

PImage on;
PImage off;

void clearitall() {
  
  // the AudioInput you got from Minim.getLineIn()
    if (input != null) {
      input.close();
    }
    if (minim != null) {
      minim.stop();
    }
    
  //Kill the variables  
  background(0);
  textreader = null;
  line = null;
  id = 0;
  textoutput = null;
  active = false;
  minim = null;
  input = null;
  recorder = null;
  on = null;
  off = null;
  
    //Text File Stuff
    //Read ID from text file
    textreader = createReader(dataPath("ids.txt"));
    try {
      line = textreader.readLine();
      //Make it an integer so we can do math & iterate
      id = Integer.parseInt(line);
      id++;
      println(id);
    } catch (IOException e) {
      e.printStackTrace();
      line = null;
    }
  
  
  //Audio Stuff
    minim = new Minim(this);
    input = minim.getLineIn(Minim.STEREO, screen.width);
    String filename = "media/audio-" + id + ".wav";
    recorder = minim.createRecorder(input, filename, true);
    
  //Other
    on = loadImage(dataPath("on.gif"));
    off = loadImage(dataPath("off.gif"));
}

void setup() {
  size(screen.width, screen.height);
  clearitall();
   //Camera Stuff
    // If no device is specified, will just use the default.
    //cam = new Capture(this, 1280, 720);

    // To use another device (i.e. if the default device causes an error),
    // list all available capture devices to the console to find your camera.
    String[] devices = Capture.list();
    //println(devices);

    // Change devices[0] to the proper index for your camera.
    cam = new Capture(this, 1280, 720, devices[3]);

    // Opens the settings page for this capture device.
    //cam.settings();

}

void draw() {
  if (cam.available() == true && active == false) {
    //Camera Stuff
    cam.read();
    imageMode(CENTER);
    image(cam, screen.width / 2, screen.height / 2);
  }
  
  //Recording status
    if ( recorder.isRecording() )
    {
      //Sound Viz
      stroke(255,0,0);
      background(0);
      image(cam, screen.width / 2, screen.height / 2);
      image(on, screen.width / 2, 50);
      
      
      // draw the waveforms
      for(int i = 0; i < input.bufferSize() - 1; i++)
      {
        line(i, (screen.height / 3) + input.left.get(i)*150, i+1, (screen.height / 3) + input.left.get(i+1)*150);
        line(i, ((screen.height / 3) * 2) + input.right.get(i)*150, i+1, ((screen.height / 3) * 2) + input.right.get(i+1)*150);
      }

    }
    else
    {
      image(off, screen.width / 2, 50);
    }
} 

void keyPressed() {
    if (key == ' ') {  // space bar
    
      String filename = "media/photo-" + id + ".jpg";
      cam.save(filename);
      
      //Audio Stuff
      if ( recorder.isRecording() )
      {
        recorder.endRecord();
        recorder.save();
        active = false;
        clearitall();
        draw();
      }
      else
      {
        recorder.beginRecord();
        active = true;
      }
      
      //Text File Stuff
      textoutput = createWriter(dataPath("ids.txt"));
      textoutput.println(id);
      textoutput.flush(); // Writes the remaining data to the file
      textoutput.close(); // Finishes the file
    }
    
   
}

void stop()
{
  
  // the AudioInput you got from Minim.getLineIn()
  input.close();
  minim.stop();
 
  // this calls the stop method that 
  // you are overriding by defining your own
  // it must be called so that your application 
  // can do all the cleanup it would normally do
  super.stop();
}

