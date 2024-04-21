

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/src/auth_credential.dart';
import 'package:larkcoins/LoginPage.dart';

import 'AccountPage.dart';

bool checkPasswords(String p1, String p2){
  return p1 == p2;
}

Future<bool> checkCredentials(String userEmail, String userPassword) async {
  try {
    AuthCredential credential = EmailAuthProvider.credential(email: userEmail, password: userPassword);
    await user?.reauthenticateWithCredential(credential);
    return true;
  } catch (e) {
    return false;
  }
}

void changePassword(String newPassword) async{
  await user?.updatePassword(newPassword);
}
