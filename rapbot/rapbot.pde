import controlP5.*;
import java.util.*;
import guru.ttslib.*;
import java.util.ArrayList;
import processing.sound.*;
import com.cage.colorharmony.*;

PFont font12;
PFont font20;
PFont font20B;
PFont arial20;
PFont font36;
PFont font36B;

ControlP5 cp5;
Textfield rhymeSchemeTF;
Button genButton;
Slider rateSlider;
TTS voice;
String rapVerse;
ArrayList<String> wordArray;

String currentScheme;
HashMap<Character, String> schemeMap;
HashMap<String, JSONArray> rhymeMap;
HashMap<Character, Integer> schemeColors;
ArrayList<ArrayList<Word>> rap;
ArrayList<Textlabel> textLabels;
ArrayList<Speak> speakList;
int currentSpeaking = 0;
ArrayList<ArrayList<Textlabel>> textLabelGroupings;

ColorHarmony colorHarmony = new ColorHarmony(this);
SoundFile beat;

color[] colors = new color[8];

Random rng;

boolean playing = false;
int startTime;

void setup() {
  currentScheme = "";
  schemeMap = new HashMap<Character, String>();
  rhymeMap = new HashMap<String, JSONArray>();
  schemeColors = new HashMap<Character, Integer>();
  schemeColors.put(' ', color(255));
  rap = new ArrayList<ArrayList<Word>>();
  textLabels = new ArrayList<Textlabel>();
  rng = new Random();
  rapVerse = "Input a rhyme scheme and words to rhyme with";
  wordArray = new ArrayList<String>();
  speakList = new ArrayList<Speak>();
  textLabelGroupings = new ArrayList<ArrayList<Textlabel>>();
  voice = new TTS();
  voice.setRate(100f);
  
  beat = new SoundFile(this, "beat.mp3");
  beat.amp(0.5);
  
  colors = colorHarmony.Triads();
  
  font12 = createFont("Monospaced", 12);
  font20 = createFont("Monospaced", 20);
  font36 = createFont("Monospaced", 36);
  font20B = createFont("Monospaced Bold", 20);
  font36B = createFont("Monospaced Bold", 36);
  arial20 = createFont("arial", 20);
  
  size(1600,900);
  
  cp5 = new ControlP5(this);
  rhymeSchemeTF = cp5.addTextfield("rhyme scheme")
                     .setPosition(20,20)
                     .setSize(200,40)
                     .setFont(arial20)
                     .setFocus(true)
                     .setColor(color(255))
                     .setColorBackground(color(0))
                     .setColorCursor(color(255))
                     .setLabel("Rhyme Scheme (ex. ABABC)");
   rhymeSchemeTF.getCaptionLabel().setFont(font12);
     
  
  genButton = cp5.addButton("generate")
     .setPosition(240,20)
     .setSize(50,40);
     
  rateSlider = cp5.addSlider("speaking rate")
    .setPosition(1400, 20)
    .setSize(100, 20)
    .snapToTickMarks(true)
    .setNumberOfTickMarks(5)
    .setRange(100,300)
    .setValue(200f);
}

void draw() {
  background(0);
  fill(255);
  updateScheme();
  updateRoots();
  if (playing) {
    if (speakList.get(currentSpeaking).finished) {
      if (currentSpeaking == speakList.size() - 1) {
        playing = false;
        speakList.clear();
        dehighlight(currentSpeaking);
        currentSpeaking = 0;
        beat.stop();
      } else {
        Thread t = new Thread(speakList.get(++currentSpeaking));
        t.start();
        highlight(currentSpeaking);
        dehighlight(currentSpeaking - 1);
      }
    }
    
  }
}

public void highlight(int index) {
  for (Textlabel label : textLabelGroupings.get(index)) {
    label.setFont(font36B);
  }
}

public void dehighlight(int index) {
  for (Textlabel label : textLabelGroupings.get(index)) {
    label.setFont(font36);
  }
}

