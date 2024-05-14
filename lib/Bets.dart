
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:normal/normal.dart';

import 'WebApiForWeather.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final uid = user?.uid;

class Bets implements Comparable<Bets> {
  final String zipCode;
  final String date;
  final double predictedTemp;
  final double wager;
  final double expectedEarning;
  final String timeOfWager;
  bool didWin;
  double? actualTemp;



  Bets(this.date, this.wager, this.expectedEarning, this.zipCode, this.predictedTemp, this.timeOfWager, this.didWin,this.actualTemp);


  factory Bets.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ){
    final data = snapshot.data();
    return Bets(
        data?['date'] ?? "",
        data?['wager'] ?? 0.0,
        data?['expectedEarning'] ?? data?['winnings'],
        data?['zipCode'] ?? "", // Providing a default value if data is null
        data?['predictedTemp'] ?? 0, // Providing a default value if data is null
        data?['timeOfWager'] ?? "",
        data?['result'] ?? false,
        data?['actualTemp']
    );
  }

  //Store it to firestore

  Map<String, dynamic> toFirestore() {
    return {
      "timeOfWager": timeOfWager,
      "date": date,
      "predictedTemp": predictedTemp,
      "wager": wager,
      "expectedEarning": expectedEarning,
      "zipCode": zipCode,
      "userid": uid.toString(),
      "result": didWin,
      "actualTemp": actualTemp,
    };
  }

  @override
  int compareTo(other) {
    if(DateTime.parse(this.date).isBefore(DateTime.parse(other.date))){
      return -1;
    }else{
      return 1;
    }
  }
}

Future<double> getExpectedWins(String zipCode, String day, int money, double predictedTemp) async{
  List<dynamic> list1 = await getDayTemp(zipCode);
  Map<String, String> map =list1.first;
  day = day + map.keys.first.substring(10);
  String? temp = map[day];
  double zScore = (predictedTemp - double.parse(temp!))/4;
  zScore = min(zScore, -1*(zScore));
  var normal = Normal();
  var prob = normal.cdf(zScore);
  double odds = 0.55/prob;
  return double.parse((money*odds).toStringAsFixed(2));

}

