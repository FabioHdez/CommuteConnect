import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService  {
  //the google sign in

  googleSignIn() async {
    //begin user login process

    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    //obtain authentication detail from the request

    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    //create new credential for the user

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    //sign in 

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}