// FFT_01.pde
// This example is based in part on an example included with
// the Beads download originally written by Beads creator
// Ollie Bown. It draws the frequency information for a
// sound on screen.
import controlP5.*;
import beads.*;


Gain masterGain;
Glide cutoffGlide;
BiquadFilter filter;

Reverb reverb;
UGen micInput;
SamplePlayer player;

ControlP5 p5;
PowerSpectrum ps;

boolean micOn = false;
boolean reverbOn = false;

color fore = color(255, 255, 255);
color back = color(0,0,0);

void setup()
{

 size(1000,600);
 p5= new ControlP5(this);
 ac = new AudioContext();

 // set up a master gain object
 masterGain = new Gain(ac, 2, 0.3);
 ac.out.addInput(masterGain);

 // load up a sample included in code download
 SamplePlayer player = null;
 try
 {
 // Load up a new SamplePlayer using an included audio
 // file.
 
 player = getSamplePlayer("techno.wav",false);
 player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
 // connect the SamplePlayer to the master Gain
 //masterGain.addInput(player); ************************
 }
 catch(Exception e)
 {
 // If there is an error, print the steps that got us to
 // that error.
 e.printStackTrace();
 }
 // In this block of code, we build an analysis chain
 // the ShortFrameSegmenter breaks the audio into short,
 // discrete chunks.
 ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);
 sfs.addInput(ac.out);

 // FFT stands for Fast Fourier Transform
 // all you really need to know about the FFT is that it
 // lets you see what frequencies are present in a sound
 // the waveform we usually look at when we see a sound
 // displayed graphically is time domain sound data
 // the FFT transforms that into frequency domain data
 FFT fft = new FFT();
 // connect the FFT object to the ShortFrameSegmenter
 sfs.addListener(fft);

 // the PowerSpectrum pulls the Amplitude information from
 // the FFT calculation (essentially)
 ps = new PowerSpectrum();
 // connect the PowerSpectrum to the FFT
 fft.addListener(ps);
 // list the frame segmenter as a dependent, so that the
 // AudioContext knows when to update it.
 ac.out.addDependent(sfs);
 // start processing audio
 
 cutoffGlide = new Glide(ac, 1500.0, 50);
 filter = new BiquadFilter(ac, BiquadFilter.AP, cutoffGlide, 0.5f);
 //add player output to the filter
 filter.addInput(player);
 //add output of filter to the gain
 masterGain.addInput(filter);
 
 reverb = new Reverb(ac);
 reverb.setSize(0.01);
 reverb.setDamping(0.1);
 reverb.setEarlyReflectionsLevel(0.1);
 
 micInput= ac.getAudioInput();
 
 //Button to control low pass filter
 p5.addButton("LowPassFilter")
   .setPosition(895,0)
   .setSize(100, 20)
   .setLabel("Low Pass Filter");
   
  p5.addButton("HighPassFilter")
   .setPosition(895, 25)
   .setSize(100, 20)
   .setLabel("High Pass Filter");
   
  p5.addButton("NoFilter")
 .setPosition(895, 50)
 .setSize(100, 20)
 .setLabel("No Filter");
 
  p5.addButton("BandPassFilter")
 .setPosition(895, 70)
 .setSize(100, 20)
 .setLabel("Band Pass Filter");
 
 //Button to control Reverb
   p5.addButton("Reverb")
 .setPosition(895, 125)
 .setSize(100, 20)
 .setLabel("Reverb Toggle");
 
  //Button to control Mic
   p5.addButton("Mic")
 .setPosition(895, 175)
 .setSize(100, 20)
 .setLabel("Mic Toggle");
 
   //Slider to control cutoff frequency
   p5.addSlider("CutoffSlider")
 .setPosition(695, 100)
 .setSize(200, 20)
 .setRange(20.0, 1500.00)
 .setValue(5000.0)
 .setLabel("Cutoff Frequency");
 
    //Slider to control damping
   p5.addSlider("Damping")
 .setPosition(695, 150)
 .setSize(200, 20)
 .setRange(0.0, 1.0)
 .setValue(.5)
 .setLabel("Damping");
 ac.start();
}

// Button handler - NoFilter- for toggling filter off
public void NoFilter(){
  println("no filter button pressed");
  filter.setType(BiquadFilter.AP);
}

// Button handler - LowPassFilter- for turning on low pass filter
public void LowPassFilter(){
  println("low pass filter button pressed");
  filter.setType(BiquadFilter.LP);
}

// Button handler - HighPassFilter- for turning on low pass filter
public void HighPassFilter(){
  println("high pass filter button pressed");
  filter.setType(BiquadFilter.HP);
}

void Mic() {
  if (micOn){
    micOn = false;
  }else {
    micOn = true;
  }
  
  if (micOn){
    filter.clearInputConnections();
    filter.addInput(micInput);
  }else {
  filter.clearInputConnections();
  filter.addInput(player);
  }
}

void Reverb() {
  if (reverbOn) {
    reverbOn = false;
    reverb.clearInputConnections();
    masterGain.clearInputConnections();
    masterGain.addInput(filter);
  } else {
  reverbOn = true;
  masterGain.clearInputConnections();
  reverb.addInput(filter);
  masterGain.addInput(reverb);
  }
}

// Button handler - BandPassFilter - for turning on low pass filter 
void BandPassFilter() {
  println("band pass filter button pressed");
  filter.setType(BiquadFilter.BP_SKIRT);
}

// Button handler - CutoffSlider - for filter cutoff frequency value change 
void CutoffSlider(float value) {
  println("cutoff slider pressed");
  cutoffGlide.setValue(value);
}

void Damping(float value) {
  reverb.setDamping(value);
}

// In the draw routine, we will interpret the FFT results and
// draw them on screen.

void draw()
{
 background(back);
 stroke(fore);

 // The getFeatures() function is a key part of the Beads
 // analysis library. It returns an array of floats
 // how this array of floats is defined (1 dimension, 2
 // dimensions ... etc) is based on the calling unit
 // generator. In this case, the PowerSpectrum returns an
 // array with the power of 256 spectral bands.
 float[] features = ps.getFeatures();

 // if any features are returned
 if(features != null)
 {
 // for each x coordinate in the Processing window
 for(int x = 0; x < width; x++)
 {
 // figure out which featureIndex corresponds to this x-
 // position
 int featureIndex = (x * features.length) / width;
 // calculate the bar height for this feature
 int barHeight = Math.min((int)(features[featureIndex] *
 height), height - 1);
 // draw a vertical line corresponding to the frequency
 // represented by this x-position
 line(x, height, x, height - barHeight);
 }
 }
}
