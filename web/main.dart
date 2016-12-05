import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

ResourceManager resourceManager = new ResourceManager();
Ground ground;

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
    ..addBitmapData("star", "star.png")
    ..addSound('meow', 'meow.ogg')
    ..addSound('purr', 'purr.oga');

  resourceManager.load().then((_) {
    var world = new World();

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
    stage.juggler.add(cat);
  });
}

class Star {
  int mapX;
  int mapY;
  Star(this.mapX, this.mapY);
}

class World {
  String map = """
############
#...*......#
#...*..*...#
#*.**...*..#
#....*..*..#
#....*..*..#
#.......*..#
#....****..#
#....*.....#
############
""";

  List<Star> stars = [new Star(9, 7)];

  at(int mapX, int mapY) {
    if (mapX < 0 || mapX >= 10 || mapY < 0 || mapY >= 8) {
      return '#';
    } else {
      return map.split("#\n#")[mapY + 1][mapX];
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
    removeChild(star);
  }
}

class Cat extends Bitmap implements Animatable {
  World world;
  var mapX = 0;
  var mapY = 0;
  var targetX = 0;
  var targetY = 0;

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
    var z = 0.05;
    x = (1 - z) * x + z * targetX;
    y = (1 - z) * y + z * targetY;
    return true;
  }

  tryWalk(int dx, int dy) {
    if (world.canWalk(mapX + dx, mapY + dy)) {
      mapX = mapX + dx;
      mapY = mapY + dy;
      targetX = targetX + dx * width;
      targetY = targetY + dy * 80;
      if (world.hasStar(mapX, mapY)) {
        world.removeStar(mapX, mapY);
        ground.removeStar();
        purr();
      }
    } else {
      meow();
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
