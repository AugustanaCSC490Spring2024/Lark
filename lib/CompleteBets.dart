import 'Bets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum winLoss {W, L}
class CompleteBets extends Bets {

  winLoss result;

  CompleteBets(String date, double wager, double expectedEarning,
      String zipCode, int predictedTemp, String timeOfWager, this.result)
      : super(
      date, wager, expectedEarning, zipCode, predictedTemp, timeOfWager);


  factory CompleteBets.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,){
    final data = snapshot.data();
    return CompleteBets(
      data?['zipCode'] ?? "",
      // Providing a default value if data is null
      data?['date'] ?? "",
      // Converting Firestore Timestamp to DateTime
      data?['predictedTemp'] ?? 0,
      // Providing a default value if data is null
      data?['wager'] ?? 0.0,

      // Providing a default value if data is null
      data?['winnings'] ?? 0.0,
      // Providing a default value if data is null,
      data?['timeOfWager'] ?? "",
      data?['result'],
    );
  }

//Store it to firestore

  Map<String, dynamic> toFirestore() {
    return {
      "timeOfWager": timeOfWager,
      "date": date,
      "predictedTemp": predictedTemp,
      "wager": wager,
      "winnings": expectedEarning,
      "zipCode": zipCode,
      "result": result,
    };
  }
}