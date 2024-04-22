// import 'dart:async';
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:objectbox/objectbox.dart';
//
//
// // Define the ObjectBox store
// late Store _store;
//
// void main() async {
//   // Initialize ObjectBox
//   await ObjectBox.init();
//
//   // Open the ObjectBox store
//   _store = await openStore();
//
//   runApp(MaterialApp(
//     home: CoinFallingAnimation(),
//   ));
// }
//
// // Open the ObjectBox store
// Future<Store> openStore() async {
//   return Store(getObjectBoxModel());
// }
//
// // Define the ObjectBox model
// ModelDefinition getObjectBoxModel() {
//   final model = ModelInfo.fromType([Coin]);
//   return ModelDefinition(model);
// }
//
// // Define the Coin entity class
// @Entity()
// class Coin {
//   @Id()
//   int id;
//
//   double positionX;
//   double positionY;
//
//   Coin({required this.positionX, required this.positionY});
// }
//
// class CoinFallingAnimation extends StatefulWidget {
//   @override
//   _CoinFallingAnimationState createState() => _CoinFallingAnimationState();
// }
//
// class _CoinFallingAnimationState extends State<CoinFallingAnimation>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 3),
//     );
//     _controller.repeat();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: List.generate(10, (index) {
//           return _buildCoin(index);
//         }),
//       ),
//     );
//   }
//
//   Widget _buildCoin(int index) {
//     Random random = Random();
//
//     // Retrieve coin data from ObjectBox
//     final coinData = _getCoinDataFromObjectBox(index);
//
//     double startPositionX = coinData.positionX;
//     double startPositionY = coinData.positionY;
//
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         double progress = _controller.value;
//         double endPositionY = MediaQuery.of(context).size.height * progress;
//         double angle = 2 * pi * progress;
//
//         return Transform.translate(
//           offset: Offset(startPositionX, startPositionY + endPositionY),
//           child: Transform.rotate(
//             angle: angle,
//             child: Container(
//               width: 20,
//               height: 20,
//               decoration: BoxDecoration(
//                 color: Colors.amber,
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // Retrieve coin data from ObjectBox
//   Coin _getCoinDataFromObjectBox(int index) {
//     final query = _store.box<Coin>().query().build();
//     final coins = query.find();
//     return coins[index];
//   }
// }


