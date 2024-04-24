//sources: https://api.flutter.dev/flutter/widgets/GestureDetector-class.html

import 'dart:html';

import 'IncompleteBets.dart';

import 'package:larkcoins/IncompleteBets.dart';


import 'logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:larkcoins/dbHandler.dart';

import 'package:async/async.dart';

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
  TextEditingController _predictedTempController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  final _betAmountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double _winnings = 0.0;
  TimeOfDay? _selectedTime;
  int _selectedHour = 0;






  Future<void> _selectTime() async {
    final DateTime now = DateTime.now();
    final TimeOfDay initialTime = TimeOfDay(hour: now.hour, minute: 0);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
      initialEntryMode: TimePickerEntryMode.input, // Set entry mode to input

    );

    if (picked != null) {
      setState(() {
        _selectedHour = picked.hour;
        _selectedTime = picked;
      });
    }

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
                          labelText: 'Location(zipcode)',
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
                SizedBox(height: screenSize.height * 0.05),
                // TextFormField(
                // controller: _timeController,
                // decoration: const InputDecoration(
                // labelText: 'Time',
                // border: OutlineInputBorder(),
                // suffixIcon: Icon(Icons.access_time),
                // contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                // ),
                // readOnly: true,
                // onTap: () async {
                // _selectTime();
                // },
                // validator: (value) {
                // if (_selectedTime == null) {
                // return 'Please select a time';
                // }
                // return null;
                // },
                // ),

                // Display the time picker
                ElevatedButton(
                  onPressed: () {
                    _selectTime();
                  },
                  child: Text(_selectedTime != null ? _selectedTime!.format(context) : 'Select Time'),
                ),

                // Validator for the time picker
                if (_selectedTime == null && _formKey.currentState != null)
                  Text(
                    'Please select a time',
                    style: TextStyle(color: Colors.red),
                  ),

                SizedBox(height: screenSize.height * 0.02),
                Text(
                  'Selected Hour: $_selectedHour',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.05),
                const Text(
                  'What do we predict the temperature will be?',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(
                  width: screenSize.width * 0.3,
                  child: TextFormField(
                    controller: _predictedTempController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the predicted temperature';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
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

                Row(
                  children: [
                    Text(
                      'Your potential winnings are: ',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10.0),
                    ElevatedButton(onPressed: () async {

                        double winnings = await getExpectedWins(_locationController.text, _dayController.text, _selectedHour, int.parse(_betAmountController.text), double.parse(_predictedTempController.text),
                        ) as double;
                        setState(() {
                          _winnings = winnings;
                        });
                    },
                        child:const Text('Calculate Winnings')),
                    SizedBox(width: 10.0),
                    Text(
                      'Winnings: $_winnings', // Display the calculated winnings
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),


                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedTime == null) {
                        // Show an error message if time is not selected
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select a time')),
                        );
                      }
                      else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirm Bet"),
                              content: Text(
                                  "Are you sure you want to place the bet?"),
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
                                      SnackBar(
                                          content: Text('Processing Bet...')),
                                    );
                                    // Place the bet

                                    if (uid != null) {
                                      print(uid);


                                      IncompleteBets bets = IncompleteBets(
                                          _dayController.text, double.parse(
                                          _betAmountController.text), _winnings,
                                          _locationController.text, double.parse(
                                          _predictedTempController.text),
                                          getDate(_selectedHour,_dayController.text));


                                      setBet(bets);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text(
                                            'You successfully placed a bet!')),
                                      );
                                      _locationController.clear();
                                      _dayController.clear();
                                      _lowRangeController.clear();
                                      _predictedTempController.clear();
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