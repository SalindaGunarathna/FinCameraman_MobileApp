import 'package:c_man_mobapp/screens/auth/cameramanHomepage.dart';
import 'package:c_man_mobapp/screens/auth/clientHomepage.dart';
import 'package:c_man_mobapp/screens/auth/user_reg_screen.dart';
import 'package:c_man_mobapp/widgets/button.dart';
import 'package:c_man_mobapp/widgets/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();

  signIn() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailcontroller.text, password: _passwordcontroller.text);

      // Check the user type by querying the respective collection
      String uid = userCredential.user?.uid ?? "";
      bool isClient = await checkIfUserIsClient(uid);
      bool isCameraman = await checkIfUserIsCameraman(uid);

      if (isClient) {
        // Navigate to client homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ClientHomepage()),
        );
      } else if (isCameraman) {
        // Navigate to cameraman homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CameramanHomepage()),
        );
      } else {
        // Handle the case where the user type is unknown or not determined
        print("Unknown user type");
      }
    } on FirebaseAuthException catch (e) {
      print("Error during login: ${e.message}");
      // Handle login errors here
    }
  }

  Future<bool> checkIfUserIsClient(String uid) async {
  try {
    // Reference to the 'users' collection in Firestore
    CollectionReference clientsCollection =
        FirebaseFirestore.instance.collection('users');

    // Check if the user's UID exists in the 'users' collection
    QuerySnapshot querySnapshot =
        await clientsCollection.where('uid', isEqualTo: uid).get();

    return querySnapshot.docs.isNotEmpty;
  } catch (e) {
    print("Error checking client collection: $e");
    return false;
  }
}

Future<bool> checkIfUserIsCameraman(String uid) async {
  try {
    // Reference to the 'cameramen' collection in Firestore
    CollectionReference cameramenCollection =
        FirebaseFirestore.instance.collection('cameramen');

    // Check if the user's UID exists in the 'cameramen' collection
    QuerySnapshot querySnapshot =
        await cameramenCollection.where('uid', isEqualTo: uid).get();

    return querySnapshot.docs.isNotEmpty;
  } catch (e) {
    print("Error checking cameraman collection: $e");
    return false;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.06,
            ),
            Image.asset(
              'assets/logoyellow.png',
              height: 150,
            ),
            const SizedBox(
              height: 35,
            ),

            // email
            TextInputField(
              controller: _emailcontroller,
              isPassword: false,
              inputkeyboardType: TextInputType.emailAddress,
              hintText: "Enter Email",
            ),
            const SizedBox(
              height: 15,
            ),

            // password
            TextInputField(
              controller: _passwordcontroller,
              isPassword: true,
              inputkeyboardType: TextInputType.emailAddress,
              hintText: "Enter Email",
            ),
            const SizedBox(
              height: 35,
            ),

            SubmitButton(text: "Log in", onPressed: signIn()),
            const SizedBox(
              height: 35,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Don\'t have an account?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserReg(),
                        ));
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    )));
  }
}
