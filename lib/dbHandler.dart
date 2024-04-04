
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Bets.dart';

var db = FirebaseFirestore.instance;

final FirebaseAuth auth = FirebaseAuth.instance;


Future<bool> setBet(Bets bet) async {

    final docRef = FirebaseFirestore.instance
      .collection("Users")
      .doc(bet.userid)
      .collection("Incomplete Bets");
  await docRef.add(bet.toFirestore());
  return true;
}




void newUserCreated(String name) {
  User? user = auth.currentUser;
  String? uid = user?.uid;
  db.collection("Users").doc(uid).set({"UserName": name, "Coin":100});


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





