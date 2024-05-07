
import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Bets.dart';
import 'BetsPool.dart';
import 'package:larkcoins/dbHandler.dart';

var db = FirebaseFirestore.instance;

final FirebaseAuth auth = FirebaseAuth.instance;

// check if user is signed/logged in
bool isUserSignedIn() {
  User? user = auth.currentUser;
  return user != null;
}


Future<bool> setBet(Bets bet) async {
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
  return getBetsHelper("Incomplete Bets");
}

Future<List<Bets>> getCompleteBets(){
  return getBetsHelper("Complete Bets");
}

Future<List<Bets>> getBetsHelper(String betType) async {
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
    
       bet = Bets.fromFirestore(documentSnapshot as DocumentSnapshot<Map<String, dynamic>>, null);
       betsList.add(bet);

    }
  } catch (e) {
    print("Error getting all bets: $e");
  }

  return betsList;
}

Future<bool> addUserToBetPool(String betID, BetsPool bp, double temp, int money) async {
  double curUserMoney = await getUserMoney();
  if (money < curUserMoney) {
    addMoney(money * -1);
    bp.addUser(auth.currentUser!.uid, temp, money);
    FirebaseFirestore.instance.collection("Pool").doc(betID).set(
        bp.toFirestore());
    return true;
  }

    return false;

}

Future<Map<String, BetsPool>> getBetPools() async{
  Map<String, BetsPool> pool= {};

  try {
    // Get a reference to the bets collection
    CollectionReference poolCollection = FirebaseFirestore.instance
        .collection("Pool");

    // Get all documents from the collection
    QuerySnapshot querySnapshot = await poolCollection.get();

    // Iterate over the documents and convert each one to a BetPool object
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {

      BetsPool bp = BetsPool.fromFirestore(documentSnapshot as DocumentSnapshot<Map<String, dynamic>>, null);
      pool[documentSnapshot.id] =bp;
    }
  } catch (e) {
    print("Error getting all bets: $e");
  }
  return pool;
}

bool hasParticipatedInPool(BetsPool bp){
  return bp.userMoney.keys.contains(auth.currentUser!.uid);
}









