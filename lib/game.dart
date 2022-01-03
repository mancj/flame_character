import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_character/platform.dart';
import 'package:flame_character/player.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class TheGame extends FlameGame with KeyboardEvents, HasCollidables {
  late Player _player;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    add(_player = Player(position: Vector2(250, 350), size: Vector2(20, 30)));
    add(
      Platform(
        blockSize: 50,
        length: 10,
        position: Vector2(100, 350),
        name: 'first',
      ),
    );
    add(Platform(
      blockSize: 50,
      length: 2,
      position: Vector2(350, 300),
      name: 'second',
    ));
    add(Platform(
      blockSize: 50,
      length: 2,
      position: Vector2(100, 300),
      name: 'second',
    ));
    add(Platform(
      blockSize: 50,
      length: 2,
      position: Vector2(450, 200),
      name: 'second',
    ));
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is RawKeyDownEvent;

    if (isKeyDown) {
      if (event.physicalKey == PhysicalKeyboardKey.space) {
        _player.jump();
      }
      if (event.physicalKey == PhysicalKeyboardKey.keyD) {
        _player.move(AxisDirection.right);
      }
      if (event.physicalKey == PhysicalKeyboardKey.keyA) {
        _player.move(AxisDirection.left);
      }
    } else if (event.physicalKey == PhysicalKeyboardKey.keyA ||
        event.physicalKey == PhysicalKeyboardKey.keyD) {
      _player.stop();
    }

    return super.onKeyEvent(event, keysPressed);
  }
}
