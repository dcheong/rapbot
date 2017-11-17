class DatamuseAPI {
  public final String NUM_SYLLABLES = "numSyllables";
  public final String TAGS = "tags";
  public final String WORD = "word";
  public final String SCORE = "score";
  
  private final String BASE_API = "http://api.datamuse.com/words?";
  private final String AND = "&";
  private final String GET_RHYMES = "rel_rhy=";
  private final String GET_RELATED = "ml=";
  private final String GET_PREV = "rc=";
  // p = parts of speech (n,v,a etc.) s = syllable count
  private final String METADATA = "md=ps";
  public DatamuseAPI() {
  }
  public JSONArray getRhymes(String root) {
    return fetch(BASE_API + GET_RHYMES + root + AND + METADATA);
  }
  public JSONArray getRelated(String root) {
    return fetch(BASE_API + GET_RELATED + root + AND + METADATA);
  }
  public JSONArray getFuzzyPrevious(String root) {
    return fetch(BASE_API + GET_PREV + root + AND + METADATA);
  }
  public JSONArray fetch(String call) {
    return loadJSONArray(call);
  }
}