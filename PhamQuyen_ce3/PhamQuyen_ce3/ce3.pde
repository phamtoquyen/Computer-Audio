import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

SamplePlayer backgroundMusic;
SamplePlayer gps1;
SamplePlayer gps2;

ControlP5 p5;

Gain musicGain; 
Gain masterGain;

Glide masterGainGlide; 
Glide musicGainGlide; 
Glide filterGlide; 

BiquadFilter duckFilter;
private static final float BIQUAD_FILTER = 500.0;

void setup() {
  size(320, 240);
  
  ac = new AudioContext();  
  p5 = new ControlP5(this); 

Bead endListener = new Bead() {
  public void messageReceived(Bead message){
    SamplePlayer sp = (SamplePlayer) message;
    filterGlide.setValue(10.0);
    musicGainGlide.setValue(1.0);  
    sp.pause(true);
  }
};

backgroundMusic = getSamplePlayer("backgroundmusic.wav");
backgroundMusic.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);

gps1 = getSamplePlayer("GPS1.wav");
gps1.pause(true);

gps2 = getSamplePlayer("GPS2.wav");
gps2.pause(true);

gps1.setEndListener(endListener);
gps2.setEndListener(endListener);


//Gain and Glide used to duck music by decreasing Gain/volume
musicGainGlide = new Glide(ac, 1.0, 500);
musicGain = new Gain(ac, 1, musicGainGlide);

//Master Gain and Glide Ugens
masterGainGlide = new Glide(ac, 10.0, 500);
masterGain = new Gain(ac, 1, masterGainGlide);

//BiquadFilter and cutoff filter Glide to duck music by filtering
filterGlide = new Glide(ac, 10.00, 500);
duckFilter = new BiquadFilter(ac, BiquadFilter.HP, filterGlide, .5);


duckFilter.addInput(backgroundMusic);
musicGain.addInput(duckFilter);

masterGain.addInput(musicGain);

masterGain.addInput(gps1); 
masterGain.addInput(gps2);

//output the final sound
ac.out.addInput(masterGain);

//Create the GainSlider 
p5.addSlider("GainSlider")
.setPosition(20, 20)
.setSize(20, 200)
.setValue(30.0)
.setLabel("Master Gain");

//This can creates the play button, which allows the sound to be played, once the onClicked is avtivated
p5.addButton("PlayGPS1")
.setPosition(width/2 - 20, 110)
.setSize(width/2 - 20, 20)
.setLabel("Play GPS 1");

p5.addButton("PlayGPS2")
.setPosition(width/2 - 20, 140)
.setSize(width/2 - 20, 20)
.setLabel("Play GPS 2");

ac.start();
}

//Create the Play method
public void PlayGPS1() {
gps2.pause(true);
musicGainGlide.setValue(.3);
gps1.setToLoopStart();
filterGlide.setValue(BIQUAD_FILTER);
gps1.start();
}

public void PlayGPS2() {
gps1.pause(true);
musicGainGlide.setValue(0.3);
gps2.setToLoopStart();
filterGlide.setValue(BIQUAD_FILTER);
gps2.start();
}

//Master gain slider
public void GainSlider(float value){
  masterGainGlide.setValue(value/100.0);
}

void draw() {
  background(0);
}
