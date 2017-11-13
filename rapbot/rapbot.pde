import controlP5.*;

ControlP5 cp5;

DatamuseAPI rhymeCall;

void setup() {
  size(1600,900);
  PFont font = createFont("arial",20);
  
  cp5 = new ControlP5(this);
  cp5.addTextfield("rhyme scheme")
     .setPosition(20,100)
     .setSize(200,40)
     .setFont(font)
     .setFocus(true)
     .setColor(color(255,255,255))
     ;
  cp5.addButton("generate")
     .setValue(0)
     .setPosition(240,100)
     .setSize(50,40);
     
     rhymeCall = new DatamuseAPI();
}

void draw() {
  background(0);
  fill(255);
  text(cp5.get(Textfield.class,"rhyme scheme").getText(), 360, 130);
}

public void generate(int theValue) {
  println("button event from generate: " + theValue);
  fetchRhymes(cp5.get(Textfield.class,"rhyme scheme").getText());
}

public void fetchRhymes(String root) {
  rhymeCall.getRhymes(root);
  String[] jsonResponse = rhymeCall.fetch();
  for (String s : jsonResponse) {
    println(s);
  }
}