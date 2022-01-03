import 'dart:collection';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame_character/game.dart';
import 'package:flame_character/platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<TheGame>, HasHitboxes, Collidable {
  static const double movementSpeed = 200;
  static const double fallingSpeed = 40;

  final _velocity = Vector2(0, 0);
  double _landY = 0;
  bool isLanded = true;

  /// Used to smoothly stop the player
  /// by deceleration of moving x velocity
  late Timer _decelerationTimer;

  static const double _jumpHeight = 120;
  late Timer _jumpTimer;
  double _jumpDelta = 0;

  bool _canMoveLeft = true;
  bool _canMoveRight = true;

  bool get isMovingForward => _velocity.x > 0;

  bool get isMovingBack => _velocity.x < 0;

  Player({
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.bottomLeft,
        );

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    addHitbox(HitboxRectangle());
    add(RectangleComponent(size: size));

    _landY = position.y;
    _jumpTimer = Timer(
      .6,
      repeat: false,
      autoStart: false,
    );
    _decelerationTimer = Timer(
      .2,
      onTick: () {
        _velocity.x = 0;
        _decelerationTimer.reset();
      },
      repeat: false,
      autoStart: false,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if ((isMovingForward && _canMoveLeft) || (isMovingBack && _canMoveRight)) {
      if (_decelerationTimer.isRunning()) {
        position.x += _velocity.x * (1 - _decelerationTimer.progress) * dt;
      } else {
        position.x += _velocity.x * dt;
      }
    }

    if (isLanded) {
      position.y += _velocity.y;
    } else if (_jumpTimer.isRunning()) {
      // calculating jump y delta using sin function with pi offset
      _jumpDelta = sin(_jumpTimer.progress * pi) * _jumpHeight;
      position.y = (_landY - _jumpDelta);
    } else {
      position.y += _velocity.y * (dt * 10);
    }
    _jumpTimer.update(dt);
    _decelerationTimer.update(dt);
  }

  void move(AxisDirection direction) {
    _decelerationTimer.stop();
    _decelerationTimer.reset();
    if (direction == AxisDirection.left) {
      _velocity.x = -movementSpeed;
    } else if (direction == AxisDirection.right) {
      _velocity.x = movementSpeed;
    }
  }

  void stop() {
    _decelerationTimer.start();
  }

  void jump() {
    if (!isLanded) return;
    isLanded = false;
    _jumpTimer.reset();
    _jumpTimer.start();
  }

  void setFalling(bool isFalling) {
    _velocity.y = isFalling ? fallingSpeed : 0;
  }

  Platform? standingPlatform;
  Platform? sidePlatform;

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is Platform && other != standingPlatform) {
      final edge = other.getPlatformEdge(this, intersectionPoints.first);
      if (edge == PlatformEdge.top) {
        print('top collision $sidePlatform');
        isLanded = true;
        standingPlatform = other;
        _jumpTimer.stop();
        _jumpTimer.reset();
        _landY = standingPlatform!.y;
        position.y = _landY;
        setFalling(false);
      }
      if (edge == PlatformEdge.bottom) {
        setFalling(true);
        _jumpTimer.stop();
        _jumpTimer.reset();
      }
      if ((edge == PlatformEdge.left || edge == PlatformEdge.right) &&
          other != sidePlatform) {
        sidePlatform = other;
        print('side collision $sidePlatform');
        _jumpTimer.stop();
        _jumpTimer.reset();
        isLanded = standingPlatform != null;
        _canMoveRight = edge == PlatformEdge.left;
        _canMoveLeft = edge == PlatformEdge.right;
      }
    }
  }

  @override
  void onCollisionEnd(Collidable other) {
    super.onCollisionEnd(other);
    if (other is Platform && other == standingPlatform) {
      isLanded = false;
      standingPlatform = null;
      setFalling(true);
    }
    if (other is Platform && other == sidePlatform) {
      sidePlatform = null;
    }
    print('destroy $sidePlatform');
    _canMoveLeft = other != sidePlatform && isLanded;
    _canMoveRight = other != sidePlatform && isLanded;
  }
}