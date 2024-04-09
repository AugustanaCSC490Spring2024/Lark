import 'Bets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class CompleteBets extends Bets {


 CompleteBets(String city, String date, int predictedTempLow, int predictedTempHigh, double wager, double expectedEarning)
      : super(city, date, predictedTempLow, predictedTempHigh, wager, expectedEarning);

  factory CompleteBets.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, 
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return CompleteBets(
      data?['city'] ?? "",
      data?['date'] ?? "",
      data?['predictedTempLow'] ?? 0,
      data?['predictedTempHigh'] ?? 0,
      data?['wager'] ?? 0.0,
      data?['expectedEarning'] ?? 0.0,
    );
  }

}
