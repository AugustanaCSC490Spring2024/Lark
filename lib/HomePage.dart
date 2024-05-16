import 'dart:async';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:larkcoins/dbHandler.dart';
import 'Bets.dart';
import 'topNavigationBar.dart';

//Code generated by Chat Gpt

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
        body: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
            ),
            TabBar(
              tabs: [
                Tab(text: 'Bets Results'),
                Tab(text: 'Pending Bets'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  BetList(isComplete: true),
                  BetList(isComplete: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BetList extends StatelessWidget {
  final bool isComplete;

  const BetList({Key? key, required this.isComplete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<List<Bets>> Function() betFuture;
    if (isComplete) {
      betFuture = getCompleteBets;
    } else {
      betFuture = getIncompleteBets;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffcdffd8), Color(0xff94b9ff)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: FutureBuilder<List<Bets>>(
        future: betFuture(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            var bets = snapshot.data!;
            return ListView.builder(
              itemCount: bets.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: BetCard(bet: bets[index]),
                );
              },
            );
          }
        },
      ),
    );
  }
}



class BetCard extends StatelessWidget {
  final Bets bet;

  const BetCard({Key? key, required this.bet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.black;
    String titleText = "";
    Widget? additionalInfo;

    if (isIncompleteBet(bet)) {
      titleText = "\$"+bet.expectedEarning.toString();
      Bets incompleteBet= bet;
      additionalInfo = _buildAdditionalInfo(incompleteBet);
    } else  {
      Bets completeBet = bet;
      titleText = completeBet.didWin? "\$${completeBet.expectedEarning}": "-\$${(completeBet.wager).toString()}";
      additionalInfo = _buildAdditionalInfo(completeBet);
      textColor = completeBet.didWin ? Colors.green.shade400 : Colors.red.shade400;

    }

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: ExpansionTile(
        title: Text(
          titleText,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor), // Set text color
        ),
        children: [
          additionalInfo ?? SizedBox.shrink(),
        ],
      ),
    );
  }

}
Widget _buildAdditionalInfo(Bets bet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        ListTile(
          leading: Icon(Icons.monetization_on_outlined, size: 16),
          title: Text("Bet Amount: ${bet.wager}", style: TextStyle(fontSize: 14)),
        ),
        ListTile(
          leading: Icon(Icons.access_time, size: 16),
          title: Text("Time: ${bet.date}", style: TextStyle(fontSize: 14)),
        ),
        ListTile(
          leading: Icon(Icons.location_pin, size: 16),
          title: Text("Location: ${bet.zipCode}", style: TextStyle(fontSize: 14)),
        ),
        ListTile(
          leading: Icon(Icons.thermostat, size: 16),
          title: Text("Your Temperature: ${bet.predictedTemp}", style: TextStyle(fontSize: 14)),
        ),
        if(!isIncompleteBet(bet))
          ListTile(
            leading: Icon(Icons.thermostat, size: 16),
            title: Text("Actual Temperature: ${bet.actualTemp}", style: TextStyle(fontSize: 14)),
          ),
      ],
    );
  }

bool isIncompleteBet(Bets bet){
  return !bet.didWin && bet.expectedEarning!=0;
}