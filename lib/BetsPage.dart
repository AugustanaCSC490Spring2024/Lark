import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:larkcoins/dbHandler.dart';

import 'Bets.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final uid = user?.uid;


void main() {

}


class BetsPage extends StatefulWidget {
  const BetsPage({Key? key}) : super(key: key);

  @override
  BetsPageState createState() => BetsPageState();

}


class BetsPageState extends State<BetsPage> {
  // final List<String> images = [
  //   'Icon-192.png',
  //   'Icon-512.png',
  //   'Icon-192.png',
  //   // Add more image paths as needed
  // ];
  TextEditingController _locationController = TextEditingController();
  TextEditingController _dayController = TextEditingController();
  TextEditingController _lowRangeController = TextEditingController();
  TextEditingController _highRangeController = TextEditingController();
  final _betAmountController = TextEditingController();
  double calculateWinnings() {
    double betAmount = double.tryParse(_betAmountController.text) ?? 0.0;

    double winnings = betAmount * 2;

    return winnings;
  }
  void clearBetAmount() {
    _betAmountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Bets'),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Color(0xffcdffd8),
      body: SingleChildScrollView(
        child: Padding(
        
          padding: const EdgeInsets.all(20.0),
          child: Column(
        
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container(
              //   height: screenSize.height * 0.2,
              //   width: screenSize.width,
              //   child: ListView.builder(
              //     scrollDirection: Axis.horizontal,
              //     itemCount: images.length,
              //     itemBuilder: (context, index) {
              //       return Padding(
              //         padding: const EdgeInsets.all(8.0),
              //         child: Image.asset(images[index]),
              //       );
              //     },
              //   ),
              // ),
        
              // const Text(
              //   'Place Bets',
              //   style: TextStyle(
              //     fontSize: 28.0,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // SizedBox(height: screenSize.height * 0.05),
              Row(
                children:[
        
                  SizedBox(
                    width: screenSize.width * 0.3,
                    child: TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: const OutlineInputBorder(),
                        suffixIcon:  Icon(Icons.location_on),
                        contentPadding: EdgeInsets.symmetric(vertical: 10 , horizontal: 10),
                        ),
                      ),
                  ),
                  SizedBox(width: screenSize.width * 0.05),
                  SizedBox(
                    width: screenSize.width * 0.3,
                    child: TextField(
                      controller: _dayController,
                      decoration: const InputDecoration(
                        labelText: 'Day',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      ),
                      ),
                  ),
        
                  ],
          ),
              SizedBox(height: screenSize.height * 0.05),
                  const Text(
                    'What do you want to bet on today?',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        
                  SizedBox(
                    width: screenSize.width * 0.3,
                    child: TextField(
                      controller: _highRangeController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      ),
                    ),
                  ),
                  // Row(
                  //   children: [
                  //     ElevatedButton(
                  //       onPressed: () {
                  //         // Respond to button press
                  //       },
                  //       child: Text('High'),
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.white,
                  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1.0),
                  //
                  //         ),
                  //     ),
                  //     ),
                  //     SizedBox(width: 20.0),
                  //     ElevatedButton(
                  //       onPressed: () {
                  //         // Respond to button press
                  //       },
                  //       child: Text('Low'),
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.white,
                  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1.0),
                  //
                  //       ),
                  //     ),
                  //     ),
                  //
                  //   ],
                  // ),
                  // const Text(
                  //   'Please enter your range',
                  //   style: TextStyle(
                  //     fontSize: 20.0,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // Row(
                  //
                  //   children:[
                  //
                  //     SizedBox(
                  //       width: 180,
                  //       child: TextField(
                  //         controller: _lowRangeController,
                  //         decoration: const InputDecoration(
                  //           border: const OutlineInputBorder(),
                  //           contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(width: 10.0),
                  //     const Text(
                  //       'to',
                  //       style: TextStyle(
                  //         fontSize: 20.0,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //     SizedBox(width: 10.0),
                  //     SizedBox(
                  //       width: 180,
                  //       child: TextField(
                  //         controller: _highRangeController,
                  //         decoration: const InputDecoration(
                  //           border: OutlineInputBorder(),
                  //           contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  //         ),
                  //       ),
                  //     ),
                  //
                  //   ],
                  // ),
                  const Text(
                    'How much do you want to bet?',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        
                  SizedBox(
                    width: screenSize.width * 0.5,
                    child: TextField(
                      controller: _betAmountController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        prefixIcon: Icon(Icons.attach_money),
        
                      ),
                    ),
                  ),
        
                  SizedBox(height: 20.0),
        
                   Text(
                    'Your potential winnings are: \$${calculateWinnings().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                     double winnings = calculateWinnings();
                      // Respond to button press
                      if(uid != null ){
                        print(uid);
                      Bets bets = Bets(uid!, _locationController.text.toString(),_dayController.text.toString(), 1,false, double.parse(_betAmountController.text),winnings);
                      setBet(bets);
                      }else{
                          print("NO UID!");
                      }
                    },
                    child: Text('Place Bets'),
                  ),
        
            ],
          ),
        ),
      ),
    );
  }
}