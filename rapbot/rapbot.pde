import controlP5.*;
import java.util.*;

PFont arial12;
PFont arial20;

ControlP5 cp5;
Textfield rhymeSchemeTF;
Textarea rapTA;
Button genButton;
DatamuseAPI datamuse;

String currentScheme;
HashMap<Character, String> schemeMap;
HashMap<String, JSONArray> rhymeMap;
Random rng;

void setup() {
  datamuse = new DatamuseAPI();
  
  currentScheme = "";
  schemeMap = new HashMap<Character, String>();
  rhymeMap = new HashMap<String, JSONArray>();
  rng = new Random();
  
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
    JSONArray rhymes;
    if (rhymeMap.get(root) == null) {
      rhymes = datamuse.getRhymes(root);
      rhymeMap.put(root, rhymes);
    } else {
      rhymes = rhymeMap.get(root);
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
    sb.append(word.getString("word")).append("\n");
  }
  rapTA.setText(sb.toString());
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