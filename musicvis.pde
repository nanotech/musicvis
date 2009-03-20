import javax.media.opengl.*;
import processing.opengl.*;
import processing.video.*;
import promidi.*;

////////////
// CONFIG //
////////////

final static String PULSE_FILE = "pulses.musicvis.txt";
final static String MOVIE_FILE = "musicvis.avi";
final static boolean READ = false; // read saved pulses
final static boolean WRITE = false; // save pulses to a file

// Create a video; you must have a previously recorded PULSE_FILE.
final static boolean RECORD = false;

// Run the app once to get a list of available devices on the console.
int MIDI_DEVICE = 0;

// Screen size
final static int WIDTH  = 1280;
final static int HEIGHT = 720;

////////////////
// END CONFIG //
////////////////

float wCenter;
float hCenter;
int frame = 0;

MovieMaker mm;
MidiIO midiIO;
Pulser pulser;

void setup() {
  size(WIDTH, HEIGHT, OPENGL);
  hint(ENABLE_OPENGL_4X_SMOOTH);
  frameRate(30);
  background(0); // black
  imageMode(CENTER); // image origin is it's center

  wCenter = (width/2);
  hCenter = (height/2);

  if (WRITE || !READ) {
    println("Creating new pulse sequence.");
    pulser = new Pulser();
  } else {
    println("Loading pulse sequence \""+PULSE_FILE+"\".");
    int[] timeline = stringArrayToIntArray(loadStrings(PULSE_FILE));
    pulser = new Pulser(timeline);
  }

  // Create MovieMaker object with size, filename,
  // compression codec and quality, framerate
  if (RECORD) {
    mm = new MovieMaker(this, width, height, MOVIE_FILE,
        30, MovieMaker.MOTION_JPEG_A, MovieMaker.BEST);
  }

  midiIO = MidiIO.getInstance(this);
  midiIO.printInputDevices();
  midiIO.openInput(MIDI_DEVICE,0);

  noStroke();
}

void draw() {
  background(0);
  setup_gl();

  translate(wCenter, hCenter);
  pulser.run();

  if (RECORD) mm.addFrame(); // Add window's pixels to movie
  frame++;
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
  if (RECORD) {
    mm.finish();
  }

  // Convert pulse history to String[] from int[]
  String[] historyStrings = intArrayToStringArray(pulser.pulseHistory);

  if (WRITE) {
    saveStrings(PULSE_FILE, historyStrings);
    println(pulser.pulseHistory);
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