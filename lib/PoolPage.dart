import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'BetsPool.dart';
import 'HomePage.dart';
import 'dbHandler.dart';
import 'topNavigationBar.dart';

class PoolPage extends StatefulWidget {
  const PoolPage({Key? key}) : super(key: key);

  @override
  PoolPageState createState() => PoolPageState();

}

class PoolPageState extends State<PoolPage> {
  TextEditingController tempController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController moneyController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(leading: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
        child: const TopNavigation(),
      )),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5],
            tileMode: TileMode.clamp,
          ),
        ),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton(
                onPressed: (){
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
                                  if (value == null || value.isEmpty){
                                    return "Please enter a value";
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: dateController,
                                decoration: InputDecoration(
                                  labelText: "Date",
                                ),
                                keyboardType: TextInputType.datetime,
                                validator: (value){
                                  if (value == null || value.isEmpty){
                                    return "Please enter a value";
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
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: timeController,
                                decoration: InputDecoration(
                                  labelText: "Time",
                                ),
                                keyboardType: TextInputType.datetime,
                                validator: (value){
                                  if (value == null || value.isEmpty){
                                    return "Please enter a value";
                                  }
                                  return null;
                                },
                              )
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
                                String added = await createPools(locationController.text, dateController.text, timeController.text, double.parse(tempController.text), double.parse(moneyController.text));
                                if (added == "Bets Pool Created"){
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
                                }else{
                                  print(added);
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
                child: Text("Create a new pool"),
              ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Pool',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text("Current Pool"),
            Expanded(
              child: FutureBuilder<Map<String, BetsPool>>(
                future: getBetPools(),
                builder: (context, snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator());
                  }
                  else if (snapshot.hasError){
                    return Text('Error: ${snapshot.error}');
                  }
                  else {
                    var poolsMap = snapshot.data!;
                    var keys = snapshot.data!.keys.toList();

                    return ListView.builder(
                      itemCount: poolsMap.length,
                      itemBuilder: (context, index){
                        return Card(
                          color: hasParticipatedInPool(poolsMap[keys[index]]!) ? Colors.green.withOpacity(0.5) : Color(0xFFE3F2FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 3,
                          child: ListTile(
                            title: Text(poolsMap[keys[index]]!.zipCode.toString()),
                            subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Amount: \$${poolsMap[keys[index]]!.totalWins.toString()}"),
                                SizedBox(height: 5),
                                Text("date: ${poolsMap[keys[index]]!.date}"),
                              ]
                            ),
                            trailing: Column(
                              children: [
                                SizedBox(height: 10),
                                Text("Total Gamblers ${poolsMap[keys[index]]!.userTemp.length.toString()}"),
                              ],
                            ),

                            onTap: hasParticipatedInPool(poolsMap[keys[index]]!) ? null : (){
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
                                              if (value == null || value.isEmpty){
                                                return "Please enter a value";
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
                                            bool added = await addUserToBetPool(keys[index], poolsMap[keys[index]]!, double.parse(tempController.text), int.parse(moneyController.text));
                                            if (added){
                                            showDialog(
                                            context: context,
                                            builder: (BuildContext context){
                                            return AlertDialog(
                                              title: Text("Success"),
                                              content: Text("You have successfully placed your bet"),
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
                                            }
                                            else{
                                              showDialog(
                                              context: context,
                                              builder: (BuildContext context){
                                            return AlertDialog(
                                              title: Text("Error"),
                                              content: Text("You do not have enough money to place this bet"),
                                              actions: [
                                              TextButton(
                                                onPressed: (){
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
                                      ),
                                    ],
                                  );
                                }
                              );
                            },
                          ),
                        );
                      }
                    );
                  }
                }
              )

      ),

      ],
    ),
    ),
    );
  }
}