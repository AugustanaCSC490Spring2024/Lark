import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:larkcoins/dbHandler.dart';
import 'Bets.dart';
import 'topNavigationBar.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          leading: GestureDetector(
            onTap: () {
              // Avoid pushing HomePage again if already on it
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            child: const TopNavigation(),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
            ),
            const TabBar(
              tabs: [
                Tab(text: 'Bets Results'),
                Tab(text: 'Pending Bets'),
              ],
            ),
            const Expanded(
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
    Stream<List<Bets>> Function() betFuture;
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
      child: StreamBuilder<List<Bets>>(
        stream: betFuture(),
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
    var winningAmount;


    if (isIncompleteBet(bet)) {
      titleText = "\$"+bet.expectedEarning.toString();
      winningAmount = bet.expectedEarning;
      Bets incompleteBet= bet;
      additionalInfo = _buildAdditionalInfo(incompleteBet);
    } else  {
      Bets completeBet = bet;
      titleText = completeBet.didWin? "\$${completeBet.expectedEarning}": "-\$${(completeBet.wager).toString()}";
      winningAmount = completeBet.expectedEarning - completeBet.wager;
      additionalInfo = _buildAdditionalInfo(completeBet);
      textColor = completeBet.didWin ? Colors.green.shade400 : Colors.red.shade400;
    }


    int winningPercentage = ((winningAmount / bet.wager) * 100).round();
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
     double baseFontSize = screenWidth / 15;


    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ExpansionTile(
        title: Text(
          titleText,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: additionalInfo ?? SizedBox.shrink()),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          winningPercentage < 0 ? Icons.arrow_downward : Icons.arrow_upward,
                          color: winningPercentage < 0 ? Colors.red : Colors.green,
                        ),
                        SizedBox(width: 4),
                        // Added circle container with only circumference
                        Container(
                          width: screenWidth * 0.3, // Adjust the size as needed
                          height: screenWidth * 0.3, // Adjust the size as needed
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: winningPercentage < 0 ? Colors.red : Colors.green,
                              width: 4, // Adjust the thickness of the circumference
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${winningPercentage}%',
                            style: TextStyle(
                              fontSize: baseFontSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                              color: winningPercentage < 0 ? Colors.red : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
        if (!isIncompleteBet(bet))
          ListTile(
            leading: Icon(Icons.thermostat, size: 16),
            title: Text("Actual Temperature: ${bet.actualTemp}", style: TextStyle(fontSize: 14)),
          ),
      ],
    );
  }
}


bool isIncompleteBet(Bets bet) {
  return !bet.didWin && bet.expectedEarning != 0;
}

