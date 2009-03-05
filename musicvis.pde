import javax.media.opengl.*;
import processing.opengl.*;
import processing.video.*;

float wCenter;
float hCenter;

MovieMaker mm;
final static boolean RECORD = false;

Pulser pulser;

void setup() {
  size(1280, 720, OPENGL);
  hint(ENABLE_OPENGL_4X_SMOOTH);
  frameRate(30);
  background(0);
  imageMode(CENTER);

  wCenter = (width/2);
  hCenter = (height/2);

  pulser = new Pulser();
  
  // Create MovieMaker object with size, filename,
  // compression codec and quality, framerate
  if (RECORD) {
    mm = new MovieMaker(this, width, height, "drawing.avi",
        30, MovieMaker.MOTION_JPEG_A, MovieMaker.BEST);
  }
  
  noStroke();
}

void draw() {
  background(0);
  setup_gl();

  translate(width/2, height/2);
  pulser.run();

  if (RECORD) mm.addFrame(); // Add window's pixels to movie
}

class Pulser {
  
  PImage[] images = new PImage[2];
  int lastPulseTime = millis();
  int maxPulses = 2000;
  Pulse[] pulses = new Pulse[maxPulses];
  int[] slots = new int[0];

  public Pulser() {
    images[0] = loadImage("star.png");
    images[1] = loadImage("flare.png");

    for (int i=maxPulses-1;i>=0;i--) {
      slots = append(slots, i);
    }

    for (int i=0;i<slots.length;i++) {
      new Pulse().alive = false;
    }
  }

  public void run() {
    // Add pulses
    if (millis() - lastPulseTime > 20) {
      for (int i=0;i<3;i++) {
        add(new Pulse(this));
      }
      lastPulseTime = millis();
    }

    // Draw pulses
    for (int i=0;i<pulses.length;i++) {
      if (pulses[i] != null) {
        pulses[i].draw();
      }
    }
  }

  public Pulse add(Pulse pulse) {
    if (slots.length > 0) {
      pulse.id = slots[slots.length-1];
      pulses[pulse.id] = pulse;
      slots = shorten(slots);
    }

    return pulse;
  }

}

class Pulse {

  int id;
  float x;
  float y;
  float size;
  int[] colors = new int[3];
  int imageId;
  int age = 0;
  int peak = 10; // in frames
  float zoomIncrement = 1.0; // how much to zoom per frame, in pixels
  boolean alive = true;
  Pulser pulser;

  public Pulse() {
    reset();
  }

  public Pulse(Pulser _pulser) {
    pulser = _pulser;
    reset();
  }

  public void reset() {
    x = random(-wCenter, wCenter);
    y = random(-hCenter, hCenter);
    size = random(120,190);
    
    imageId = random(15) < 1 ? 0 : 1;
  }

  public void draw() {
    if (alive == true) {
      int timeTint = round(sin((float) millis() / 1500) * 3) - 32;
      tint(colors[0], colors[1] + timeTint, colors[2] + timeTint);
      age();
      zoom();
      image(pulser.images[imageId], x, y, size, size);
    }
  }
  
  void age() {
    if (age++ < peak) {
      fadeIn();
    } else {
      fadeOut();
    }
  }

  void zoom() {
    float oldDistance = sqrt(sq(x) + sq(y));

    // Zoomed Width/Height Center
    float zwc = wCenter + zoomIncrement;
    float zhc = hCenter + zoomIncrement;

    // Apply movement zoom.
    x = map(x, -wCenter, wCenter, -zwc, zwc);
    y = map(y, -hCenter, hCenter, -zhc, zhc);

    float newDistance = sqrt(sq(x) + sq(y));

    // Apply size zoom.
    size *= (newDistance-oldDistance)/200 + 1;
  }
  
  void fadeOut() {
    boolean colored = false;

    for (int i=0;i<colors.length;i++) {
      if (colors[i] > 0) {
        colors[i] -= 1;
        colored = true;
      }
    }

    if (!colored) die();
  }
 
  void fadeIn() {
    for (int i=0;i<colors.length;i++) {
      colors[i] += int(random(18));
    }
  }

  void die() {
    alive = false;
    pulser.slots = append(pulser.slots, id);
  }

}

void setup_gl() {
  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  // g may change
  GL gl = pgl.beginGL();  // always use the GL object returned by beginGL

  gl.glDepthMask(false);
  gl.glDisable(GL.GL_DEPTH_TEST);
  gl.glClear(GL.GL_DEPTH_BUFFER_BIT);
  gl.glEnable(GL.GL_BLEND);

  // Fade out old shapes with normal transparency
  /*
  gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA);
  fill(0, 0, 0, 70);
  rect(0, 0, width*2, height*2);
  */

  // Add new shapes with addition transparency
  gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);

  pgl.endGL();
}

void keyPressed() {
  if (RECORD && key == ' ') {
    // Finish the movie if space bar is pressed
    mm.finish();
    // Quit running the sketch once the file is written
    exit();
  }
}
