/*
Simple modification of https://www.shadertoy.com/view/lssGDj
See also the useful tool provided in thrill-project.com/archiv/coding/bitmap/

The size of the color bin and the size of the symbol can be modifyed pressing
'q', 'w', 'e' or 'r' (see keyPressed function).
press space to enable / disable the shader.
*/

import processing.video.*;
Movie myMovie;

PShader asciiShader;
float symbol_scale = 1;
float color_bin = 1;
boolean enableAscii = true;


void setup() {
  size(800, 600, P2D);
  myMovie = new Movie(this, "walking.mp4");
  myMovie.loop();
  asciiShader = loadShader("frag.glsl", "vert.glsl");
  
  asciiShader.set("resolution", float(width), float(height));
  asciiShader.set("symbol_scale", symbol_scale);
  asciiShader.set("color_bin", color_bin);
}

void draw() {
  background(0);
  asciiShader.set("time", (float)(millis()/1000.0));
  asciiShader.set("mouse", float(mouseX), float(mouseY));
  PShape r = createShape(RECT,0,0, width, height);
  r.setTexture(myMovie);
  if(enableAscii){
    shader(asciiShader);
  }else{
    resetShader();
  }
  shape(r);
}

void movieEvent(Movie m) {
  m.read();
}

void keyPressed(){
  if(key == 'q') symbol_scale = max(1, symbol_scale -1);
  if(key == 'w') symbol_scale++;
  if(key == 'e') color_bin = max(1, color_bin -1);
  if(key == 'r') color_bin++;
  if(key == ' ') enableAscii = !enableAscii;
  asciiShader.set("symbol_scale", symbol_scale);
  asciiShader.set("color_bin", color_bin);
}
