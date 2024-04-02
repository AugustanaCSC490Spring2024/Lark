
import 'package:cloud_firestore/cloud_firestore.dart';

class Bets {
  final String userid;
  final String city;
  final String date;
  final int predictedTemp;
  bool complete;
  final double wager;
  final double expectedEarning;

  Bets(this.userid, this.city, this.date, this.predictedTemp,
      this.complete, this.wager, this.expectedEarning){
  }

Future<int> getNumberOfBets() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    .collection("Incomplete Bets")
      .doc(userid)
      .collection("Bets")
      .get();

  return querySnapshot.size;
}

  factory Bets.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Bets(
      data?['userId'] ?? "", // Providing a default value if data is null
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
      "userId": userid,
      "city": city,
      "date": date,
      "predictedTemp": predictedTemp,
      "complete": complete,
      "wager": wager,
      "expectedEarning": expectedEarning,
    };
  }


}