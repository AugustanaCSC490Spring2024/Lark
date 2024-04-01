
import 'package:cloud_firestore/cloud_firestore.dart';

class Bets {
  static int ROLL=1;
  final String userEmail;
  final String city;
  final String date;
  final int predictedTemp;
  bool complete;
  final double wager;
  final double expectedEarning;
  final int id= ROLL;

  Bets(this.userEmail, this.city, this.date, this.predictedTemp,
      this.complete, this.wager, this.expectedEarning, ){
    ROLL ++;
  }



  factory Bets.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Bets(
      data?['userEmail'] ?? "", // Providing a default value if data is null
      data?['city'] ?? "", // Providing a default value if data is null
      data?['date'] ?? "", // Converting Firestore Timestamp to DateTime
      data?['predictedTemp'] ?? 0, // Providing a default value if data is null
      data?['complete'] ?? false, // Providing a default value if data is null
      data?['wager'] ?? 0.0, // Providing a default value if data is null
      data?['expectedEarning'] ?? 0.0, // Providing a default value if data is null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "userEmail": userEmail,
      "city": city,
      "date": date,
      "predictedTemp": predictedTemp,
      "complete": complete,
      "wager": wager,
      "expectedEarning": expectedEarning,
    };
  }


}