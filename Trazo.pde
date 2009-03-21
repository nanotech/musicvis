// Originally created by Herbert Spencer.
// http://www.openprocessing.org/visuals/?visualID=1248

boolean outline = false;

final class Trazo extends Pulseable {
  int length, step;
  int start = 1;
  float[][] pos;
  float[] r;
  float[] ang;
  int seed;
  boolean drawing;
  boolean alive = true;
  float grosor = 1.0;

  Trazo(Pulser pulser, int velocity){
    super(pulser, velocity);
  }

  void reset() {
    super.reset();

    length = round(random(100, 200)); // length
    pos = new float[length][2];
    r = new float[length];
    ang = new float[length];
    pos[0][0] = x;
    pos[0][1] = y;
    ang[0] = random(TWO_PI);
    r[0] = 0.1;
    //this.ang = ang;
    drawing = true;
    seed = round(random(3000));
    step = 1;

    for(int i = 1; i < length; i++){
      noiseSeed(seed);
      float fac = map(i, 1, length, 0.3, PI-0.3);
      ang[i] = ang[i-1] + ((noise((float)i/50.0) - 0.5) * 0.5);  
      r[i]   = (r[i-1]   + (noise((float)i/80) - 0.5) * grosor) * sin(fac) + 0.2;
      pos[i][0] = pos[i-1][0] + (cos(ang[i]) * 6);
      pos[i][1] = pos[i-1][1] + (sin(ang[i]) * 6);
    }
  }

  void draw(){
    if (!alive) return;

    if(outline){
      stroke(255, 190);
      noFill();
    }
    else{
      fill(255, 190);
      noStroke();
    }
    int count = (drawing) ? step : length;

    beginShape();

    for(int i = start; i < count; i++){
      float x = pos[i][0] + (cos(ang[i] - HALF_PI) * r[i]);
      float y = pos[i][1] + (sin(ang[i] - HALF_PI) * r[i]);
      curveVertex(x,y);
    }

    curveVertex(pos[count-1][0], pos[count-1][1]);

    for(int i = count-2; i > start; i--){
      float x = pos[i][0] + (cos(ang[i] + HALF_PI) * r[i]);
      float y = pos[i][1] + (sin(ang[i] + HALF_PI) * r[i]);
      curveVertex(x,y);
    }

    endShape();

    if (drawing) {
      step++;

      if(step == length){
        drawing = false;
      } 
    }

    if (length - step < 70) {
      start++;
    }

    if (start >= length) {
      alive = false;
    }
  }
}

/*
void wiggle(){
  for(int i = trazos.length-1; i >= 0; i--){
    Trazo t = trazos[i];
    noiseSeed(t.seed);
    for(int j = 0; j < t.length; j++){
      t.r[j] += (noise((float)millis()/10.0) - 0.5) * 0.5;
      t.pos[j][0] += noise((float)(millis()+t.seed)/50.0) - 0.5;
      t.pos[j][1] += noise((float)(millis()+t.seed*2)/100.0) - 0.5;
    }
  }
}

void wiggle2(){
  for(int i = trazos.length-1; i >= 0; i--){
    Trazo t = trazos[i];
    noiseSeed(t.seed);
    for(int j = 0; j < t.length; j++){
      //t.r[j] += noise((t.r[j]/10.0) - 0.5) * 0.5;
      t.pos[j][0] += noise((t.pos[j][0])/50.0) - 0.5;
      t.pos[j][1] += noise((t.pos[j][1])/50.0) - 0.5;
    }
  }
}

void keyPressed(){
  if(key == 'h'){
    outline = !outline;
  }
  if(key == 'c'){
    trazos = new Trazo[0];
  }
}
*/

/////////////////////////////////////////////

/*
Trazo[] trazos = new Trazo[0];

void setup(){
  size(800, 400);
  smooth();
}

void mouseDragged() {
  trazoate(mouseX, mouseY);
}

void mousePressed() {
  trazoate(mouseX, mouseY);
}

void trazoate(float x, float y) {
  trazos = (Trazo[]) append(trazos, new Trazo(x, y));
}

void draw(){
  background(0);
  for(int i = trazos.length-1; i >= 0; i--){
    trazos[i].trace();
  }

  //if (random(10) < 2) trazoate(random(width), random(height));
  
  if(key == ' ' && keyPressed){
    wiggle();
  }
  if(key == 'x' && keyPressed){
    wiggle2();
  }
}
*/
