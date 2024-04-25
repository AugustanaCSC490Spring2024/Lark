
import 'dart:async';
import 'dart:core';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Bets.dart';
import 'IncompleteBets.dart';
import 'CompleteBets.dart';
import 'package:larkcoins/dbHandler.dart';

var db = FirebaseFirestore.instance;

final FirebaseAuth auth = FirebaseAuth.instance;

// check if user is signed/logged in
bool isUserSignedIn() {
  User? user = auth.currentUser;
  return user != null;
}


Future<bool> setBet(IncompleteBets bet) async {
   User? user = auth.currentUser;
   String? uid = user?.uid;
   double curUserMoney = await getUserMoney();
   if(bet.wager<curUserMoney){
     addMoney(bet.wager*(-1));
     final docRef = FirebaseFirestore.instance
         .collection("Users")
         .doc(uid)
         .collection("Incomplete Bets");
     await docRef.add(bet.toFirestore());
     return true;
   }
  return false;
}





void newUserCreated(String name) {
  User? user = auth.currentUser;
  String? uid = user?.uid;
  db.collection("Users").doc(uid).set({"UserName": name, "Coin":100});

}

void changeUserName(String name){
  User? user = auth.currentUser;
  String? uid = user?.uid;
  db.collection("Users").doc(uid).update({"UserName": name});
}


Future<double> getUserMoney() async {
  User? user = auth.currentUser;
  String? uid = user?.uid;
  final docRef = FirebaseFirestore.instance.collection("Users").doc(uid);
  try {
    final DocumentSnapshot doc = await docRef.get();
    final data = doc.data() as Map<String, dynamic>;
    return data["Coin"] as double;
  } catch (e) {
    return 0;
  }

}

Future<String> getUserName() async{
  User? user = auth.currentUser;
  String? uid = user?.uid;
  final docRef = FirebaseFirestore.instance.collection("Users").doc(uid);

  try {
    final DocumentSnapshot doc = await docRef.get();
    final data = doc.data() as Map<String, dynamic>;
    return data["UserName"] as String;
  } catch (e) {
    return "User1";
  }
}

void addMoney(double money) async{
  User? user = auth.currentUser;
  String? uid = user?.uid;
  double curMoney = await getUserMoney();
  curMoney += money;
  db.collection("Users").doc(uid).update({ "Coin":curMoney});
}

Future<List<Bets>> getIncompleteBets(){
  return getIncompleteBetsHelper("Incomplete Bets");
}

Future<List<CompleteBets>> getCompletBets(){
  return getCompleteBetHelper("Complete Bets");
}

Future<List<CompleteBets>> getCompleteBetHelper(String betType) async {
  User? user = auth.currentUser;
  String? uid = user?.uid;
  List<CompleteBets> betsList = [];
  CompleteBets bet;

  try {
    // Get a reference to the bets collection
    CollectionReference betsCollection = FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .collection(betType);

    // Get all documents from the collection
    QuerySnapshot querySnapshot = await betsCollection.get();

    // Iterate over the documents and convert each one to a Bets object
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
       bet = CompleteBets.fromFirestore(documentSnapshot as DocumentSnapshot<Map<String, dynamic>>, null); 
      betsList.add(bet);

    }
  } catch (e) {
    print("Error getting all bets: $e");
  }

  return betsList;
}


Future<List<Bets>> getIncompleteBetsHelper(String betType) async {
  User? user = auth.currentUser;
  String? uid = user?.uid;
  List<Bets> betsList = [];
  Bets bet;

  try {
    // Get a reference to the bets collection
    CollectionReference betsCollection = FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .collection(betType);

    // Get all documents from the collection
    QuerySnapshot querySnapshot = await betsCollection.get();

    // Iterate over the documents and convert each one to a Bets object
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
    
       bet = IncompleteBets.fromFirestore(documentSnapshot as DocumentSnapshot<Map<String, dynamic>>, null); 
       betsList.add(bet);

    }
  } catch (e) {
    print("Error getting all bets: $e");
  }

  return betsList;
}








