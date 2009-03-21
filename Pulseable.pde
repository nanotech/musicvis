abstract class Pulseable {

  public int id;
  public float x;
  public float y;
  public boolean alive = true;
  public int age = 0;

  protected int velocity;
  protected Pulser pulser;

  public Pulseable(Pulser _pulser, int _velocity) {
    pulser = _pulser;
    velocity = _velocity;
    reset();
  }

  public void reset() {
    int padding = 100;
    x = random(-wCenter+padding, wCenter-padding);
    y = random(-hCenter+padding, hCenter-padding);
  }

  public void draw() {}

  protected void die() {
    alive = false;
    pulser.slots = append(pulser.slots, id);
  }

}
