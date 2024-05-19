import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:larkcoins/topNavigationBar.dart';
import 'BetsPool.dart';
import 'HomePage.dart';
import 'dbHandler.dart';


class PoolPage extends StatefulWidget {
  const PoolPage({Key? key}) : super(key: key);

  @override
  PoolPageState createState() => PoolPageState();
}

class PoolPageState extends State<PoolPage> with TickerProviderStateMixin{
  TextEditingController tempController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController moneyController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  double UserMoney = 0;
  // Add a TabController for handling tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<TimeOfDay?> showHourPicker({
    required BuildContext context,
    required TimeOfDay initialTime,
  }) async {
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
      // Set the selected minutes to 0
      return TimeOfDay(hour: picked.hour, minute: 0);
    }
    return null;
  }
  FutureBuilder<double> getMoneyOfUser() {
    return FutureBuilder<double>(
      future: getUserMoney(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          UserMoney = snapshot.data!;
          return Text('User Money: $UserMoney');
        }
      },
    );
  }
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.3;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
               TabBar(
                controller: _tabController,
                 labelPadding: EdgeInsets.symmetric(horizontal: 0),
                 indicatorPadding: EdgeInsets.zero,
                tabs: [
                  Tab(
                    child: Container(
                      constraints: BoxConstraints(minWidth: fontSize),
                      child: Center(child: Text('All Pools')),
                    ),
                  ),
                    Tab(
                    child: Container(
                    constraints: BoxConstraints(minWidth: fontSize),
                    child: Center(child: Text('My Pools')),
                    ),
                    ),
                  Tab(
                    child: Container(
                      constraints: BoxConstraints(minWidth: fontSize),
                      child: Center(child: Text('Completed Pools')),
                    ),
                  ),
                ],
              ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllPoolsTab(),
                  _buildMyPoolsTab(),
                  _buildCompletedPoolsTab(),
                ],
              ),
            ),
            // Expanded widget to make the TabBarView take the remaining space
           ] // (after the TabBar and the padding above it
        )


      ),
     

    );
  }


  Widget _buildAllPoolsTab() {
    Size screenSize = MediaQuery.of(context).size;
    return StreamBuilder<Map<String, BetsPool>>(
      stream: getIncompletePoolsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          var poolsMap = snapshot.data!;
          var allPools = poolsMap.values.where((pool) => !hasParticipatedInPool(pool)).toList();

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Create a new pool"),
                              titleTextStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                              content: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: locationController,
                                      decoration: InputDecoration(
                                        labelText: "Zip Code",
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter a value";
                                        }
                                        if (int.tryParse(value) == null) {
                                          return "Please enter a valid number";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 10),
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
                                              controller: moneyController,
                                              decoration: const InputDecoration(
                                                labelText: 'Amount',
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
                                                if (int.tryParse(value) == null) {
                                                  return "Please enter a valid number";
                                                }
                                                return null;
                                              },
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextFormField(
                                      controller: dateController,
                                      decoration: const InputDecoration(
                                        labelText: 'Day',
                                        suffixIcon: Icon(Icons.calendar_today),
                                      ),
                                      readOnly: true,
                                      onTap: () async {
                                        final DateTime tomorrow = DateTime.now().add(Duration(days: 1));

                                        final DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: tomorrow,
                                          firstDate: tomorrow,
                                          lastDate: DateTime(2101),
                                        );
                                        if (picked != null) {
                                          String date = picked.toString();
                                          date = date.substring(0, 10);
                                          dateController.text = date;
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a date';
                                        }
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      controller: tempController,
                                      decoration: InputDecoration(
                                        labelText: "Temperature",
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter a value";
                                        }
                                        if (int.tryParse(value) == null) {
                                          return "Please enter a valid number";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 10),
                                    TextFormField(
                                      controller: timeController,
                                      decoration: const InputDecoration(
                                        labelText: 'Time',
                                        suffixIcon: Icon(Icons.access_time),
                                      ),
                                      readOnly: true,
                                      onTap: () async {
                                        final TimeOfDay? selectedTime = await showHourPicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (selectedTime != null) {
                                          setState(() {
                                            timeController.text = _formatTimeOfDay(selectedTime);
                                          });
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a time';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      bool added = await createPools(locationController.text, dateController.text, timeController.text, double.parse(tempController.text), double.parse(moneyController.text));
                                      if (added) {
                                        setState(() {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text("Success"),
                                                  content: Text("You have successfully created a new pool"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text("Close"),
                                                    ),
                                                  ],
                                                );
                                              }
                                          );
                                        });
                                      }else{
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Error"),
                                                content: Text("You can only create one pool at a time until that pool finishes you can make more"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text("Close"),
                                                  ),
                                                ],
                                              );
                                            }
                                        );
                                      }

                                    }
                                  },
                                  child: Text("Submit"),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blue,
                                    enableFeedback: locationController.text.isNotEmpty && moneyController.text.isNotEmpty && dateController.text.isNotEmpty && tempController.text.isNotEmpty && timeController.text.isNotEmpty,
                                  ),
                                ),
                              ],
                            );
                          }
                      );
                    });
                  },
                  child: Text("Create a new pool"),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: allPools.length,
                  itemBuilder: (context, index) {
                    var pool = allPools[index];
                    return Card(
                      child: ExpansionTile(
                        title: Text('Zip Code: ${pool.zipCode}'),
                        subtitle: Text('Amount: \$${pool.totalWins}, Date: ${pool.date}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total gamblers: ${pool.userMoney.length}'),
                                Text('More detailed information about the pool can go here.'),
                                // Add any other detailed information you want to display
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Place your bet"),
                                            content: Form(
                                              key: _formKey,
                                              child: Column(
                                                children: [
                                                  TextFormField(
                                                    controller: tempController,
                                                    decoration: InputDecoration(
                                                      labelText: "Temperature",
                                                    ),
                                                    keyboardType: TextInputType.number,
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return "Please enter a value";
                                                      }
                                                      if (int.tryParse(value) == null) {
                                                        return "Please enter a valid number";
                                                      }
                                                      return null;
                                                    },
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
                                                            controller: moneyController,
                                                            decoration: const InputDecoration(
                                                              labelText: 'Amount',
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
                                                              if (int.tryParse(value) == null) {
                                                                return "Please enter a valid number";
                                                              }
                                                              return null;
                                                            },
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  if (_formKey.currentState!.validate()) {
                                                    bool added = await addUserToBetPool(allPools[index].docID, double.parse(tempController.text), int.parse(moneyController.text));
                                                    if (added) {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              title: Text("Success"),
                                                              content: Text("You have successfully placed your bet"),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop();
                                                                    Navigator.of(context).pop();
                                                                    setState(() {});
                                                                  },
                                                                  child: Text("Close"),
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                      );
                                                    }
                                                  }
                                                },
                                                child: Text("Submit"),
                                              ),
                                            ],
                                          );
                                        }
                                    );
                                  },
                                  child: Text("Place your bet"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildMyPoolsTab() {
    return StreamBuilder<Map<String, BetsPool>>(
      stream: getIncompletePoolsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          var poolsMap = snapshot.data!;
          var keys = poolsMap.keys.toList();

          var myPools = poolsMap.values.where((pool) => hasParticipatedInPool(pool)).toList();
          if (myPools.isEmpty) {
            return Center(child: Text('No pools to show'));
          } else {
            return ListView.builder(
              itemCount: myPools.length,
              itemBuilder: (context, index) {
                var pool = myPools[index];
                return Card(
                  child: ExpansionTile(
                    title: Text('Zip Code: ${pool.zipCode}'),
                    subtitle: Text('Total gamblers: ${pool.userMoney.length}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: Icon(Icons.monetization_on_outlined, size: 16),
                              title: Text('your money: ${pool.getCurUserMoneyBet()}', style: TextStyle(fontSize: 14)),
                            ),
                            ListTile(
                              leading: Icon(Icons.thermostat_outlined, size: 16),
                              title: Text('Temperature: ${pool.getCurUserTemp()}', style: TextStyle(fontSize: 14)),
                            ),
                            ListTile(
                              leading: Icon(Icons.monetization_on_outlined, size: 16),
                              title: Text('Total Money in the Pool: \$${pool.totalWins}', style: TextStyle(fontSize: 14)),
                            ),
                            ListTile(
                              leading: Icon(Icons.access_time, size: 16),
                              title: Text('Date: ${pool.date}', style: TextStyle(fontSize: 14)),
                            ),
                            // Add any other detailed information you want to display
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        }
      },
    );
  }

  Widget _buildCompletedPoolsTab() {
    Color textColor = Colors.black;
    return StreamBuilder<List<BetsPool>>(
      stream: getCompletePoolsParticipatedStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          var completedPools = snapshot.data!;
          return ListView.builder(
            itemCount: completedPools.length,
            itemBuilder: (context, index) {
              var pool = completedPools[index];
              double totalWinnings = getBetsPoolWInnings(pool);
              if (pool.getCurUserMoneyBet() > 0) {
                textColor = Colors.green;
              } else {
                textColor = Colors.red;
              }

              return Card(
                child: ExpansionTile(
                  title: Text('Zip Code: ${pool.zipCode}', style: TextStyle(color: textColor)),
                  subtitle: Text('Amount: \$${totalWinnings}', style: TextStyle(fontSize: 14, color: textColor)),
                  //Text('Total gamblers: ${pool.userMoney.length}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Icon(Icons.people_alt_outlined, size: 16),
                            title: Text('Total gamblers: ${pool.userMoney.length}'),
                          ),
                          ListTile(
                            leading: Icon(Icons.thermostat_outlined, size: 16),
                            title: Text('the winning temperature: ${pool.getWinningTemp()}', style: TextStyle(fontSize: 14)),
                          ),
                          ListTile(
                            leading: Icon(Icons.thermostat_outlined, size: 16),
                            title: Text('Your temperature: ${pool.getCurUserTemp()}', style: TextStyle(fontSize: 14)),
                          ),
                          ListTile(
                            leading: Icon(Icons.access_time, size: 16),
                            title: Text('Date: ${pool.date}', style: TextStyle(fontSize: 14)),
                          ),
                          // Add any other detailed information you want to display
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return Center(child: Text('No completed pools to show'));
        }
      },
    );
  }




}
