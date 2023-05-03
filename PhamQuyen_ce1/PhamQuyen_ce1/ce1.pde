import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

//declare global variables at the top of your sketch
//AudioContext ac; is declared in helper_functions
SamplePlayer buttonSound;
ControlP5 p5;

Glide gainGlide;
Gain masterGain;

Glide dampingGlide;
Reverb r;
//end global variables

//runs once when the Play button above is pressed
void setup() {
  size(320, 240); //size(width, height) must be the first line in setup()
  
  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions 
  p5 = new ControlP5(this); //Initialize p5;
  
  buttonSound = getSamplePlayer("soundRoad.wav");
  buttonSound.pause(true);
  
  
  dampingGlide = new Glide(ac, 0.5, 50);
  r = new Reverb(ac, 1);//Create a new reverb which takes in 1 input
  r.setDamping(dampingGlide.getValue());
  r.addInput(buttonSound); // The sound will be sent to reverb
 
  
  
  
  gainGlide = new Glide(ac, 1.0, 500); //Create a gline to smoothly change masterGain, is used control the volume (Gain) dynamically (a knob) //@params: ac, starting value held by Glide, #time it takes to go from 1 value to another value
  masterGain = new Gain(ac, 1, gainGlide); //with @params: ac, # of input, start at - to control the volume of the object
  masterGain.addInput(r);//the sound from reverb was sent to masterGain
  ac.out.addInput(masterGain); // after that the sound was sent to ac
  
  
  p5.addButton("Play")
    .setPosition(width/2 + 30, 100)
    .setSize(60, 20)
    .setLabel("Play Sound")
    .activateBy((ControlP5.RELEASE));
    
    p5.addSlider("Gainslider")
    .setPosition(20, 20)
    .setSize(20, 200)
    .setRange(0, 100)
    .setValue(50)
    .setLabel("Gain");
    
    p5.addSlider("DampingTime")
    .setPosition(80, 20)
    .setSize(20, 200)
    .setRange(0, 1)
    .setValue(0.5)
    .setLabel("Damping Value");

  ac.start();                  
}

void Play(int value){
  //resets sound whenever play button is pressed
  buttonSound.setToLoopStart();
  buttonSound.start();
}

void Gainslider(float value){
  println("Gain slider moved: ", value);
  gainGlide.setValue(value/100);
}

void DampingTime(float value){
  println("Damping Time slider moved: ", value);
  dampingGlide.setValue(value);
}


void draw() {
  background(0);  //fills the canvas with black (0) each frame 
}
