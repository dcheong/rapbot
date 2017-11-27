class Speak implements Runnable {
  private TTS voice;
  private String toSpeak;
  public Boolean finished;
  public Speak(String s, float r) {
    toSpeak = s;
    voice = new TTS();
    voice.setRate(r);
    finished = false;
  }
  public void run() {
    voice.speak(toSpeak);
    println("done speaking");
    finished = true;
    //playing = false;
  }
}