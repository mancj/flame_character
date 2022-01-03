import 'package:flame/game.dart';
import 'package:flame_character/game.dart';
import 'package:flutter/material.dart';

void main() {
  final game = TheGame();
  runApp(GameWidget(game: game));
}
