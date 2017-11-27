class Word {
  private int syllables;
  private String word;
  private char scheme;
  public Textlabel label;
  
  public Word(String word, char scheme) {
    this.word = word;
    this.scheme = scheme;
  }
  
  public Word(JSONObject obj, char scheme) {
    this.scheme = scheme;
    syllables = obj.getInt(DatamuseAPI.NUM_SYLLABLES);
    word = obj.getString(DatamuseAPI.WORD);
  }
  
  public int getSyllables() {
    return syllables;
  }
  
  public String getWord() {
    return word;
  }
  
  public char getScheme() {
    return scheme;
  }
  
  public String toString() {
    return word;
  }
}