import 'package:flutter/material.dart';
import 'package:larkcoins/dbHandler.dart';
import 'Bets.dart';
import 'logo.dart';



class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Your Bets'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Complete Bets'),
              Tab(text: 'Incomplete Bets'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BetList(isComplete: true),
            BetList(isComplete: false),
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
          colors: [Colors.indigo.shade900, Colors.indigo.shade700],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5],
          tileMode: TileMode.clamp,
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
    Color cardColor = Colors.blue;
    String titleText = "";
    Widget? additionalInfo;

    if (isIncompleteBet(bet)) {
      titleText = bet.zipCode;
      Bets incompleteBet= bet;
      additionalInfo = _buildAdditionalInfo(incompleteBet);
    } else  {
      Bets completeBet = bet;
      titleText = completeBet.result? completeBet.expectedEarning.toString(): (-completeBet.wager).toString();
      additionalInfo = _buildAdditionalInfo(completeBet);
      cardColor = completeBet.result ? Colors.green : Colors.red;
    }

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: ExpansionTile(
        title: Text(
          titleText,
          style: TextStyle(fontWeight: FontWeight.bold),
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
          leading: Icon(Icons.access_time, size: 16),
          title: Text("Time: ${bet.date}", style: TextStyle(fontSize: 14)),
        ),
        ListTile(
          leading: Icon(Icons.attach_money, size: 16),
          title: Text("Expected Wins: \$${bet.expectedEarning}", style: TextStyle(fontSize: 14)),
        ),
        if(isIncompleteBet(bet))
          ListTile(
            leading: Icon(Icons.thermostat, size: 16),
            title: Text("Temperature: ${bet.predictedTemp}", style: TextStyle(fontSize: 14)),
          ),
      ],
    );
  }

bool isIncompleteBet(Bets bet){
  return !bet.result && bet.expectedEarning!=0;
}