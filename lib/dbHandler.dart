
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Bets.dart';

var db = FirebaseFirestore.instance;

final FirebaseAuth auth = FirebaseAuth.instance;


Future<void> setBet(Bets bet) async {
  int numberOfBets = await bet.getNumberOfBets() + 1;
  String betID = numberOfBets.toString();
  print(numberOfBets);
    final docRef = FirebaseFirestore.instance
      .collection("Incomplete Bets")
      .doc(bet.userid)
      .collection("Bets")
      .doc(betID);
  await docRef.set(bet.toFirestore());
}




void newUserCreated(String name) {
  User? user = auth.currentUser;
  String? uid = user?.uid;
  db.collection("Users").doc(uid).set({"UserName": name});
  db.collection("Coin").doc(uid).set({"Coin": 100});
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





