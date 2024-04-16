import 'dart:ffi';

import 'Bets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class IncompleteBets extends Bets{

 IncompleteBets( String date, double wager, double expectedEarning, String zipCode, int predictedTemp, String timeOfWager)
      : super(date, wager, expectedEarning, zipCode, predictedTemp, timeOfWager);


 factory IncompleteBets.fromFirestore(
     DocumentSnapshot<Map<String, dynamic>> snapshot,
     SnapshotOptions? options,
     ){
   final data = snapshot.data();
   return IncompleteBets(
       data?['zipCode'] ?? "", // Providing a default value if data is null
       data?['date'] ?? "", // Converting Firestore Timestamp to DateTime
       data?['predictedTemp'] ?? 0, // Providing a default value if data is null
       data?['wager'] ?? 0.0, // Providing a default value if data is null
       data?['expectedEarning'] ?? 0.0, // Providing a default value if data is null,
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
   };
 }


}
double getOdds(String zipCode, String date, int money){


  return money*2;
}