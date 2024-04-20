
//import 'dart:ffi';

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:normal/normal.dart';


import 'Bets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'WebApiForWeather.dart';


final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final uid = user?.uid;




class IncompleteBets extends Bets{

 IncompleteBets( String date, double wager, double expectedEarning, String zipCode, double predictedTemp, String timeOfWager)
      : super(date, wager, expectedEarning, zipCode, predictedTemp, timeOfWager);


 factory IncompleteBets.fromFirestore(
     DocumentSnapshot<Map<String, dynamic>> snapshot,
     SnapshotOptions? options,
     ){
   final data = snapshot.data();
   return IncompleteBets(
       data?['date'] ?? "",
       data?['wager'] ?? 0.0,
       data?['expectedEarning'] ?? 0.0,
       data?['zipCode'] ?? "", // Providing a default value if data is null
       data?['predictedTemp'] ?? 0, // Providing a default value if data is null
       data?['timeOfWager'] ?? ""
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
   };
 }


}

Future<double> getExpectedWins(String zipCode, String year, String month, String day, String time, int money, double predictedTemp) async{
   Map<String, String> map = await getMinutelyData(zipCode);
   String date= year +'-'+ month +"-"+day +"T"+time+"Z";
   String? temp = map[date];
   double zScore = (predictedTemp - int.parse(temp!))/1.25;
   zScore = min(zScore, -1*(zScore));
   var normal = Normal();
   var prob = normal.cdf(zScore);
   var odds = 0.9/prob;
   return money*odds;
}