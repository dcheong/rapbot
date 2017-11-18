class DatamuseAPI {
  public static final String NUM_SYLLABLES = "numSyllables";
  public static final String TAGS = "tags";
  public static final String WORD = "word";
  public static final String SCORE = "score";
  
  private final String BASE_API = "http://api.datamuse.com/words?";
  private final String AND = "&";
  private final String GET_RHYMES = "rel_rhy=";
  private final String GET_RELATED = "ml=";
  private final String GET_PREV = "rc=";
  // p = parts of speech (n,v,a etc.) s = syllable count
  private final String METADATA = "md=ps";
  
  private String call;
  
  public DatamuseAPI() {
    call = BASE_API;
  }
  public DatamuseAPI and() {
    call += AND;
    return this;
  }
  public DatamuseAPI rhymes(String root) {
    call += GET_RHYMES + root;
    return this;
  }
  public DatamuseAPI related(String root) {
    call += GET_RELATED + root;
    return this;
  }
  public DatamuseAPI previous(String root) {
    call += GET_PREV + root;
    return this;
  }
  public JSONArray fetch() {
    return loadJSONArray(call + AND + METADATA);
  }
}