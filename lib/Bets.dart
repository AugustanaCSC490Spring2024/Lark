
import 'package:cloud_firestore/cloud_firestore.dart';

class Bets {
  final String zipCode;
  final String date;
  final int predictedTemp;
  final double wager;
  final double expectedEarning;
  final String timeOfWager;


  Bets(this.date, this.wager, this.expectedEarning, this.zipCode, this.predictedTemp, this.timeOfWager);



  // factory Bets.fromFirestore(
  //     DocumentSnapshot<Map<String, dynamic>> snapshot,
  //     SnapshotOptions? options,
  //     ){
  //   final data = snapshot.data();
  //   return Bets(
  //     data?['zipCode'] ?? "", // Providing a default value if data is null
  //     data?['date'] ?? "", // Converting Firestore Timestamp to DateTime
  //     data?['predictedTemp'] ?? 0, // Providing a default value if data is null
  //     data?['wager'] ?? 0.0, // Providing a default value if data is null
  //     data?['expectedEarning'] ?? 0.0, // Providing a default value if data is null,
  //     data?['timeOfWager'] ?? ""
  //   );
  // }
  //
  // //Store it to firestore
  //
  //  Map<String, dynamic> toFirestore() {
  //   return {
  //     "timeOfWager": timeOfWager,
  //     "date": date,
  //     "predictedTemp": predictedTemp,
  //     "wager": wager,
  //     "expectedEarning": expectedEarning,
  //     "zipCode": zipCode,
  //   };
  // }

}

