import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dbHandler.dart';
// sources :
// https://docs.flutter.dev/ui/animations/tutorial
// https://api.flutter.dev/flutter/dart-async/Timer-class.html
// https://api.flutter.dev/flutter/animation/AnimationController-class.html
// https://www.dhiwise.com/post/unlock-the-power-of-flutter-tween-a-comprehensive-guide


class Coin {
  final Animation<double> topAnimation;
  final Animation<double> rotationAnimation;
  final double horizontalPosition;
  final Duration duration;

  Coin(this.topAnimation, this.rotationAnimation, this.horizontalPosition, this.duration);
}

class RainingCoins extends StatefulWidget {
  @override
  _RainingCoinsState createState() => _RainingCoinsState();
}

class _RainingCoinsState extends State<RainingCoins>
    with TickerProviderStateMixin {
  List<AnimationController> _coinAnimationControllers = [];
  List<Coin> coinList = [];
  bool _isUserSignedIn = false;
  late Timer _coinTimer;

  @override
  void initState() {
    super.initState();
    _checkUserSignIn();
    _startCoinAnimation();
  }

  void _checkUserSignIn() {
    _isUserSignedIn = isUserSignedIn();
  }

  @override
  void dispose() {
    _coinTimer.cancel();
    _coinAnimationControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void setUserSignIn(bool isSignedIn) {
    setState(() {
      _isUserSignedIn = isUserSignedIn();
    });
  }

  void _startCoinAnimation() {
    if (!mounted) {
      return;
    }

    _coinTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!_isUserSignedIn) {
        _createCoin();
      } else {
        _coinTimer.cancel(); // Cancel the timer when the user signs in
      }
    });
  }

  void _createCoin() {
    double randomLeft = Random().nextInt(MediaQuery.of(context).size.width.toInt()).toDouble();
    int randDuration = Random().nextInt(6) + 2;
    Duration coinDuration = Duration(seconds: randDuration);

    final AnimationController animationController = _createAnimationController(coinDuration);

    final topAnimation = _createTopAnimation(animationController);

    final rotationAnimation = _createRotationAnimation(animationController);

    final coin = Coin(
      topAnimation,
      rotationAnimation,
      randomLeft,
      coinDuration,
    );

    _addCoin(coin, animationController);

    animationController.forward();

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _removeCoin(animationController);
      }
    });

  }

  AnimationController _createAnimationController(Duration duration) {
    return AnimationController(
      vsync: this,
      duration: duration,
    );
  }

  Animation<double> _createTopAnimation(AnimationController controller) {
    return CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
    );
  }

  Animation<double> _createRotationAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(controller);
  }

  void _addCoin(Coin coin, AnimationController controller) {
    setState(() {
      coinList.add(coin);
      _coinAnimationControllers.add(controller);
    });
  }

  void _removeCoin(AnimationController controller) {
    setState(() {
      _coinAnimationControllers.remove(controller);

    });
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: coinList.map((coin) {
        return AnimatedBuilder(
          animation: coin.topAnimation,
          builder: (context, child) {
            return Positioned(
              top: coin.topAnimation.value * MediaQuery.of(context).size.height,
              left: coin.horizontalPosition,
              child: Transform.rotate(
                angle: coin.rotationAnimation.value * 5 * pi,
                child: child,
              ),
            );
          },
          child: Container(
            width: 30,
            height: 30,
            child: Image.asset('assets/coin.png'),
          ),
        );
      }).toList(),
    );
  }
}


