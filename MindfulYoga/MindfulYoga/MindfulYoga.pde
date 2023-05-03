//This project is built based on the idea of smartHome provided on Canvas

import beads.*;
import org.jaudiolibs.beads.*;
import controlP5.*;
import guru.ttslib.*;

ControlP5 p5;

Gain masterGain;
Glide gainGlide;
Glide cutoffGlide;
BiquadFilter lpFilter;

Button startEventStream;
Button pauseEventStream;
Button stopEventStream;

BiquadFilter duckFilter;
Glide filterGlide;
Gain musicGain;

Button onYogaMode;
Button onMeditationMode;
Button onHeartRateMode;
Button onReminderMode;

SamplePlayer yogaSound;
SamplePlayer meditationSound;
SamplePlayer heartRateSound;
SamplePlayer remiderSound;
SamplePlayer alertSound; //Used when heart rate was not in normal range.

//IMPORTANT (notice from text_to_speech.pde):
//to use this you must import 'ttslib' into Processing, as this code uses the included FreeTTS library
//e.g. from the Menu Bar select Sketch -> Import Library... -> ttslib


TextToSpeechMaker ttsMaker;
//priority: 1, 2, 3, 4 --> on yoga, on meditation, on heartRate, on reminder mode
int priority; 

//name of a file to load from the data directory
String eventDataJSON = "notification.json";

NotificationServer notificationServer;
ArrayList<Notification> notifications;

MyNotificationListener myNotificationListener;

void setup() {
  size(620,220);
  p5 = new ControlP5(this);
  ac = new AudioContext(); //ac is defined in helper_functions.pde
  cutoffGlide = new Glide(ac,1500.0, 50);
  lpFilter = new BiquadFilter(ac, BiquadFilter.LP, cutoffGlide, 0.5f);
  gainGlide = new Glide(ac, .75, 2000);
  masterGain = new Gain(ac, 1, gainGlide);
  
  alertSound = getSamplePlayer("alert.wav");
  alertSound.pause(true);
  
  //mode sounds
  yogaSound = getSamplePlayer("yoga.wav");
  yogaSound.pause(true);
  
  meditationSound = getSamplePlayer("meditation.wav");
  meditationSound.pause(true);
  
  heartRateSound = getSamplePlayer("heartRate.wav");
  heartRateSound.pause(true);
  
  //this will create WAV files in your data directory from input speech 
  //which you will then need to hook up to SamplePlayer Beads

  ttsMaker = new TextToSpeechMaker();
  
  String exampleSpeech = "Text to speech is okay, I guess.";
  
  ttsExamplePlayback(exampleSpeech); //see ttsExamplePlayback below for usage
  
  //START NotificationServer setup
  notificationServer = new NotificationServer();
  
  //instantiating a custom class (seen below) and registering it as a listener to the server
  myNotificationListener = new MyNotificationListener();
  notificationServer.addListener(myNotificationListener);
    
  //END NotificationServer setup
  
  //START sounds button
  p5.addButton("Yoga")
    .setPosition(100 ,20)
    .setSize(100, 20)
    .setLabel("Yoga")
    .activateBy((ControlP5.RELEASE));
    
  p5.addButton("Meditation")
    .setPosition(230 ,20)
    .setSize(100, 20)
    .setLabel("Meditation")
    .activateBy((ControlP5.RELEASE));
  
  p5.addButton("HeartRate")
    .setPosition(360 ,20)
    .setSize(100, 20)
    .setLabel("Heart Rate")
    .activateBy((ControlP5.RELEASE));

  p5.addButton("Reminder")
    .setPosition(490 ,20)
    .setSize(100, 20)
    .setLabel("Reminder")
    .activateBy((ControlP5.RELEASE));
  //END sounds button
      
 //START event streams
  
  startEventStream = p5.addButton("startEventStream")
    .setPosition(100,100)
    .setSize(130,20)
    .setLabel("Start Event Stream");
  
  startEventStream = p5.addButton("pauseEventStream")
    .setPosition(260,100)
    .setSize(130,20)
    .setLabel("Pause Event Stream");
 
  startEventStream = p5.addButton("stopEventStream")
    .setPosition(420,100)
    .setSize(130,20)
    .setLabel("Stop Event Stream");
  

  p5.addSlider("GainSlider")
  .setPosition(100,140)
  .setSize(450,20)
  .setRange(0,100)
  .setValue(40)
  .setLabel("Volume");



  p5.addSlider("CutoffSlider")
    .setPosition(100,180)
    .setSize(450,20)
    .setRange(40,20000)
    .setValue(4000)
    .setLabel("Cutof Freq");

  //END event streams

//START modify for text to speech for different mode type
  p5.addButton("onYogaMode")
    .setPosition(100 ,60)
    .setSize(100, 20)
    .setLabel("On Yoga Mode")
    .activateBy((ControlP5.RELEASE));
  
  p5.addButton("onMeditationMode")
    .setPosition(230 ,60)
    .setSize(100, 20)
    .setLabel("On Meditation Mode")
    .activateBy((ControlP5.RELEASE));

  p5.addButton("onHeartRateMode")
    .setPosition(360 ,60)
    .setSize(100, 20)
    .setLabel("On Heart Rate Mode")
    .activateBy((ControlP5.RELEASE));

  p5.addButton("onReminderMode")
    .setPosition(490 ,60)
    .setSize(100, 20)
    .setLabel("On Reminder Mode")
    .activateBy((ControlP5.RELEASE));


  lpFilter.addInput(alertSound);
  lpFilter.addInput(yogaSound);  
  lpFilter.addInput(meditationSound);
  lpFilter.addInput(heartRateSound);
  masterGain.addInput(lpFilter);
  
  ac.out.addInput(masterGain);
  ac.start();
}

