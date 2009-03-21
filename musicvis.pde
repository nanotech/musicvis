import javax.media.opengl.*;
import processing.opengl.*;
import processing.video.*;
import promidi.*;

// Screen size
int WIDTH  = 1280;
int HEIGHT = 720;

// Shortcuts
float wCenter;
float hCenter;

// Menu
int selection = 0;
PFont font;

// Enviornment settings
int FRAME = 0;
int MIDI_DEVICE = 0;
int MIDI_CHANNEL = 0;
boolean RUNNING = false;
boolean START_RUNNING = false;
boolean DEBUG = false;
boolean RECORD = false;

// Object declarations
MovieMaker mm;
MidiIO midiIO;
Pulser pulser;

void setup() {
  // Don't allow window sizes bigger than the screen.
  if (WIDTH > screen.width) WIDTH = screen.width;
  if (HEIGHT > screen.height) HEIGHT = screen.height;

  size(WIDTH, HEIGHT, OPENGL);
  hint(ENABLE_OPENGL_4X_SMOOTH);
  frameRate(30);
  background(0); // black
  imageMode(CENTER); // image origin is it's center

  wCenter = (width/2);
  hCenter = (height/2);

  midiIO = MidiIO.getInstance(this);

  font = loadFont("Gentium-48.vlw");
  textFont(font);
  noStroke();
}

void postSetup() {
  if (RUNNING) return;
  if (!RECORD) {
    println("Creating new pulse sequence.");
    pulser = new Pulser();
    midiIO.openInput(MIDI_DEVICE, MIDI_CHANNEL);
  } else {
    String pulseFile = selectInput("Select a MusicVis session to load");
    println("Loading session \""+pulseFile+"\".");
    int[] timeline = stringArrayToIntArray(loadStrings(pulseFile));

    println("Creating Pulser");
    pulser = new Pulser(timeline);

    println("Creating MovieMaker object");
    String videoFile = selectOutput("Save the Video");
    mm = new MovieMaker(this, width, height, videoFile + ".avi",
        30, MovieMaker.MOTION_JPEG_A, MovieMaker.BEST);
  }

  println("Done postSetup()");
  RUNNING = true;
}

void keyPressed() {
  if (RUNNING) {
    switch(key) {
      case 'd':
        DEBUG = !DEBUG;
        break;
      case ' ':
        if (!RECORD) pulser.pulse(127);
        break;
    }
  }
  else { // menu
    int value = 0;

    switch(keyCode) {
      case DOWN:
        if (selection < 3) selection++; else selection = 0;
        break;
      case UP:
        if (selection > 0) selection--; else selection = 3;
        break;
      case LEFT:
        value |= -1;
      case RIGHT:
        value |= 1;
      case RETURN:
      case ENTER:
      case ' ':
        actOn(selection, value);
        break;
    }
  }
}

void actOn(int id, int value) {
  if (RUNNING) return;
  switch(id) {
    case 0: RECORD = !RECORD; break;
    case 1:
      if (MIDI_DEVICE + value >= 0 &&
          MIDI_DEVICE + value < midiIO.numberOfInputDevices())
        MIDI_DEVICE += value;
      break;
    case 2: if (MIDI_CHANNEL + value >= 0) MIDI_CHANNEL += value; break;
    case 3: START_RUNNING = true; break;
  }
}

void draw() {
  background(0);

  if (START_RUNNING) {
    postSetup();
  }

  if (RUNNING) {
    translate(wCenter, hCenter);
    setup_gl();
    pulser.run();
    if (RECORD) mm.addFrame(); // Add window's pixels to movie
    FRAME++;
    translate(-wCenter, -hCenter);

    if (DEBUG) {
      text("Frame " + str(FRAME) + " - " + str(round(frameRate)) + " FPS", 20, 50);
    }
  }
  else { // menu
    String[] message = {
      (RECORD) ? "Create Video from Session" : "Record Session",
      midiIO.getInputDeviceName(MIDI_DEVICE),
      "Midi Channel " + str(MIDI_CHANNEL),
      "Begin",
    };

    int lineHeight = 60;
    int messageHeight = ((message.length+1)*lineHeight)/2;

    for (int i=0;i<message.length;i++) {
      if (i == selection) fill(255); else fill(120);
      text(message[i], 50, ((i+1)*lineHeight) + (hCenter - messageHeight));
    }
  }
}

// Fancy OpenGL effects.
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

// Clean up.
void stop() {
  if (RUNNING) {
    if (RECORD) {
      mm.finish();
    }
    else {
      // Convert pulse history to String[] from int[]
      String[] historyStrings = intArrayToStringArray(pulser.pulseHistory);

      String pulseFile = selectOutput("Save your MusicVis session");

      if (pulseFile != null) {
        saveStrings(pulseFile, historyStrings);
      }
    }
  }

  super.stop();
}

void noteOn(
  Note note,
  int deviceNumber,
  int midiChannel
){
  if (note.getCommand() != 144) return;
  int vel = note.getVelocity();
  int pit = note.getPitch();

  pulser.pulse(note.getVelocity());
}

void noteOff( // not implemented
  Note note,
  int deviceNumber,
  int midiChannel
){
  if (note.getCommand() != 128) return;
  int pit = note.getPitch();
}

void programChange( // not implemented
  ProgramChange programChange,
  int deviceNumber,
  int midiChannel
){
  int num = programChange.getNumber();
  println(programChange);
}

//
// Helpers
//

String[] intArrayToStringArray(int[] ints) {
  String[] strings = new String[ints.length];

  for (int i=ints.length-1;i>=0;i--) {
    strings[i] = str(ints[i]);
  }

  return strings;
}

int[] stringArrayToIntArray(String[] strings) {
  int[] ints = new int[strings.length];

  for (int i=strings.length-1;i>=0;i--) {
    ints[i] = int(strings[i]);
  }

  return ints;
}
