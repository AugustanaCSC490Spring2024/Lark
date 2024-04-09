
import 'package:cloud_firestore/cloud_firestore.dart';

class Bets {
  final String city;
  final String date;
  final int predictedTempLow;
  final int predictedTempHigh;
  final double wager;
  final double expectedEarning;

  Bets(this.city, this.date, this.predictedTempLow, this.predictedTempHigh,
       this.wager, this.expectedEarning);





  factory Bets.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ){
    final data = snapshot.data();
    return Bets(
      data?['city'] ?? "", // Providing a default value if data is null
      data?['date'] ?? "", // Converting Firestore Timestamp to DateTime
      data?['predictedTempLow'] ?? 0, // Providing a default value if data is null
      data?['predictedTempHigh'] ?? 0,
      data?['wager'] ?? 0.0, // Providing a default value if data is null
      data?['expectedEarning'] ?? 0.0, // Providing a default value if data is null,
    );
  }

  //Store it to firestore 

   Map<String, dynamic> toFirestore() {
    return {
      "city": city,
      "date": date,
      "predictedTempLow": predictedTempLow,
      "predictedTempHigh": predictedTempHigh,
      "wager": wager,
      "expectedEarning": expectedEarning,
    };
  }

}

