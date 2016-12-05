part of catRules;

class Cat extends Bitmap {
  World world;
  var mapX = 0;
  var mapY = 0;
  var busy = false;
  Random random = new Random();

  Cat(BitmapData bitmapData, this.world) : super(bitmapData) {
    pivotX = width / 2;
    pivotY = height / 2;
    x = pivotX;
    y = pivotY;
  }

  tryWalk(int dx, int dy) {
    if (busy) {
      return;
    }
    if (world.canWalk(mapX + dx, mapY + dy)) {
      walk(dx, dy);
    } else if (canJump(dx, dy)) {
      jump(dx, dy);
    } else {
      showNoWay(dx, dy);
    }
  }

  walk(int dx, int dy) {
    if (random.nextInt(10) > 7) {
      meow();
    }
    mapX = mapX + dx;
    mapY = mapY + dy;
    animateMotion(dx, dy);
    tryGetStar();
  }

  tryGetStar() {
    if (world.hasStar(mapX, mapY)) {
      world.removeStar(mapX, mapY);
      ground.removeStar();
      purr();
    }
  }

  bool canJump(int dx, int dy) {
    return (world.hasTree(mapX + dx, mapY + dy) &&
        world.canWalk(mapX + 2 * dx, mapY + 2 * dy) && dy==0);
  }

  jump(int dx, int dy) {
    meow();
    mapX = mapX + 2 * dx;
    mapY = mapY + 2 * dy;
    animateJump(2 * dx, 2 * dy);
    tryGetStar();
  }

  animateMotion(int dx, int dy) {
    busy = true;
    var tween = new Tween(this, 0.4, Transition.easeInOutQuadratic);
    tween.animate.x.by(dx * width);
    tween.animate.y.by(dy * 80);
    tween.onComplete = (() {
      busy = false;
    });
    renderLoop.juggler.add(tween);
  }

  animateJump(int dx, int dy) {
    busy = true;
    var xTween = new Tween(this, 0.4, Transition.easeInOutQuadratic);
    xTween.animate.x.by(dx * width);
    xTween.onComplete = (() {
      busy = false;
    });
    renderLoop.juggler.add(xTween);
    var yTween = new Tween(this, 0.4, Transition.sine);
    yTween.animate.y.by(-80);
    renderLoop.juggler.add(yTween);
  }

  showNoWay(int dx, int dy) {
    busy = true;
    var tween = new Tween(this, 0.2, Transition.sine);
    tween.animate.x.by(dx * width * 0.25);
    tween.animate.y.by(dy * 80 * 0.25);
    renderLoop.juggler.add(tween);
    tween.onComplete = (() {
      busy = false;
    });
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
