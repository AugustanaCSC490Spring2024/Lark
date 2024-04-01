
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Bets.dart';

var db = FirebaseFirestore.instance;

void setBet(Bets bet) async{
  String betID= bet.id.toString();
  final docRef = db
      .collection("Users").doc(bet.userEmail).collection("Bets")
      .withConverter(
    fromFirestore: Bets.fromFirestore,
    toFirestore: (Bets bet, options) => bet.toFirestore(),
  )
      .doc(betID);
  await docRef.set(bet);
}

void newUserBonus(String email) {
  db.collection("Users").doc(email).set({"Coin": 100});
}

Future<int?> getUserMoney(String email) async {
  final docRef = FirebaseFirestore.instance.collection("Users").doc(email);

  try {
    final DocumentSnapshot doc = await docRef.get();
    final data = doc.data() as Map<String, dynamic>;
    return data["Coin"] as int?;
  } catch (e) {
    return null;
  }
}




