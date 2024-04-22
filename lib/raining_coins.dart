import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

//debugged by chatgpt

const int maxCoins = 5000000;

class Coin {
  final Animation<double> topAnimation;
  final Animation<double> rotationAnimation;
  final double left;
  final Duration duration;

  Coin(this.topAnimation, this.rotationAnimation, this.left, this.duration);
}

class RainingCoins extends StatefulWidget {
  @override
  _RainingCoinsState createState() => _RainingCoinsState();
}

class _RainingCoinsState extends State<RainingCoins>
    with TickerProviderStateMixin {
  List<AnimationController> _coinAnimationControllers = [];
  List<Coin> coinList = [];

  @override
  void initState() {
    super.initState();
    _startCoinAnimation();


  }

  @override
  void dispose() {
    _coinAnimationControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _startCoinAnimation() {
    Timer.periodic(Duration(milliseconds: 500), (_) {
      _createCoin();
    });
  }

  void _createCoin() {
    if (coinList.length < maxCoins) {
      double randomLeft =
      Random().nextInt(MediaQuery.of(context).size.width.toInt()).toDouble();
      double randomRotation = Random().nextDouble();

      int randDuration = Random().nextInt(6) + 2;
      Duration coinDuration = Duration(seconds: randDuration);

      final AnimationController animationController = AnimationController(
        vsync: this,
        duration: coinDuration,
      );

      final topAnimation = CurvedAnimation(
        parent: animationController,
        curve: Curves.linear,
      );

      final rotationAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(animationController);

      final coin = Coin(
        topAnimation,
        rotationAnimation,
        randomLeft,
        coinDuration,
      );

      setState(() {
        coinList.add(coin);
        _coinAnimationControllers.add(animationController);
      });

      animationController.forward();

      // Remove the animation controller from the list when animation completes
      animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _coinAnimationControllers.remove(animationController);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: coinList.map((coin) {
        return AnimatedBuilder(
          animation: coin.topAnimation,
          builder: (context, child) {
            return Positioned(
              top: coin.topAnimation.value *
                  MediaQuery.of(context).size.height,
              left: coin.left,
              child: Transform.rotate(
                angle: coin.rotationAnimation.value * 2 * pi,
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

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(),
      body: Center(
        child: RainingCoins(),
      ),
    ),
  ));
}
