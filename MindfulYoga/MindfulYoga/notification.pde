enum NotificationType { Yoga, Meditation, HeartRate, Reminder }

class Notification {
   
  NotificationType type;
  int time;
  int priority;
  String message;
  String tag;
  int correctness;
  int duration;
  int inhaleDuration;
  int exhaleDuration;
  int heartRate;
  
  public Notification(JSONObject json) {
    this.time = json.getInt("time");
    this.duration = json.getInt("duration");
    this.inhaleDuration = json.getInt("inhaleDuration");
    this.exhaleDuration = json.getInt("exhaleDuration");
    this.heartRate = json.getInt("heartRate");
    
    //time in milliseconds for playback from sketch start
    
    String typeString = json.getString("type");
    
    try {
      this.type = NotificationType.valueOf(typeString);
    }
    catch (IllegalArgumentException e) {
      throw new RuntimeException(typeString + " is not a valid value for enum NotificationType.");
    }
    
    if (json.isNull("tag")) {
      this.tag = "";
    }
    else {
      this.tag = json.getString("tag");      
    }
    
    if (json.isNull("message")) {
      this.message = "";
    }
    else {
      if (json.getString("message").equals("")) {
        this.message = json.getString("tag") + " " + json.getString("location");
      } else {
      this.message = json.getString("message");
      }
    }  
    this.priority = json.getInt("priority");
    //1-4 levels (corresponding with each mode)    
  }
  
  public int getTime() { return time; }
  public NotificationType getType() { return type; }
  public String getMessage() { return message; }
  public String getTag() { return tag; }
  public int getPriority() { return priority; }
  public int getHeartRate() {return heartRate; }
  
  public String toString() {
      String output = getType().toString() + ": ";
      output += "(tag: " + getTag() + ") ";
      output += "(priority: " + getPriority() + ") ";
      output += "(message: " + getMessage() + ") ";
      return output;
    }
}
