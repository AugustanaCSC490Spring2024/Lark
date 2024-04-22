import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

const int maxCoins = 50;

class Coin {
  final Animation<double> topAnimation;
  final Animation<double> rotationAnimation;
  final double left;

  Coin(this.topAnimation, this.rotationAnimation, this.left);
}

class coinEfffect extends StatefulWidget {
  @override
  _RainingCoinsState createState() => _RainingCoinsState();
}

class _RainingCoinsState extends State<coinEfffect>
    with TickerProviderStateMixin {
  late AnimationController _rotationAnimationController;
  List<Coin> coinList = [];

  @override
  void initState() {
    super.initState();
    _rotationAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _startCoinAnimation();
  }

  @override
  void dispose() {
    _rotationAnimationController.dispose();
    super.dispose();
  }

  void _startCoinAnimation() {
    _rotationAnimationController.forward().then((_) {
      // Stop creating new coins after animation completes
      Timer.run(() {
        _rotationAnimationController.stop();
      });
    });

    // Setup timer for creating coins
    Timer.periodic(Duration(milliseconds: 500), (_) {
      _createCoins();
    });
  }

  void _createCoins() {
    if (!_rotationAnimationController.isAnimating ||
        coinList.length >= maxCoins) {
      return;
    }

    int num = Random().nextInt(21) + 30;

    for (int i = 0; i < num; i++) {
      double randomLeft =
          Random().nextDouble() * MediaQuery.of(context).size.width;
      double randomRotation = Random().nextDouble();

      final topAnimation = CurvedAnimation(
        parent: _rotationAnimationController,
        curve: Interval(
          0.0,
          Random().nextDouble(),
          curve: Curves.linear,
        ),
      );

      final rotationAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(_rotationAnimationController);

      final coin = Coin(
        topAnimation,
        rotationAnimation,
        randomLeft,
      );

      setState(() {
        coinList.add(coin);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: coinList.map((coin) {
        return AnimatedBuilder(
          animation: _rotationAnimationController,
          builder: (context, child) {
            return Positioned(
              top: coin.topAnimation.value * MediaQuery.of(context).size.height,
              left: coin.left,
              child: Transform.rotate(
                angle: coin.rotationAnimation.value * 2 * pi,
                child: child,
              ),
            );
          },
          child: Container(
            width: Random().nextInt(20) + 26,
            height: Random().nextInt(20) + 26,
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
        child: coinEfffect(),
      ),
    ),
  ));
}
