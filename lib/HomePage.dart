import 'package:flutter/material.dart';
import 'dbHandler.dart';
import 'Bets.dart';
// chatgpt fixed the code
class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Bets>>(
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
    );
  }
}
