final class Pulser {

  public PImage[] images = new PImage[2];
  private int[] timeline = new int[0];
  public int timelinePos = 0;
  //public int beat = 60000 / bpm;
  public int lastBeat;
  public int[] pulseHistory = new int[0];

  private int lastPulseTime = millis();
  private Pulseable[] pulses = new Pulseable[2000];
  private int[] slots = new int[0];

  public Pulser(int[] _timeline) {
    timeline = _timeline;
    setup();
  }
  public Pulser() {
    setup();
  }

  public void setup() {
    images[0] = loadImage("star.png");
    images[1] = loadImage("flare.png");

    for (int i=pulses.length-1;i>=0;i--) {
      slots = append(slots, i);
    }
  }

  public void run() {
    // Check for the end.

    /*
    if (FRAME - lastBeat >= beat) {
      lastBeat += beat;
    }
    */

    if (timeline.length != 0) {
      if (timelinePos == timeline.length && allDead() == true) exit();

      // Add pulses
      while (timelinePos < timeline.length && FRAME >= timeline[timelinePos]) {
        pulse(0);
        lastPulseTime = FRAME;
        timelinePos++;
      }
    }

    // Draw pulses
    for (int i=0;i<pulses.length;i++) {
      if (pulses[i] != null) {
        pulses[i].draw();
      }
    }

    /*
    PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  // g may change
    GL gl = pgl.beginGL();  // always use the GL object returned by beginGL
    gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA);

    fill(0, map(FRAME-lastBeat, 0, beat, 0, 60));
    rect(-wCenter*2, -hCenter*2, wCenter*4, hCenter*4);

    gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
    pgl.endGL();
    */
  }

  public void add(Pulseable pulse) {
    if (slots.length > 0) {
      pulse.id = slots[slots.length-1];
      pulses[pulse.id] = pulse;
      pulseHistory = append(pulseHistory, FRAME);
      slots = shorten(slots);
    }
  }

  public void pulse(int x) {
    /*
    if (random(5) < 2)
      add(new Trazo(this, x));
    else*/
      add(new Pulse(this, x));
  }

  private boolean allDead() {
    for (int i=0;i<pulses.length;i++) {
      if (pulses[i] != null && pulses[i].alive == true) {
        return false;
      }
    }

    return true;
  }

}
