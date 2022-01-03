import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Platform extends PositionComponent
    with HasGameRef, HasHitboxes, Collidable {
  final double blockSize;
  final int length;
  String? name;

  Platform({
    required this.blockSize,
    required this.length,
    required Vector2 position,
    this.name,
  }) : super(
          size: Vector2(length * blockSize, blockSize),
          position: position,
          anchor: Anchor.topLeft,
        );

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    addHitbox(HitboxRectangle());
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = Colors.brown[600]!,
      ),
    );
  }

  @override
  String toString() {
    return name ?? super.toString();
  }

  PlatformEdge? getPlatformEdge(
    PositionComponent other,
    Vector2 intersectionPoint,
  ) {
    if (other.anchor != Anchor.bottomLeft) {
      throw Exception(
        'Use Anchor.bottomLeft for the ${other}. '
        'Currently other anchors do not supported for this method',
      );
    }

    final right = x + width;
    final bottom = y + height;
    final double offset = 5;

    if (other.y - other.height < y) {
      final isInXBounds =
          other.x + other.width > x + offset && other.x < x + width - offset;
      if (isInXBounds) {
        return PlatformEdge.top;
      }
    } else if (other.y > bottom) {
      return PlatformEdge.bottom;
    } else if (other.x + other.width > right) {
      return PlatformEdge.right;
    } else if (other.x < x) {
      return PlatformEdge.left;
    }

    return null;
  }
}

enum PlatformEdge { top, left, right, bottom }
