import 'dart:html' as html;
import 'dart:math';
import 'package:stagexl/stagexl.dart';

ResourceManager resourceManager = new ResourceManager();

void main() {
  // setup the Stage and RenderLoop
  var canvas = html.querySelector('#stage');
  canvas.focus();
  var stage = new Stage(canvas);
  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  resourceManager
    ..addBitmapData("cat", "cat.png")
    ..addBitmapData("stoneTile", "stone.png")
    ..addBitmapData("tree", "tree.png")
    ..addSound('meow', 'meow.ogg');

  resourceManager.load().then((_) {
    stage.addChild(new Ground());

    var cat = new Cat(resourceManager.getBitmapData("cat"));

    stage.onKeyDown.listen((KeyboardEvent event) {
      if (event.keyCode == 39) {
        cat.walkRight();
        cat.meow();
      }
      if (event.keyCode == 37) {
        cat.walkLeft();
        cat.meow();
      }
      if (event.keyCode == 40) {
        cat.walkDown();
        cat.meow();
      }
      if (event.keyCode == 38) {
        cat.walkUp();
        cat.meow();
      }
    });

    stage.addChild(cat);
    stage.focus = stage;
    stage.juggler.add(cat);
  });
}

class Ground extends DisplayObjectContainer {
  Ground() {
    var random = new Random();
    for (int row = 0; row < 8; row++) {
      for (int column = 0; column < 10; column++) {
        addTile(column * 101, row * 80, random.nextBool());
      }
    }
  }

  addTile(int tileX, int tileY, bool hasTree) {
    addChild(new Bitmap(resourceManager.getBitmapData('stoneTile'))
      ..x = tileX
      ..y = tileY);
      if(hasTree){
        addChild(new Bitmap(resourceManager.getBitmapData('tree'))
          ..x = tileX
          ..y = tileY);
      }
  }
}

class Cat extends Bitmap implements Animatable {
  var targetX = 0;
  var targetY = 0;

  Cat(BitmapData bitmapData) : super(bitmapData) {
    pivotX = width / 2;
    pivotY = height / 2;
    x = pivotX;
    targetX = x;
    y = pivotY;
    targetY = y;
  }

  @override
  bool advanceTime(num time) {
    var z = 0.05;
    x = (1 - z) * x + z * targetX;
    y = (1 - z) * y + z * targetY;
    return true;
  }

  walkRight() {
    targetX = targetX + width;
    scaleX = 1;
  }

  walkLeft() {
    targetX = targetX - width;
    scaleX = -1;
  }

  walkUp() {
    targetY = targetY - 80;
  }

  walkDown() {
    targetY = targetY + 80;
  }

  meow() {
    resourceManager.getSound('meow').play();
  }
}
