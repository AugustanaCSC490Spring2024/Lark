import 'Bets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class IncompleteBets extends Bets{

 IncompleteBets(String city, String date, int predictedTempLow, int predictedTempHigh, double wager, double expectedEarning)
      : super(city, date, predictedTempLow, predictedTempHigh, wager, expectedEarning);

  factory IncompleteBets.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, 
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return IncompleteBets(
      data?['city'] ?? "",
      data?['date'] ?? "",
      data?['predictedTempLow'] ?? 0,
      data?['predictedTempHigh'] ?? 0,
      data?['wager'] ?? 0.0,
      data?['expectedEarning'] ?? 0.0,
    );
  }


  

}