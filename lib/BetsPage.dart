import 'Bets.dart';
import 'topNavigationBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:larkcoins/dbHandler.dart';
import 'HomePage.dart';
import 'coin_effect.dart';
import 'dart:convert';

final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final uid = user?.uid;

class BetsPage extends StatefulWidget {
  const BetsPage({Key? key}) : super(key: key);

  @override
  BetsPageState createState() => BetsPageState();
}

class BetsPageState extends State<BetsPage> {
  TextEditingController _locationController = TextEditingController();
  TextEditingController _dayController = TextEditingController();
  TextEditingController _predictedTempController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _betAmountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double _winnings = 0.0;
  TimeOfDay? _selectedTime;
  String _selectedHour = '0';
  bool _showCoinEffect = false;

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
    );

    if (picked != null) {
      setState(() {
        _selectedHour = getDate(picked.hour);
      });
    }
  }

  String? _checkNumericInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    if (double.tryParse(value) == null) {
      return 'Values must consist of numbers only';
    }
    return null;
  }

  void _showBetPlacedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You successfully placed a bet!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          child: const TopNavigation(),
        ),
      ),
      //backgroundColor: Colors.transparent,

    body: Container(

    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [Color(0xffcdffd8), Color(0xff94b9ff)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    ),
    ),


      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please place your bets',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location (zipcode)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.location_on),
                    ),


                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the zipcode';
                      }
                      final numericError = _checkNumericInput(value);
                      if (numericError != null) {
                        return numericError;
                      }

                      return null;
                      },
                  ),

                  SizedBox(height: 20),
                  TextFormField(
                    controller: _dayController,
                    decoration: const InputDecoration(
                      labelText: 'Day',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final DateTime tomorrow = DateTime.now().add(Duration(days: 1));
                      final DateTime maxSelectableDate = DateTime.now().add(const Duration(days: 6));

                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: tomorrow,
                        firstDate: tomorrow,
                        lastDate: maxSelectableDate,
                      );
                      if (picked != null) {
                        String date = picked.toString();
                        date = date.substring(0, 10);
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
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _selectTime();
                    },
                    child: Text("Select Time: $_selectedHour"),
                  ),
                  SizedBox(height: 10),
                  if (_selectedHour == '0' && _formKey.currentState != null)
                    Text(
                      'Please select a time',
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(height: 20),
                  Text(
                    'The selected hour is according UTC timezone (24hr format): $_selectedHour',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'What do we predict the temperature will be?',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
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
                        final numericError = _checkNumericInput(value);
                        if (numericError != null) {
                          return numericError;
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'How much do you want to bet?',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: screenSize.width * 0.5,
                    child: FutureBuilder<double>(
                      future: getUserMoney(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else {
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
                              if (betAmount > currentBalance) {
                                return 'Insufficient balance. Please top up your account';
                              }


                              final numericError = _checkNumericInput(value);
                              if (numericError != null) {
                                return numericError;
                              }

                              return null;
                            },
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20),


                      Text(
                        'Your potential winnings are: ',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              double winnings = await getExpectedWins(
                                _locationController.text,
                                _dayController.text,
                                int.parse(_betAmountController.text),
                                double.parse(_predictedTempController.text),
                              ) as double;
                              setState(() {
                                _winnings = winnings;
                              });
                            },
                            child: Text('Calculate Winnings'),
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            'Winnings: $_winnings', // Display the calculated winnings
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),



                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedHour == '0') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select a time')),
                          );
                        } else {
                          double winnings = await getExpectedWins(
                            _locationController.text,
                            _dayController.text,
                            int.parse(_betAmountController.text),
                            double.parse(_predictedTempController.text),
                          ) as double;
                          setState(() {
                            _winnings = winnings;
                          });

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
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Processing Bet...')),
                                      );
                                      if (uid != null) {
                                        Bets bets = Bets(
                                          _dayController.text,
                                          double.parse(_betAmountController.text),
                                          _winnings,
                                          _locationController.text,
                                          double.parse(_predictedTempController.text),
                                          _selectedHour,
                                          false,
                                        );
                                        setBet(bets);
                                        print("bets stored");


                                        setState(() {
                                          _showCoinEffect = true;
                                        });


                                        _showBetPlacedSnackbar(context);

                                        _locationController.clear();
                                        _dayController.clear();
                                        _predictedTempController.clear();
                                        _betAmountController.clear();
                                        _winnings = 0.0;
                                        _selectedHour = "0";
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
                  if (_showCoinEffect)
                    SizedBox(height: 20),
                ],
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Visibility(
                    visible: _showCoinEffect,
                    child: coinEfffect(),
                  ),
                ),

              ),
            ],
          ),
        ),
      ),
    ));

  }

  String getDate(int hour) {
    if (hour < 10) {
      return "0${hour}:00";
    }
    return "${hour}:00";
  }
}
