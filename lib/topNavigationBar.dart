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
    return GestureDetector(
      onTap: () {
        // the following two lines from chatgpt
        Navigator.popUntil(context, (route) => route.isFirst); // Close all existing routes
        Navigator.pushReplacementNamed(context, '/'); // Navigate to the home page
      },
      child: const Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          'CLIMECOIN',
          style: TextStyle(
            fontSize: 70,
            fontFamily: 'Casino3D',
            color: Color(0xffff8884),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(2, 1, 2, 1),
      color: Colors.transparent,
      child: Row(
        children: [
          leading,
          const SizedBox(width: 16),
          // (future assignment) Add wallet to the right side of appbar later
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
