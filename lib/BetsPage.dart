//sources: https://api.flutter.dev/flutter/widgets/GestureDetector-class.html

import 'dart:html';
import 'package:larkcoins/IncompleteBets.dart';

import 'logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:larkcoins/dbHandler.dart';
import 'HomePage.dart' ;

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
  final List<String> images = [
    'Icon-192.png',
    'Icon-512.png',
    'Icon-192.png',
    // Add more image paths as needed
  ];
  TextEditingController _locationController = TextEditingController();
  TextEditingController _dayController = TextEditingController();
  TextEditingController _lowRangeController = TextEditingController();
  TextEditingController _highRangeController = TextEditingController();
  final _betAmountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double calculateWinnings() {
    double betAmount = double.tryParse(_betAmountController.text) ?? 0.0;

    double winnings = betAmount * 2 ;

    return winnings;
  }
  void clearBetAmount() {
    _betAmountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(leading: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
        child: TopLeftLogo(),
      )),



      backgroundColor: Color(0xffcdffd8),
      body: Form(

        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),


            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,


              children: [
                Text(
                  'Please place your bets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),

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
                      child: TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: const OutlineInputBorder(),
                          suffixIcon:  Icon(Icons.location_on),
                          contentPadding: EdgeInsets.symmetric(vertical: 10 , horizontal: 10),
                          ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },

                        ),
                    ),
                    SizedBox(width: screenSize.width * 0.05),
                    SizedBox(
                      width: screenSize.width * 0.3,
                      child: TextFormField(
                        controller: _dayController,
                        decoration: const InputDecoration(
                          labelText: 'Day',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        ),
                        readOnly: true,
                        onTap: () async{
                          final DateTime tomorrow = DateTime.now().add(Duration(days: 1));
                          final DateTime maxSelectableDate = DateTime.now().add(const Duration(days: 6));

                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: tomorrow,
                            firstDate: tomorrow,
                            lastDate: maxSelectableDate,
                          );
                          if (picked != null){
                            String date = picked.toString();
                            date = date.substring(0,10);
                            _dayController.text = date;
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a date';
                          }
                          return null;
                        },
                        ),
                    ),

                    ],
            ),
                // SizedBox(height: screenSize.height * 0.05),
                //     const Text(
                //       'What do you want to bet on today?',
                //       style: TextStyle(
                //         fontSize: 20.0,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),

                    // SizedBox(
                    //   width: screenSize.width * 0.3,
                    //   child: TextField(
                    //     controller: _highRangeController,
                    //     decoration: const InputDecoration(
                    //       border: OutlineInputBorder(),
                    //       contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    //     ),
                    //   ),
                    // ),
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
                    const Text(
                      'Please enter your range',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(

                      children:[

                        SizedBox(
                          width: 180,
                          child: TextFormField(
                            controller: _lowRangeController,
                            decoration: const InputDecoration(
                              border: const OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the low range';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 10.0),
                        const Text(
                          'to',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10.0),
                        SizedBox(
                          width: 180,
                          child: TextFormField(
                            controller: _highRangeController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                            ),
                            validator: (value) {
                            if (value == null || value.isEmpty) {
                            return 'Please enter the high range';
                            }
                            final int lowRange = int.parse(_lowRangeController.text);
                            final int highRange = int.parse(value);
                            if (lowRange >= highRange) {
                              return 'High range must be greater than the low range';
                            }

                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                            },
                          ),
                        ),

                      ],
                    ),
                    const Text(
                      'How much do you want to bet?',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(
                      width: screenSize.width * 0.5,
                      child: FutureBuilder<double>(
                        future: getUserMoney(),
                        builder: (context, snapshot){
                          if(snapshot.connectionState == ConnectionState.waiting){
                            return Container();
                          } else if(snapshot.hasError){
                            return Text("Error: ${snapshot.error}");
                          }else{
                            double currentBalance = snapshot.data ?? 0.0;

                            return TextFormField(
                              controller: _betAmountController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                prefixIcon: Icon(Icons.attach_money),

                              ),

                              validator: (value) {

                                if (value == null || value.isEmpty) {
                                  return 'Please enter the amount you want to bet';
                                }
                                double betAmount = double.tryParse(value) ?? 0.0;
                                if (betAmount > currentBalance){
                                  return 'Insufficient balance. Please top up your account';
                                }
                                return null;
                              },
                            );
                          }
                        }
                      )

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
                    if (_formKey.currentState!.validate()) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Confirm Bet"),
                            content: Text("Are you sure you want to place the bet?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Show a snackbar while processing the bet
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Processing Bet...')),
                                  );
                                  // Place the bet
                                  double winnings = calculateWinnings();
                                  if (uid != null) {
                                    print(uid);

                                    IncompleteBets bets = IncompleteBets('', 1, 2, '', 1, "");
                                      

                                    setBet(bets);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('You successfully placed a bet!')),
                                    );
                                    _locationController.clear();
                                    _dayController.clear();
                                    _lowRangeController.clear();
                                    _highRangeController.clear();
                                    _betAmountController.clear();
                                  } else {
                                    print("NO UID!");
                                  }
                                },
                                child: Text("Place Bet"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text('Place Bets'),
                ),


              ],
            ),

          ),
        ),
      ),
    );
  }
}