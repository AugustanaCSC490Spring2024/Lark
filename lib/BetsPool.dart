import 'package:cloud_firestore/cloud_firestore.dart';

class BetsPool{
  String zipCode;
  String date;
  double totalWins;
  Map<String,dynamic> userTemp;
  Map<String, dynamic> userMoney;
  String creator;
  String time;
  Map<String, dynamic>? winners;
  BetsPool(this.zipCode, this.date, this.time,this.totalWins, this.userMoney, this.userTemp, this.creator,{this.winners}){
  }

  factory BetsPool.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
    ){
  final data = snapshot.data();
  return BetsPool(
    data?['zipCode'] ?? "",
    data?['date'] ?? "",
    data?['time']?? '',
    data?['totalWins'] ?? 0,
    data?['userMoney'] ?? {},
    data?['userTemp']?? {},
    data?['creator'] ?? "user1",
    winners: data?['winners']
  );
}

  Map<String, dynamic> toFirestore() {
    return {
      "zipCode": this.zipCode,
      "date": date,
      "totalWins": totalWins,
      "userMoney": userMoney,
      "userTemp": userTemp,
      "creator": creator,
      'time': time,
      'winners': winners
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