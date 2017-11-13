class DatamuseAPI {
  private final String BASE_API = "http://api.datamuse.com/words?";
  private final String GET_RHYMES = "rel_rhy=";
  public DatamuseAPI() {
  }
  public JSONArray getRhymes(String root) {
    return fetch(BASE_API + GET_RHYMES + root);
  }
  public JSONArray fetch(String call) {
    return loadJSONArray(call);
  }
}