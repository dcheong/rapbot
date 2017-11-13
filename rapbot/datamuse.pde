class DatamuseAPI {
  private final String BASE_API = "http://api.datamuse.com/words?";
  private final String GET_RHYMES = "rel_rhy=";
  private String fetchString;
  public DatamuseAPI() {
    fetchString = BASE_API;
  }
  public DatamuseAPI getRhymes(String root) {
    fetchString = BASE_API + GET_RHYMES + root;
    return this;
  }
  public String[] fetch() {
    String[] jsonResponse = loadStrings(fetchString);
    return jsonResponse;
  }
  
}