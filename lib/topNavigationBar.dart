// sources : https://api.flutter.dev/flutter/painting/TextStyle-class.html
//https://stackoverflow.com/questions/63235072/how-to-create-a-working-sidebar-in-flutter
//https://stackoverflow.com/questions/73763083/how-to-make-the-app-jump-to-another-page-after-clicking-text-flutter


import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'dbHandler.dart';

class TopNavigation extends StatelessWidget {
  const TopNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.05; // Adjust this ratio as needed

    return GestureDetector(
      onTap: () {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacementNamed(context, '/');
      },
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          'CLIMECOIN',
          style: TextStyle(
            fontFamily: 'Casino3D',
            color: Color(0xffff8884),
            fontSize: fontSize,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Color(0xffff8884),
                offset: Offset(-5, -5),
              ),
              Shadow(
                blurRadius: 10,
                color: Color(0xffffcbc8),
                offset: Offset(5, 5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget leading;

  const CustomAppBar({super.key, required this.leading});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.02; // Adjust this ratio as needed

    return Container(
      padding: const EdgeInsets.fromLTRB(2, 1, 2, 1),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          leading,
          StreamBuilder<double>(
            stream: getUserMoneyStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return Text('No data');
              } else {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    'Wallet: \$${snapshot.data}',
                    style: TextStyle(fontSize: fontSize),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}


void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const TopNavigation());
}
