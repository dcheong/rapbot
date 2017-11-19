import controlP5.*;
import java.util.*;
import guru.ttslib.*;
import java.util.ArrayList;

PFont arial12;
PFont arial20;

ControlP5 cp5;
Textfield rhymeSchemeTF;
Textarea rapTA;
Button genButton;
TTS voice;
String rapVerse;
ArrayList<String> wordArray;

String currentScheme;
HashMap<Character, String> schemeMap;
HashMap<String, JSONArray> rhymeMap;
HashMap<String, JSONArray> relatedMap;
Random rng;

void setup() {
  currentScheme = "";
  schemeMap = new HashMap<Character, String>();
  rhymeMap = new HashMap<String, JSONArray>();
  relatedMap = new HashMap<String, JSONArray>();
  rng = new Random();
  rapVerse = "Input a rhyme scheme and words to rhyme with";
  wordArray = new ArrayList<String>();
  voice = new TTS();
  voice.setRate(100f);
  
  arial12 = createFont("arial", 12);
  arial20 = createFont("arial", 20);
  
  size(1600,900);
  
  cp5 = new ControlP5(this);
  rhymeSchemeTF = cp5.addTextfield("rhyme scheme")
                     .setPosition(20,20)
                     .setSize(200,40)
                     .setFont(arial20)
                     .setFocus(true)
                     .setColor(color(255))
                     .setColorCursor(color(255))
                     .setLabel("Rhyme Scheme (ex. ABABC)");
   rhymeSchemeTF.getCaptionLabel().setFont(arial12).toUpperCase(false);
   rapTA = cp5.addTextarea("generated rap")
              .setPosition(300, 10)
              .setSize(1290, 880)
              .setFont(arial20)
              .setLineHeight(24)
              .setColor(color(255))
              .setColorBackground(color(20,20,20));
     
  
  genButton = cp5.addButton("generate")
     .setPosition(240,20)
     .setSize(50,40);
}

void draw() {
  background(0);
  fill(255);
  
  updateScheme();
  updateRoots();
}

public void generate(int theValue) {
  for (Character c : schemeMap.keySet()) {
    String root = schemeMap.get(c);
    if (root == null || root.length() == 0) { continue; }
    if (rhymeMap.get(root) == null) {
      JSONArray rhymes = new DatamuseAPI().rhymes(root).fetch();
      rhymeMap.put(root, rhymes);
    }
    if (relatedMap.get(root) == null) {
      JSONArray related = new DatamuseAPI().related(root).fetch();
      relatedMap.put(root, related);
    }
  }
  StringBuilder sb = new StringBuilder();
  for (int i = 0; i < currentScheme.length(); i++) {
    Character c = currentScheme.charAt(i);
    JSONArray rhymes = rhymeMap.get(schemeMap.get(c));
    if (rhymes.size() == 0) {
      println("no rhymes found for: " + schemeMap.get(c));
      sb.append("/////").append("\n");
      continue;
    }
    JSONObject word = rhymes.getJSONObject(rng.nextInt(rhymes.size()));
    String wordStr = word.getString("word");
    sb.append(chooseRandWordsBackwards(word, 10)).append("\n");
    wordArray.add(wordStr);

    //wordArray.add(chooseRandWordsBackwards(word, 10));
  }
  rapTA.setText(sb.toString());
  rapVerse = sb.toString();
}

public void updateScheme() {
  String newScheme = rhymeSchemeTF.getText();
  if (currentScheme.equals(newScheme)) { return; }
  Set<Character> currentKeySet = new HashSet<Character>(schemeMap.keySet());
  Set<Character> newKeySet = new HashSet<Character>();
  for (int i = 0; i < newScheme.length(); i++) {
    newKeySet.add(newScheme.charAt(i));
  }
  if (currentKeySet.equals(newKeySet)) { 
    currentScheme = newScheme;
    return;
  }
  
  Iterator<Character> keyIter = currentKeySet.iterator();
  while (keyIter.hasNext()) {
    Character c = keyIter.next();
    cp5.remove("word " + c);
    if(!newKeySet.contains(c)) {
      schemeMap.remove(c);
    }
  }
  int counter = 0;
  for (Character c : newKeySet) {
    Textfield newTextfield = cp5.addTextfield("word " + c)
                                .setPosition(20, 100 + counter * 80)
                                .setSize(200, 40)
                                .setFont(arial20)
                                .setColor(color(255))
                                .setColorCursor(color(255));
    if (!currentKeySet.contains(c)) {
      schemeMap.put(c, "");
    } else {
      newTextfield.setText(schemeMap.get(c));
    }
    
    counter++;
  }
  currentScheme = newScheme;
}

public void updateRoots() {
  for (Character c : schemeMap.keySet()) {
    String newVal = cp5.get(Textfield.class, "word " + c).getText();
    schemeMap.put(c, newVal);
  }
}

public String chooseRandWordsBackwards(JSONObject tail, int numSyllables) {
  String tailString = tail.getString(DatamuseAPI.WORD);
  int currSyllables = tail.getInt(DatamuseAPI.NUM_SYLLABLES);
  StringBuilder sb = new StringBuilder(tailString);
  String lastWord = tailString.split(" ")[0];
  while (currSyllables < numSyllables) {
    JSONArray prevs = new DatamuseAPI().previous(lastWord).fetch();
    JSONObject chosenPrev = prevs.getJSONObject(rng.nextInt(prevs.size()));
    sb.insert(0, " ").insert(0, chosenPrev.getString(DatamuseAPI.WORD));
    wordArray.add(0, chosenPrev.getString(DatamuseAPI.WORD));
    currSyllables += chosenPrev.getInt(DatamuseAPI.NUM_SYLLABLES);
    lastWord = chosenPrev.getString(DatamuseAPI.WORD);
    //wordArray.add(lastWord);
  }
  return sb.toString();
}


void keyPressed() {
  if (keyCode == ENTER) {
      print(rapVerse);
    voice.speak(rapVerse);
     //for (String word : wordArray) {
     //  voice.speak(word);
     //}
       
  }
}