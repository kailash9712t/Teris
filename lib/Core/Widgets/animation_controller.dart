import 'package:flutter/cupertino.dart';

class ButtonAnimationController {
  late AnimationController buttonController;
  late Animation<double> animation;

  ButtonAnimationController(AnimationController controller) {
    buttonController = controller;
    animation = Tween<double>(begin: 1.0 , end : 0.9).animate(CurvedAnimation(parent : buttonController,curve : Curves.linear));
  }

  void onTapDown(_) {
    buttonController.forward();
  }

  void onTapUp(_) {
    buttonController.reverse();
  }

  void onTapCancal() {
    buttonController.reverse();
  }
}
