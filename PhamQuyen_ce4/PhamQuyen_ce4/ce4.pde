import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

ControlP5 p5;

SamplePlayer music;
Glide musicRateGlide; // control playback rate of music SamplePlayer (i.e. play, FF, Rewind)
double musicLength;
Bead musicEndListener;

SamplePlayer play;
SamplePlayer rewind;
SamplePlayer stop;
SamplePlayer fastforward;
SamplePlayer reset;

void setup(){
  size(320, 260);
  ac = new AudioContext(); 
  p5 = new ControlP5(this);
  
  music = getSamplePlayer("music.wav");
  musicLength = music.getSample().getLength();
  musicRateGlide = new Glide(ac, 0, 500);
  music.setRate(musicRateGlide);
  
  play = getSamplePlayer("play.wav");
  play.pause(true);
  rewind = getSamplePlayer("rewind.wav");
  rewind.pause(true);
  stop = getSamplePlayer("stop.wav");
  stop.pause(true);
  fastforward = getSamplePlayer("fastforward.wav");
  fastforward.pause(true);
  reset = getSamplePlayer("reset.wav");
  reset.pause(true);
  
  ac.out.addInput(music);
  ac.out.addInput(play);
  ac.out.addInput(stop);
  ac.out.addInput(rewind);
  ac.out.addInput(fastforward);
  ac.out.addInput(reset);
  
  
  musicEndListener = new Bead(){
    public void messageReceived(Bead message){
      SamplePlayer sp = (SamplePlayer) message;
      sp.setEndListener(null);
      setPlaybackRate(0, true);
      stop.start(0);
    }
  };

  // Create the UI
  p5.addButton("Play")
    .setWidth(width - 20)
    .setHeight(40)
    .setPosition(10 , 10)
    .activateBy((ControlP5.RELEASE));
    
  p5.addButton("Rewind")
    .setWidth(width - 20)
    .setHeight(40)
    .setPosition(10, 60)
    .activateBy((ControlP5.RELEASE));

  p5.addButton("Stop")
    .setWidth(width - 20)
    .setHeight(40)
    .setPosition(10, 110)
    .activateBy((ControlP5.RELEASE));

  p5.addButton("FastForward")
    .setPosition(10, 160)
    .setWidth(width - 20)
    .setHeight(40)
    .setLabel("Fast Forward")
    .activateBy((ControlP5.RELEASE));
    
  p5.addButton("Reset")
    .setWidth(width - 20)
    .setHeight(40)
    .setPosition(10, 210)
    .activateBy((ControlP5.RELEASE));
    
  ac.out.addInput(music);
  ac.out.addInput(play);
  ac.out.addInput(rewind);
  ac.out.addInput(stop);
  ac.out.addInput(reset);
  ac.out.addInput(fastforward);
  ac.start();
}

// Add endListener to the music SamplePlayer if one doesn't already exist
public void addEndListener() {
  if (music.getEndListener() == null) {
    music.setEndListener(musicEndListener);
  }
}

// Set music playback rate using a Glide
public void setPlaybackRate(float rate, boolean immediately) {
  // Make sure playback head position isn't past end or beginning of the sample 
  if (music.getPosition() >= musicLength) {
    println("End of tape");
    // reset playback head position to end of sample (tape)
    music.setToEnd();
  }

  if (music.getPosition() < 0) {
    println("Beggining of tape");
    music.reset();
  }
  
  if (immediately) {
    musicRateGlide.setValueImmediately(rate);
  }
  else {
    musicRateGlide.setValue(rate);
  }
}

public void Play(int value)
{
  println("press play");
  if (music.getPosition() < musicLength) {
    setPlaybackRate(1, false);
    addEndListener();
  }
  play.start(0);
}

public void FastForward(int value) {
  println("pressed FF");
  if (music.getPosition() < musicLength) {
    setPlaybackRate(4, false);
    music.setEndListener(musicEndListener);
  }
  fastforward.start(0);
}

public void Stop(int value){
  println("stop");
  stop.start(0);
  setPlaybackRate(0, false);
}

public void Reset(int value) {
  println("reset");
  reset.start(0);
  music.reset();
  setPlaybackRate(0, true);
}

public void Rewind(int value) {
  println("RWD");
  if (music.getPosition()> 0) {
    setPlaybackRate(-4, false);
    music.setEndListener(musicEndListener);
  }
  rewind.start(0);
}


void draw() {
  background(0);
}