void startEventStream(int value) {//same
  //loading the event stream, which also starts the timer serving events
  notificationServer.loadEventStream(eventDataJSON);
}

void pauseEventStream(int value) {//same
  //loading the event stream, which also starts the timer serving events
  notificationServer.pauseEventStream();
}

void stopEventStream(int value) {//same
  //loading the event stream, which also starts the timer serving events
  notificationServer.stopEventStream();
}

void draw() {
  //this method must be present (even if empty) to process events such as keyPressed()  
  textSize(13);
  fill(255);
  text("MODE: ", 30, 36);
  text("FOCUS MODE: ", 5, 76);
  text("EVENT STREAM: ", 2, 116);
  
}

void keyPressed() {//same
  //example of stopping the current event stream and loading the second one
  if (key == RETURN || key == ENTER) {
    notificationServer.stopEventStream(); //always call this before loading a new stream
  }
}

//in your own custom class, you will implement the NotificationListener interface 
//(with the notificationReceived() method) to receive Notification events as they come in
class MyNotificationListener implements NotificationListener {
  
  public MyNotificationListener() {
    //setup here
  }
  
  //this method must be implemented to receive notifications
  public void notificationReceived(Notification notification) { 
    println("Test >>>>>" + notification);
    lpFilter.setType(BiquadFilter.AP);
    println("<Example> " + notification.getType().toString() + " notification received at " 
    + Integer.toString(notification.getTime()) + " ms");
    
    String debugOutput = ">>> ";
    int eventPriority = notification.getPriority();
    String message = "";
    int heartRate = 0;
    stopAllSounds();
    
    switch (notification.getType()) {
      case Yoga:
        debugOutput += "Yoga moved: ";
        message = notification.getMessage();
        yogaSound.start(0);
        break;
      case Meditation:
        debugOutput += "Meditation: ";
        message = notification.getMessage();
        meditationSound.start(0);
        break;
      case HeartRate:
        debugOutput += "Heart rate: ";
        message = notification.getMessage();
        heartRateSound.start(0);
        break;
      case Reminder:
        debugOutput += "Message: ";
        message = notification.getMessage();
        ttsExamplePlayback(message);
        break;
    }
    debugOutput += notification.toString();
    println("The message is >>>>" + message);
     if (priority >= eventPriority && !notification.getType().toString().equals("Reminder")) {
      stopAllSounds();
      heartRate = notification.getHeartRate();
      if (eventPriority == 3 && heartRate >= 105) {
        lpFilter.setType(BiquadFilter.HP);
         alertSound.start(0);
      }
      println("message is >>>>" + message);
      ttsExamplePlayback(message);
    }
    
    
   //You can experiment with the timing by altering the timestamp values (in ms) in the exampleData.json file
    //(located in the data directory)
  }
}

void ttsExamplePlayback(String inputSpeech) {
  //create TTS file and play it back immediately
  //the SamplePlayer will remove itself when it is finished in this case
  
  String ttsFilePath = ttsMaker.createTTSWavFile(inputSpeech);
  println("File created at " + ttsFilePath);
  
  //createTTSWavFile makes a new WAV file of name ttsX.wav, where X is a unique integer
  //it returns the path relative to the sketch's data directory to the wav file
  
  //see helper_functions.pde for actual loading of the WAV file into a SamplePlayer
  
  SamplePlayer sp = getSamplePlayer(ttsFilePath, true); 
  //true means it will delete itself when it is finished playing
  //you may or may not want this behavior!
  
  ac.out.addInput(sp);
  sp.setToLoopStart();
  sp.start();
  println("TTS: " + inputSpeech);
}

//Modes
public void Yoga(int value) {
  meditationSound.pause(true);
  heartRateSound.pause(true);
  yogaSound.setToLoopStart();
  yogaSound.start();
}

public void Meditation(int value) {
  yogaSound.pause(true);
  heartRateSound.pause(true);
  meditationSound.setToLoopStart();
  meditationSound.start();
}

public void HeartRate(int value) {
  yogaSound.pause(true);
  meditationSound.pause(true);
  heartRateSound.setToLoopStart();
  heartRateSound.start();
}

public void Reminder(int value) {
  yogaSound.pause(true);
  meditationSound.pause(true);
  heartRateSound.pause(true); 
  ttsExamplePlayback("Here's a friendly reminder to do your practice");
}

void onYogaMode(int value) {
  priority = 1;   
}
void onMeditationMode(int value) {
  priority = 2;   
}
void onHeartRateMode(int value) {
  priority = 3;   
}

void onReminderMode(int value) {
  priority = 4;   
}

public void GainSlider(float value) {
masterGain.setGain(value/100.0);
}

void stopAllSounds() {
    yogaSound.pause(true);
    meditationSound.pause(true);
    heartRateSound.pause(true); 
    alertSound.pause(true);
}

public void CutoffSlider(float value) {
cutoffGlide.setValue(value);
}
