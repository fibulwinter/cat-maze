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
    var title = new TextField(
        "Meow!",
        new TextFormat('Helvetica,Arial', 200, Color.BlueViolet,
            align: TextFormatAlign.CENTER));
    title
      ..x = -1000
      ..y = 750 / 2 - 400 / 2
      ..width = 600
      ..height = 400;
    stage.addChild(title);
    stage.juggler.addChain([
      new Tween(title, 4, Transition.easeOutElastic)
        ..animate.x.to(1010 / 2 - 600 / 2),
      new Tween(title, 1)..animate.alpha.to(0),
    ]);
    cat.y = -100;
    ground.alpha = 0;
    stage.juggler.addChain([
      new Tween(ground, 1)..animate.alpha.to(1),
      new Tween(cat, 1, Transition.easeOutBounce)..animate.y.to(80)
    ]);

    stage.focus = stage;
  });
}

class Star {
  int mapX;
  int mapY;
  Star(this.mapX, this.mapY);
}

class LongestPath {
  int x = 0;
  int y = 0;
  int length = 0;
}

class WorldGenerator {
  makeRandomWorld(World world) {
    while (true) {
      generate(world);
      var path = calculateFurherstPath(world);
      if (path.length > 18) {
        world.stars.clear();
        world.stars.add(new Star(path.x, path.y));

        return;
      }
    }
  }

  generate(World world) {
    var random = new Random();
    for (var i = 1; i < 79; i++) {
      if (random.nextBool()) {
        world.map[i] = '*';
      } else {
        world.map[i] = '.';
      }
    }
  }

  tryWalk(World world, List<int> map, int targetValue, int mapX, int mapY,
      int dx, int dy, LongestPath result) {
    if (world.canWalk(mapX + dx, mapY + dy) &&
        map[mapX + dx + (mapY + dy) * 10] > targetValue + 1) {
      map[mapX + dx + (mapY + dy) * 10] = targetValue + 1;
      result.x = mapX + dx;
      result.y = mapY + dy;
      result.length = targetValue + 1;
    }
  }

  LongestPath calculateFurherstPath(World world) {
    var result = new LongestPath();
    List<int> map = new List.filled(10 * 8, 9999999);
    map[0] = 0;
    for (var targetValue = 0; targetValue < 81; targetValue++) {
      for (var mapY = 0; mapY < 8; mapY++) {
        for (var mapX = 0; mapX < 10; mapX++) {
          var v = map[mapX + mapY * 10];
          if (v == targetValue) {
            tryWalk(world, map, targetValue, mapX, mapY, 0, -1, result);
            tryWalk(world, map, targetValue, mapX, mapY, 0, 1, result);
            tryWalk(world, map, targetValue, mapX, mapY, 1, 0, result);
            tryWalk(world, map, targetValue, mapX, mapY, -1, 0, result);
            tryWalk(world, map, targetValue, mapX, mapY, 2, 0, result);
            tryWalk(world, map, targetValue, mapX, mapY, -2, 0, result);
          }
        }
      }
    }
    return result;
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
