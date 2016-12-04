import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

ResourceManager resourceManager  = new ResourceManager();

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
    ..addSound('meow', 'meow.ogg');

  resourceManager.load().then((_) {
    stage.addChild(new Ground());

    var cat = new Cat(resourceManager.getBitmapData("cat"));

    stage.onMouseClick.listen((MouseEvent event) {
      cat.walkHorizontal(event.stageX);
    });

    stage.addChild(cat);
    stage.juggler.add(cat);
  });
}

class Ground extends DisplayObjectContainer{
  Ground(){
    for(int row=0; row<8; row++){
      for(int column=0; column<10; column++){
        addTile(column*101, row*80);
      }
    }
  }

  addTile(int tileX, int tileY) {
    var tile = new Bitmap(resourceManager.getBitmapData('stoneTile'));
    tile.x = tileX;
    tile.y = tileY;
    addChild(tile);
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

  walk(targetX, targetY) {
    this.targetX = targetX;
    this.targetY = targetY;
  }

  @override
  bool advanceTime(num time) {
    var z = 0.05;
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
