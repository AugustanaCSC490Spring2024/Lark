
import 'package:cloud_firestore/cloud_firestore.dart';

class Bets {
  final String userID;
  final String city;
  final DateTime date;
  final int predictedTemp;
  final bool complete;
  final double wager;
  final double expectedEarning;

  Bets(this.userID, this.city, this.date, this.predictedTemp,
      this.complete, this.wager, this.expectedEarning, );

  factory Bets.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Bets(
      data?['userID'] ?? "", // Providing a default value if data is null
      data?['city'] ?? "", // Providing a default value if data is null
      (data?['date'] as Timestamp).toDate(), // Converting Firestore Timestamp to DateTime
      data?['predictedTemp'] ?? 0, // Providing a default value if data is null
      data?['complete'] ?? false, // Providing a default value if data is null
      data?['wager'] ?? 0.0, // Providing a default value if data is null
      data?['expectedEarning'] ?? 0.0, // Providing a default value if data is null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "userID": userID,
      "city": city,
      "date": date,
      "predictedTemp": predictedTemp,
      "complete": complete,
      "wager": wager,
      "expectedEarning": expectedEarning,
    };
  }
  

}