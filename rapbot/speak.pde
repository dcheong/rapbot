class Speak implements Runnable {
  private TTS voice;
  private String toSpeak;
  public Speak(String s, float r) {
    toSpeak = s;
    voice = new TTS();
    voice.setRate(r);
  }
  public void run() {
    voice.speak(toSpeak);
    println("done speaking");
    playing = false;
  }
}