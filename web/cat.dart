part of catRules;

class Cat extends Bitmap implements Animatable {
  World world;
  var mapX = 0;
  var mapY = 0;
  var targetX = 0;
  var targetY = 0;
  var age = 0;
  var lastCommandAge = 0;

  Cat(BitmapData bitmapData, this.world) : super(bitmapData) {
    pivotX = width / 2;
    pivotY = height / 2;
    x = pivotX;
    targetX = x;
    y = pivotY;
    targetY = y;
  }

  @override
  bool advanceTime(num time) {
    age = age + time;
    var z = 0.05;
    x = (1 - z) * x + z * targetX;
    y = (1 - z) * y + z * targetY;
    return true;
  }

  tryWalk(int dx, int dy) {
    if (world.canWalk(mapX + dx, mapY + dy) && age > lastCommandAge+0.35) {
      meow();
      lastCommandAge = age;
      mapX = mapX + dx;
      mapY = mapY + dy;
      targetX = targetX + dx * width;
      targetY = targetY + dy * 80;
      if (world.hasStar(mapX, mapY)) {
        world.removeStar(mapX, mapY);
        ground.removeStar();
        purr();
      }
    }
  }

  walkRight() {
    scaleX = 1;
    tryWalk(1, 0);
  }

  walkLeft() {
    scaleX = -1;
    tryWalk(-1, 0);
  }

  walkUp() {
    tryWalk(0, -1);
  }

  walkDown() {
    tryWalk(0, 1);
  }

  meow() {
    resourceManager.getSound('meow').play();
  }

  purr() {
    resourceManager.getSound('purr').play();
  }
}
