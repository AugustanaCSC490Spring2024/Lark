
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Bets.dart';

var db = FirebaseFirestore.instance;

void setBet(Bets bet) async{
  final docRef = db
      .collection("users")
      .withConverter(
    fromFirestore: Bets.fromFirestore,
    toFirestore: (Bets bet, options) => bet.toFirestore(),
  )
      .doc("Bet");
  await docRef.set(bet);
}


