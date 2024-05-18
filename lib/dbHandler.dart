
import 'dart:async';
import 'dart:convert';
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

String getuserID(){
  User? user = auth.currentUser;
  return user!.uid;
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
Stream<double> getUserMoneyStream() {
  User? user = auth.currentUser;
  String? uid = user?.uid;
  return FirebaseFirestore.instance
      .collection('Users')
      .doc(uid)
      .snapshots()
      .map((snapshot) {
    if (snapshot.exists && snapshot.data() != null) {
      return snapshot.data()!['Coin']?.toDouble() ?? 0.0;
    } else {
      return 0.0;
    }
  });
}

Future<void> addMoney(double money) async{
  User? user = auth.currentUser;
  String? uid = user?.uid;
  final sfDocRef = db.collection("Users").doc(uid);
  db.runTransaction((transaction) async {
    final snapshot = await transaction.get(sfDocRef);
    final updateMoney = snapshot.get("Coin") + money;
    transaction.update(sfDocRef, {"Coin": updateMoney});
  }).then(
        (value) => print("DocumentSnapshot successfully updated!"),
    onError: (e) => print("Error updating document $e"),
  );
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

Future<bool> addUserToBetPool(String betID, double temp, int money) async {
  double curUserMoney = await getUserMoney();
  if (money < curUserMoney) {
    await addMoney(money * -1);

    print("This is the bet id: $betID");
    final sfDocRef = db.collection("IncompletePools").doc(betID);


     db.runTransaction((transaction) async {
      print("Transaction is running");
      final snapshot = await transaction.get(sfDocRef);
      print("got snapshot: $snapshot");

      print(snapshot.toString());



      BetsPool bp = BetsPool.fromFirestore(snapshot , null);
      print("bp = $bp");
      
      bp.addUser(auth.currentUser!.uid, temp, money);


      print("Bets here in add user to bet pool: ${bp.userMoney}" );

      
      
      transaction.update(sfDocRef, {"totalWins": bp.totalWins, "userMoney":bp.userMoney, "userTemp":bp.userTemp});
    })
    .then(
          (value) => print("addUserToBetPool TRANSACTION SUCCEEDED: $value"),
      onError: (e) => print("addUserToBetPool TRANSACTION Error $e"),
    );

    return true;
  }

    return false;

}


Future<Map<String, BetsPool>> getBetPools() async{
  return await getBetPoolsHelper("IncompletePools");
}

Future<List<BetsPool>> getCompletedPools() async{
  Map<String, BetsPool> pool = await getBetPoolsHelper("CompletedPools");
  List<BetsPool> list= [];
  for(String bet in pool.keys){
    if(hasParticipatedInPool(pool[bet]!)){
      list.add(pool[bet]!);
    }
  }
  list.sort();
  return list;
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
  
  if(querySnapshot.docs.length >= 1) {

    return false;
  
  }

  addMoney(money*(-1));
  BetsPool bp = BetsPool("", zipCode, date,time, money, {uid!:money}, {uid:temp}, uid , 0);
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

double getBetsPoolWInnings(BetsPool bp){
  String uid =  FirebaseAuth.instance.currentUser!.uid;
  if(bp.winners!.containsKey(uid)){
    return bp.winners![uid] as double;
  }else{
    return bp.userMoney[uid]*-1 as double;

  }
}