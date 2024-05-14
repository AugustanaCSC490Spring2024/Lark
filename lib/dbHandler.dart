
import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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

Future<List<Bets>> getCompleteBets() async{
  List<Bets> betList = await getBetsHelper("Complete Bets");
  return betList.reversed.toList();
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
  betsList.sort();
  return betsList;
}

Future<bool> addUserToBetPool(String betID, BetsPool bp, double temp, int money) async {
  double curUserMoney = await getUserMoney();
  if (money < curUserMoney) {
    addMoney(money * -1);
    bp.addUser(auth.currentUser!.uid, temp, money);
    FirebaseFirestore.instance.collection("IncompletePools").doc(betID).set(
        bp.toFirestore());
    return true;
  }

    return false;

}


Future<Map<String, BetsPool>> getBetPools() async{
  return await getBetPoolsHelper("IncompletePools");
}

Future<Map<String, BetsPool>> getCompletedPools() async{
  Map<String, BetsPool> pool = await getBetPoolsHelper("CompletedPools");
  for(String bet in pool.keys){
    if(!hasParticipatedInPool(pool[bet]!)){
      pool.remove(bet);
    }
  }
  return pool;
}
Future<Map<String, BetsPool>> getBetPoolsHelper(String poolType) async{
  Map<String, BetsPool> pool= {};

  try {
    // Get a reference to the bets collection
    CollectionReference poolCollection = FirebaseFirestore.instance
        .collection(poolType);

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


Future<bool> createPools(String zipCode, String date, String time,double temp, double money ) async{
  User? user = auth.currentUser;
  String? uid = user?.uid;
  final docRef = FirebaseFirestore.instance.collection("IncompletePools");
  final querySnapshot = await docRef.where('creator', isEqualTo: uid).get();
  if(querySnapshot.docs.isNotEmpty) {
    return false;
  }
  addMoney(money*(-1));
  BetsPool bp = BetsPool(zipCode, date,time, money, {uid!:money}, {uid:temp}, uid);
  await docRef.add(bp.toFirestore());
  return true;


}

Future<void> addWatchlist(Map<String, String> zipcodes) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
   String uid = user.uid;
    var watchlistRef = FirebaseFirestore.instance.collection("Users").doc(uid);
    // Add the list of zipcodes as a field in the document
    await watchlistRef.update({"Watchlist": zipcodes});
    print("Watchlist added successfully for user with UID: $uid");
  } else {
    print("User is not authenticated");
  }
}




Future<Map<String, String>> getWatchlist() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String uid = user.uid;
    var watchlistRef = FirebaseFirestore.instance.collection("Users").doc(uid);
    // Retrieve the document data
    var docSnapshot = await watchlistRef.get();
    if (docSnapshot.exists) {
      var docData = docSnapshot.data();
      // Check if 'Watchlist' field exists in the document
      if (docData != null && docData.containsKey('Watchlist')) {
        // Extract and return the 'Watchlist' field value
        var zipcodes = docData['Watchlist'];
        return Map<String, String>.from(zipcodes);
      } else {
        print("Watchlist not found for user with UID: $uid");
        return {};
      }
    } else {
      print("Document not found for user with UID: $uid");
      return {};
    }
  } else {
    print("User is not authenticated");
    return {};
  }

}