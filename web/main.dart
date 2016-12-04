import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

void main() {
  // setup the Stage and RenderLoop
  var canvas = html.querySelector('#stage');
  canvas.focus();
  var stage = new Stage(canvas);
  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  var resourceManager = new ResourceManager()
    ..addBitmapData("cat", "cat.png")
    ..addSound('meow', 'meow.ogg');

  resourceManager.load().then((_) {
    var cat = new Cat(resourceManager.getBitmapData("cat"), resourceManager);
    cat.x = 400;
    cat.y = 300;

    stage.onKeyDown.listen((KeyboardEvent event) {
      // if(event.keyCode==39){
      cat.walk(cat.x + 10, cat.y = 0);
      // }
    });

    stage.onMouseClick.listen((MouseEvent event) {
      cat.walkHorizontal(event.stageX);
    });

    stage.addChild(cat);
    stage.juggler.add(cat);
  });
}

class Cat extends Bitmap implements Animatable {
  ResourceManager resourceManager;
  var targetX = 0;
  var targetY = 0;

  Cat(BitmapData bitmapData, this.resourceManager) : super(bitmapData) {
    pivotX = width / 2;
    pivotY = height / 2;
    x = pivotX;
    targetX = x;
    y = pivotY;
    targetY = y;
  }

  walk(targetX, targetY) {
    this.targetX = targetX;
    this.targetY = targetY;
  }

  @override
  bool advanceTime(num time) {
    var z = 0.25;
    x = (1 - z) * x + z * targetX;
    y = (1 - z) * y + z * targetY;
    return true;
  }

  walkHorizontal(clickX) {
    if (clickX > x) {
      targetX = targetX + width;
      scaleX = 1;
    }
    if (clickX < x) {
      targetX = targetX - width;
      scaleX = -1;
    }
    meow();
  }

  meow() {
    resourceManager.getSound('meow').play();
  }
}
