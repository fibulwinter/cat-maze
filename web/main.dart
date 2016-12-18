library catRules;

import 'dart:html' as html;
import 'dart:math';
import 'package:stagexl/stagexl.dart';

part 'cat.dart';

ResourceManager resourceManager = new ResourceManager();
Ground ground;
RenderLoop renderLoop = new RenderLoop();

void main() {
  // setup the Stage and RenderLoop
  var canvas = html.querySelector('#stage');
  canvas.focus();
  var stage = new Stage(canvas);
  renderLoop.addStage(stage);

  resourceManager
    ..addBitmapData("cat", "images/cat.png")
    ..addBitmapData("stoneTile", "images/stone.png")
    ..addBitmapData("tree", "images/tree.png")
    ..addBitmapData("star", "images/star.png")
    ..addSound('meow', 'sounds/meow.ogg')
    ..addSound('purr', 'sounds/purr.ogg');

  resourceManager.load().then((_) {
    var world = new World();
    new WorldGenerator().makeRandomWorld(world);

    ground = new Ground(world);
    stage.addChild(ground);

    var cat = new Cat(resourceManager.getBitmapData("cat"), world);

    stage.onKeyDown.listen((KeyboardEvent event) {
      if (event.keyCode == 39) {
        cat.walkRight();
      }
      if (event.keyCode == 37) {
        cat.walkLeft();
      }
      if (event.keyCode == 40) {
        cat.walkDown();
      }
      if (event.keyCode == 38) {
        cat.walkUp();
      }
    });

    stage.addChild(cat);
    stage.focus = stage;
  });
}

class Star {
  int mapX;
  int mapY;
  Star(this.mapX, this.mapY);
}

class WorldGenerator {
  makeRandomWorld(World world) {
    var random = new Random();
    for (var i = 1; i < 79; i++) {
      if (random.nextBool()) {
        world.map[i] = '*';
      } else {
        world.map[i] = '.';
      }
    }
  }
}

class World {
  List<String> map = new List.filled(10 * 8, '.');

  List<Star> stars = [new Star(9, 7)];

  at(int mapX, int mapY) {
    if (mapX < 0 || mapX >= 10 || mapY < 0 || mapY >= 8) {
      return '#';
    } else {
      return map[mapX + 10 * mapY];
    }
  }

  bool hasTree(int mapX, int mapY) {
    return at(mapX, mapY) == '*';
  }

  bool canWalk(int mapX, int mapY) {
    return at(mapX, mapY) == '.' || hasStar(mapX, mapY);
  }

  bool hasStar(int mapX, int mapY) {
    return stars
        .where((star) => star.mapX == mapX && star.mapY == mapY)
        .isNotEmpty;
  }

  removeStar(int mapX, int mapY) {
    stars.removeWhere((star) => star.mapX == mapX && star.mapY == mapY);
  }
}

class Ground extends DisplayObjectContainer {
  var star;

  Ground(World world) {
    for (int row = 0; row < 8; row++) {
      for (int column = 0; column < 10; column++) {
        addTile(column * 101, row * 80, world.hasTree(column, row),
            world.hasStar(column, row));
      }
    }
  }

  addTile(int tileX, int tileY, bool hasTree, bool hasStar) {
    addChild(new Bitmap(resourceManager.getBitmapData('stoneTile'))
      ..x = tileX
      ..y = tileY);
    if (hasTree) {
      addChild(new Bitmap(resourceManager.getBitmapData('tree'))
        ..x = tileX
        ..y = tileY);
    }
    if (hasStar) {
      star = new Bitmap(resourceManager.getBitmapData('star'))
        ..x = tileX
        ..y = tileY;
      addChild(star);
    }
  }

  removeStar() {
    var tween = new Tween(star, 1.0);
    tween.animate.scaleX.to(3.0);
    tween.animate.scaleY.to(3.0);
    tween.animate.alpha.to(0.0);
    tween.animate.rotation.by(6.3);
    tween.onComplete = () {
      removeChild(star);
    };
    renderLoop.juggler.add(tween);
  }
}
