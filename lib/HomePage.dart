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
            colors: [Colors.lightBlue.shade50, Colors.white],
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
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Your Bets',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Bets>>(
                future: getIncompleteBets(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    var bets = snapshot.data!;
                    return ListView.builder(
                      itemCount: bets.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Color(0xFFE3F2FF), // Set background color here
                          child: ListTile(
                            title: Text(bets[index].city),
                            subtitle: Text("Amount: \$${bets[index].wager.toString()}"),
                            trailing: Text("Expected: \$${bets[index].expectedEarning.toString()}"),
                          ),
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
