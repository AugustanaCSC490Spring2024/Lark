
//import 'dart:ffi';

import 'dart:async';
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

 getExpectedWins(String zipCode, String year, String month, String day, String time, int money, double predictedTemp) async{
   Map<String, String> map = await getMinutelyData(zipCode);
    String date= year +'-'+ month +"-"+day +"T"+time+"Z";
    print(date);
   String? temp = map[date];
   print(map.toString());
   print("This is temp:");
   print(temp);
  //  double zScore = double.parse(temp!);
  // //  zScore = min(zScore, -1*(zScore));
  // //  var normal = Normal();
  // //  var prob = normal.cdf(zScore);
  // //  double odds = 0.9/prob;
  // //  return money*odds;

}


main() async {
var v = await getExpectedWins("61201", "2024", "04", "23", "14:27:00", 100, 21.4);
print(v);
}