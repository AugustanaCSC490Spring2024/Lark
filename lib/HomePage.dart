import 'package:flutter/material.dart';
import 'package:larkcoins/dbHandler.dart';
import 'Bets.dart';
import 'logo.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: TopLeftLogo(),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.indigo.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Your Bets',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 8),
            _buildBetList("Pending Bets", getIncompleteBets()),
            SizedBox(height: 16),
            _buildBetList("Completed Bets", getCompletBets()),
          ],
        ),
      ),
    );
  }

  Widget _buildBetList(String title, Future<List<Bets>> betFuture) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Bets>>(
                future: betFuture,
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
            ),
          ],
        ),
      ),
    );
  }
}

class BetCard extends StatefulWidget {
  final Bets bet;

  const BetCard({Key? key, required this.bet}) : super(key: key);

  @override
  _BetCardState createState() => _BetCardState();
}

class _BetCardState extends State<BetCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    Color cardColor = Colors.blue;
    String titleText = "";
    Widget? additionalInfo;

    if (isIncompleteBet(widget.bet)) {
      titleText = widget.bet.zipCode;
      Bets incompleteBet= widget.bet;
      additionalInfo = _buildAdditionalInfo(incompleteBet);
    } else  {
      Bets completeBet = widget.bet;
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
        onExpansionChanged: (value) {
          setState(() {
            _isExpanded = value;
          });
        },
        children: [
          additionalInfo ?? SizedBox.shrink(),
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
}

bool isIncompleteBet(Bets bet){
  return !bet.result && bet.expectedEarning!=0;
}