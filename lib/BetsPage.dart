//sources: https://api.flutter.dev/flutter/widgets/GestureDetector-class.html
import 'Bets.dart';
import 'logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:larkcoins/dbHandler.dart';
import 'HomePage.dart' ;
import 'coin_effect.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  final _betAmountController = TextEditingController();
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

  //location images
  List<String> _imageUrls = [];
  Future<void> fetchImages(String location) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$location&radius=5000&type=point_of_interest&key=YOUR_API_KEY'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _imageUrls.clear();
        for (final result in data['results']) {
          _imageUrls.add(result['urls']['regular']);
        }
      });
    } else {
      throw Exception('Failed to load images');
    }
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
          child: const TopLeftLogo(),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
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
                                return 'Please enter the zipcode';
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
                    ElevatedButton(
                      onPressed: () {
                        _selectTime();
                      },
                      child: Text("selected time: $_selectedHour"),
                    ),
                    // Validator for the time picker
                    if (_selectedHour == null && _formKey.currentState != null)
                      Text(
                        'Please select a time',
                        style: TextStyle(color: Colors.red),
                      ),
                    SizedBox(height: screenSize.height * 0.02),
                    Text(
                      'The selected hour is according UTC timezone(24hr format): $_selectedHour',
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
                          double winnings = await getExpectedWins(_locationController.text, _dayController.text,  int.parse(_betAmountController.text), double.parse(_predictedTempController.text),
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
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_selectedHour == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please select a time')),
                            );
                          }
                          else {
                            double winnings = await getExpectedWins(_locationController.text, _dayController.text, int.parse(_betAmountController.text), double.parse(_predictedTempController.text),
                            ) as double;
                            setState(() {
                              _winnings = winnings;
                            });
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
                                          Bets bets = Bets(
                                              _dayController.text, double.parse(
                                              _betAmountController.text), _winnings,
                                              _locationController.text, double.parse(
                                              _predictedTempController.text),
                                              _selectedHour, false);
                                          setBet(bets);
                                          print("bets stored");
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  Text('You successfully placed a bet!'),
                                                  SizedBox(width: 8),
                                                  Visibility(
                                                    visible: _showCoinEffect,
                                                    child: coinEfffect(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ).closed.then((_) {
                                            // Delay setting _showCoinEffect to true
                                            print("Before setting _showCoinEffect: $_showCoinEffect");
                                            Future.delayed(Duration(seconds: 2), () {
                                              print("Setting _showCoinEffect to true");
                                              setState(() {
                                                _showCoinEffect = true;
                                              });
                                            });
                                          });

                                          _locationController.clear();
                                          _dayController.clear();
                                          _predictedTempController.clear();
                                          _betAmountController.clear();
                                          _winnings = 0.0;
                                          _selectedHour = "";
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
          // Add coinEfffect widget to the Stack if _showCoinEffect is true
          if (_showCoinEffect)
            Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter, // Adjust alignment as needed
                child: coinEfffect(), // Display the coin effect
              ),
            ),
        ],
      ),
    );
  }
}

String getDate(int hour){
  if(hour<10){
    return "0${hour}:00";
  }
  return "${hour}:00";
}