public void generate(int theValue) {
  rap.clear();
  for (Textlabel tl : textLabels) {
    tl.remove();
  }
  textLabels.clear();
  for (Character c : schemeMap.keySet()) {
    String root = schemeMap.get(c);
    if (root == null || root.length() == 0) { continue; }
    if (rhymeMap.get(root) == null) {
      JSONArray rhymes = new DatamuseAPI().rhymes(root).fetch();
      rhymeMap.put(root, rhymes);
    }
  }
  StringBuilder sb = new StringBuilder();
  int currentY = 10;
  for (int i = 0; i < currentScheme.length(); i++) {
    // Each iteration is a line
    ArrayList<Word> phrase = new ArrayList<Word>();
    Character c = currentScheme.charAt(i);
    JSONArray rhymes = rhymeMap.get(schemeMap.get(c));
    if (rhymes.size() == 0) {
      println("no rhymes found for: " + schemeMap.get(c));
      sb.append("/////").append("\n");
      continue;
    }
    JSONObject wordObj = rhymes.getJSONObject(rng.nextInt(rhymes.size()));
    String wordObjString = wordObj.getString(DatamuseAPI.WORD);
    String[] splitWords = wordObjString.split(" ");
    for (int k = 0; k < splitWords.length; k++) {
      Word word = new Word(splitWords[k], c);
      phrase.add(word);
    }
    chooseRandWordsBackwards(wordObj, 10, phrase);
    rap.add(phrase);
    
    int currentX = 300;
    for (int j = 0; j < phrase.size(); j++) {
      Word currWord = phrase.get(j);
      Textlabel newTL = cp5.addTextlabel(i + "-" + j)
                           .setPosition(currentX, currentY)
                           .setFont(font36)
                           .setLineHeight(36)
                           .setText(currWord.getWord())
                           .setColor(schemeColors.get(currWord.getScheme()));
      currentX += currWord.getWord().length() * 26;
      currWord.label = newTL;
      textLabels.add(newTL);
    }
    currentY += 36;
  }
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
    if (!schemeColors.containsKey(c)) {
      schemeColors.put(c, colors[(int)random(8)]);
    }
    Textfield newTextfield = cp5.addTextfield("word " + c)
                                .setPosition(20, 100 + counter * 80)
                                .setSize(200, 40)
                                .setFont(arial20)
                                .setColor(schemeColors.get(c))
                                .setColorBackground(color(0))
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

public void chooseRandWordsBackwards(JSONObject tail, int numSyllables, ArrayList<Word> phrase) {
  int currSyllables = tail.getInt(DatamuseAPI.NUM_SYLLABLES);
  String lastWord = phrase.get(0).getWord();
  while (currSyllables < numSyllables) {
    JSONArray prevs = new DatamuseAPI().previous(lastWord).fetch();
    JSONArray filtered = new JSONArray();
    int count = 0;
    for (int i = 0; i < prevs.size(); i++) {
      if (prevs.getJSONObject(i).getInt(DatamuseAPI.NUM_SYLLABLES) < 5) {
        filtered.setJSONObject(count++, prevs.getJSONObject(i));
      }
    }
    JSONObject chosenPrev = filtered.getJSONObject(rng.nextInt(prevs.size()));
    phrase.add(0, new Word(chosenPrev, ' '));
    currSyllables += chosenPrev.getInt(DatamuseAPI.NUM_SYLLABLES);
    lastWord = chosenPrev.getString(DatamuseAPI.WORD);
  }
}

public String rapToString() {
  StringBuilder sb = new StringBuilder();
  for (ArrayList<Word> phrase : rap) {
    for (Word w : phrase) {
      sb.append(w.getWord());
      sb.append(" ");
    }
    sb.append("\n");
  }
  return sb.toString();
}

public ArrayList<String> rapToStringByLine() {
  ArrayList<String> rapSeperated = new ArrayList<String>();
  //ArrayList<String>returnArr = new String[rap.size()];
  for (int i = 0; i < rap.size(); i++) {
    ArrayList<Textlabel> newGrouping = new ArrayList<Textlabel>();
    int syllable = 0;
    ArrayList<Word> phrase = rap.get(i);
    StringBuilder sb = new StringBuilder();
    for (Word w : phrase) {
      newGrouping.add(w.label);
      syllable += w.getSyllables();
      sb.append(w.getWord());
      sb.append(" ");     
      if (syllable >= 4) {
          println(sb.toString());
          rapSeperated.add(sb.toString());
          sb = new StringBuilder();
          syllable = 0;
          textLabelGroupings.add(newGrouping);
          newGrouping = new ArrayList<Textlabel>();
      }
    }
    if (sb.length() > 0) {
      rapSeperated.add(sb.toString());
      sb = new StringBuilder();
      syllable = 0;
      textLabelGroupings.add(newGrouping);
    }
  }
  return rapSeperated;
}


void keyPressed() {
  if (keyCode == ENTER) {
    //String toSpeak = rapToString();
    ArrayList<String> toSpeak = rapToStringByLine();
    //print(toSpeak);
    //Speak speak = new Speak(toSpeak, 200f);
    for (String s : toSpeak) {
      Speak speak = new Speak(s, rateSlider.getValue());
      speakList.add(speak);
    }
    Thread t = new Thread(speakList.get(0));
    currentSpeaking = 0;
    highlight(0);
    //Thread t = new Thread(speak);
    t.start();
    beat.play();
    playing = true;
    startTime = millis();
    //voice.speak(toSpeak);
    // //for (String word : wordArray) {
    // //  voice.speak(word);
    // //}
    //String[] phrases = rapToStringByLine();
    //for (String phrase : phrases) {
    //  Speak speak = new Speak(phrase, 200f);
    //  Thread t = new Thread(speak);
    //  t.start();
    //}
  }
}