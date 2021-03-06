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
  static const double fallingSpeed = 70;

  final _velocity = Vector2(0, 0);
  double _landY = 0;
  bool isLanded = true;
  Platform? standingPlatform;
  Platform? sidePlatform;

  bool _canMoveLeft = true;
  bool _canMoveRight = true;

  /// Used to smoothly stop the player
  /// by deceleration of moving x velocity
  late Timer _decelerationTimer;

  static const double _jumpHeight = 120;
  late Timer _jumpTimer;
  double _jumpDelta = 0;

  bool get isMovingForward => _velocity.x > 0;

  bool get isMovingBack => _velocity.x < 0;

  late final Vector2 _cameraTarget;

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
    _cameraTarget = Vector2(0, position.y / 1.2);
    gameRef.camera.followVector2(_cameraTarget);

    /*add(
      CircleComponent(
          radius: 4,
          paint: debugPaint,
          position: Vector2(width / 2, height / 2),
          anchor: Anchor.center),
    );*/

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

    if ((isMovingForward && _canMoveRight) || (isMovingBack && _canMoveLeft)) {
      if (_decelerationTimer.isRunning()) {
        position.x += _velocity.x * (1 - _decelerationTimer.progress) * dt;
      } else {
        position.x += _velocity.x * dt;
      }
    }

    if (_jumpTimer.isRunning()) {
      // calculating jump y delta using sin function with pi offset
      _jumpDelta = sin(_jumpTimer.progress * pi) * _jumpHeight;
      position.y = (_landY - _jumpDelta);
    } else if (!isLanded && sidePlatform != null) {
      // sliding side platform
      position.y += (fallingSpeed * dt);
    } else {
      // falling down
      position.y += _velocity.y * (dt * 10);
    }
    _jumpTimer.update(dt);
    _decelerationTimer.update(dt);
    _cameraTarget.x = position.x;
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

  void _stopJumpTimer() {
    _jumpTimer.stop();
    _jumpTimer.reset();
  }

  void setFalling(bool isFalling) {
    _velocity.y = isFalling ? fallingSpeed : 0;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is Platform && other != standingPlatform) {
      final edge = other.getPlatformEdge(this, intersectionPoints);
      if (edge == PlatformEdge.top && other != sidePlatform) {
        isLanded = true;
        standingPlatform = other;
        _stopJumpTimer();
        _landY = standingPlatform!.y;
        position.y = _landY;
        setFalling(false);
      }
      if (edge == PlatformEdge.bottom) {
        // sidePlatform = other;
        setFalling(standingPlatform == null);
        _stopJumpTimer();
      }
      if ((edge == PlatformEdge.left || edge == PlatformEdge.right)) {
        sidePlatform = other;

        _canMoveLeft = edge != PlatformEdge.right;
        _canMoveRight = edge != PlatformEdge.left;

        if (!isLanded && _landY - position.y > 50) {
          _stopJumpTimer();
        }
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
    if (other == sidePlatform) {
      sidePlatform = null;
      _canMoveLeft = true;
      _canMoveRight = true;
    }
  }
}
