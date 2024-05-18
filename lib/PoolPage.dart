import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
            Padding(
              padding: EdgeInsets.all(8.0),
            ),
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'All Pools'),
                Tab(text: 'My Pools'),
                Tab(text: 'Completed Pools'),
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
    return FutureBuilder<Map<String, BetsPool>>(
      future: getBetPools(),
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
                onPressed: (){

                  setState(() {


                  showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        title: Text("Create a new pool"),
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
                                validator: (value){
                                  if (value == null || value.isEmpty){
                                    return "Please enter a value";
                                  }
                                  if (int.tryParse(value) == null){
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


                                        if (int.tryParse(value) == null){
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
                                validator: (value){
                                  if (value == null || value.isEmpty){
                                    return "Please enter a value";
                                  }
                                  if (int.tryParse(value) == null){
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
                            onPressed: (){
                              Navigator.of(context).pop();

                            },
                            child: Text("Cancel"),
                          ),



                          ElevatedButton(
                            onPressed: () async{
                              if (_formKey.currentState!.validate()) {
                                bool added = await createPools(locationController.text, dateController.text, timeController.text, double.parse(tempController.text), double.parse(moneyController.text));

                                if (added){

                                setState(() {

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context){
                                      return AlertDialog(
                                        title: Text("Success"),
                                        content: Text("You have successfully created a new pool"),
                                        actions: [
                                          TextButton(
                                            onPressed: (){


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
                                  print(added);
                                }
                              }
                            },
                            child: Text("Submit"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.blue,
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
                      // Customize card appearance as needed


                      child: ListTile(
                        title: Text('Zip Code: ${pool.zipCode}'),
                        subtitle: Text('Amount: \$${pool.totalWins}, Date: ${pool.date}'),
                        trailing: Text('Total gamblers: ${pool.userMoney.length}'),
                        onTap: () {
                          // Handle onTap event
                          showDialog(
                          context: context,
                          builder: (BuildContext context){
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
                                        validator: (value){
                                      if (value == null || value.isEmpty){
                                      return "Please enter a value";
                                      }
                                      if (int.tryParse(value) == null){
                                        return "Please enter a valid number";
                                      }
                                      return null;
                                      },
                                      ),
                                       TextFormField(
                                        controller: moneyController,
                                        decoration: InputDecoration(
                                        labelText: "Amount",
                                        ),
                                  keyboardType: TextInputType.number,
                                  validator: (value){
                                  getMoneyOfUser();
                                  if (value == null || value.isEmpty){
                                      return "Please enter a value";
                                  }
                                  if (int.parse(value) > UserMoney){
                                      return "You do not have enough money";
                                  }

                                  if (int.tryParse(value) == null){
                                  return "Please enter a valid number";
                                  }
                                  return null;
                                  },
                                       ),
                                  ],
                                  ),
                                  ),
                                  actions: [
                                  TextButton(
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel"),
                                  ),

                                  TextButton(
                                  onPressed: () async{
                                    if (_formKey.currentState!.validate()) {

                                    bool added = await addUserToBetPool(allPools[index].docID, double.parse(tempController.text), int.parse(moneyController.text));

                                    if (added) {

                                    showDialog(
                                   context: context,
                                    builder: (
                                    BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Success"),
                                      content: Text(
                                      "You have successfully placed your bet"),
                                  actions: [
                                      TextButton(
                                      onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      setState(() {

                                      });
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
    return FutureBuilder<Map<String, BetsPool>>(
      future: getBetPools(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {


          var poolsMap = snapshot.data!;
          var keys = poolsMap.keys.toList();

          // Filter out pools that the user has participated in
          var myPools = poolsMap.values.where((pool) => hasParticipatedInPool(pool)).toList();

          return ListView.builder(
            itemCount: myPools.length,
            itemBuilder: (context, index) {
              var pool = myPools[index];
              return Card(

                // Customize card appearance as needed
                child: ListTile(
                  title: Text('Zip Code: ${pool.zipCode}'),
                  subtitle: Text('Amount: \$${pool.totalWins}, Date: ${pool.date}'),
                  trailing: Text('Total gamblers: ${pool.userMoney.length}'),
                  onTap: () {
                    // Handle onTap event
                  },
                ),
              );
            },
          );
        }
      },
    );
  }


  Widget _buildCompletedPoolsTab() {

    return FutureBuilder<List<BetsPool>>(
      future: getCompletedPools(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          // Create a copy of the list only when data is not null and not empty
          var completedPools = snapshot.data!;
          return ListView.builder(
            itemCount: completedPools.length,
            itemBuilder: (context, index) {
              var pool = completedPools[index];
              double totalWinnings = getBetsPoolWInnings(pool);





              return Card(
                // Customize card appearance as needed
                child: ListTile(
                  title: Text('Zip Code: ${pool.zipCode}'),
                  subtitle: Text('Amount: \$${totalWinnings}, Date: ${pool.date}'),
                  trailing: Text('Total gamblers: ${pool.userMoney.length}'),
                  onTap: () {
                    // Handle onTap event
                  },
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
