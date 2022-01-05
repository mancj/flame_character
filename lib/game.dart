import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_character/platform.dart';
import 'package:flame_character/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class TheGame extends FlameGame
    with KeyboardEvents, HasCollidables, HasDraggables, HasTappables {
  late Player _player;


  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    // debugMode = true;
    add(ButtonComponent(
        button: TextComponent(
          text: 'delete points',
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
        position: Vector2(20, 20),
        onPressed: () {
          children.whereType<CircleComponent>().forEach((element) {
            remove(element);
          });
        }));
    add(_player = Player(position: Vector2(250, 350), size: Vector2(20, 30)));
    add(
      Platform(
        blockSize: 50,
        length: 10,
        position: Vector2(100, 350),
        name: '1',
      ),
    );
    add(Platform(
      blockSize: 50,
      length: 2,
      position: Vector2(350, 300),
      name: '2',
    ));
    add(Platform(
      blockSize: 50,
      length: 2,
      position: Vector2(100, 300),
      name: '3',
    ));
    add(Platform(
      blockSize: 50,
      length: 2,
      position: Vector2(450, 200),
      name: '4',
    ));

    final knobPaint = Paint()..color = Colors.blue.withAlpha(200);
    final backgroundPaint = Paint()..color = Colors.blue.withAlpha(100);
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
