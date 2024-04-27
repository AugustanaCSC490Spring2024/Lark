
import 'package:cloud_firestore/cloud_firestore.dart';

class Bets {
  final String zipCode;
  final String date;
  final double predictedTemp;
  final double wager;
  final double expectedEarning;
  final String timeOfWager;


  Bets(this.date, this.wager, this.expectedEarning, this.zipCode, this.predictedTemp, this.timeOfWager);


}

