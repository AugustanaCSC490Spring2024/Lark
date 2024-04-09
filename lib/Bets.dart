
import 'package:cloud_firestore/cloud_firestore.dart';

class Bets {
  final String userid;
  final String city;
  final String date;
  final int predictedTempLow;
  final int predictedTempHigh;
  bool complete;
  final double wager;
  final double expectedEarning;

  Bets(this.userid, this.city, this.date, this.predictedTempLow, this.predictedTempHigh,
      this.complete, this.wager, this.expectedEarning);



  factory Bets.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Bets(
      data?['userId'] ?? "", // Providing a default value if data is null
      data?['city'] ?? "", // Providing a default value if data is null
      data?['date'] ?? "", // Converting Firestore Timestamp to DateTime
      data?['predictedTempLow'] ?? 0, // Providing a default value if data is null
      data?['predictedTempHigh'] ?? 0,
      data?['complete'] ?? false, // Providing a default value if data is null
      data?['wager'] ?? 0.0, // Providing a default value if data is null
      data?['expectedEarning'] ?? 0.0, // Providing a default value if data is null,
    );
  }

   Map<String, dynamic> toFirestore() {
    return {
      "userId": userid,
      "city": city,
      "date": date,
      "predictedTempLow": predictedTempLow,
      "predictedTempHigh": predictedTempHigh,
      "complete": complete,
      "wager": wager,
      "expectedEarning": expectedEarning,
    };
  }
  
}

