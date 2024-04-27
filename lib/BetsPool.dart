import 'package:cloud_firestore/cloud_firestore.dart';

class BetsPool{
  String zipCode;
  String date;
  int totalWins;
  Map<String,dynamic> userTemp;
  Map<String, dynamic> userMoney;

  BetsPool(this.zipCode, this.date, this.totalWins, this.userMoney, this.userTemp){
  }

  factory BetsPool.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
    ){
  final data = snapshot.data();
  return BetsPool(
    data?['zipCode'] ?? "",
    data?['date'] ?? "",
    data?['totalWins'] ?? 0,
    data?['userMoney'] ?? {},
    data?['userTemp']?? {},
  );
}

  Map<String, dynamic> toFirestore() {
    return {
      "zipCode": this.zipCode,
      "date": date,
      "totalWins": totalWins,
      "userMoney": userMoney,
      "userTemp": userTemp
    };
  }

  void addUser(String uid, double temp, int money) {
    if(userMoney.keys.contains(uid)){
      userMoney[uid]=userMoney[uid] +money;
    }else{
      userMoney[uid]= money;
    }
    totalWins += money;
    userTemp[uid]=temp;
  }

}