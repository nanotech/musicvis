final class Pulse {

  public int id;
  public float x;
  public float y;
  public float size;
  public boolean alive = true;
  public int age = 0;

  private int[] colors = new int[3];
  private int velocity;
  private int imageId;
  private int peak = 8; // in frames
  private float zoomIncrement = 1.0; // how much to zoom per frame, in pixels
  private final Pulser pulser;

  public Pulse(Pulser _pulser, int _velocity) {
    pulser = _pulser;
    velocity = _velocity;
    reset();
  }

  public void reset() {
    int padding = 100;
    x = random(-wCenter+padding, wCenter-padding);
    y = random(-hCenter+padding, hCenter-padding);
    size = random(120,190);
    
    imageId = random(8) < 1 ? 0 : 1;
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
  
  private void age() {
    if (age++ < peak) {
      fadeIn();
    } else {
      fadeOut();
    }
  }

  private void zoom() {
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
  
  private void fadeOut() {
    boolean colored = false;

    for (int i=0;i<colors.length;i++) {
      if (colors[i] > 0) {
        colors[i] -= 1;
        colored = true;
      }
    }

    if (!colored) die();
  }
 
  private void fadeIn() {
    for (int i=0;i<colors.length;i++) {
      //int m = (i == favorHue) ? 5 : 0;
      int m = 6;
      colors[i] += (int) random(m, 34);
    }
  }

  private void die() {
    alive = false;
    pulser.slots = append(pulser.slots, id);
  }

}
