//import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Bets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'WebApiForWeather.dart';


final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final uid = user?.uid;




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
     "userid": uid.toString(),
   };
 }


}
Future<double> getOdds(String zipCode, String date, int money) async{
   Map<String, String> map = await getMinutelyData(zipCode);


  return money*2;
}