// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../widget/auth_form.dart';
//
// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});
//
//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }
//
// class _AuthScreenState extends State<AuthScreen> {
//   final _auth = FirebaseAuth.instance;
//   var _isLoading = false;
//
//   void _submitAuthForm(
//     String email,
//     String password,
//     String username,
//     File image,
//     bool isLogin,
//   ) async {
//     try {
//       setState(() {
//         _isLoading = true;
//       });
//
//       UserCredential authResult;
//       if (isLogin) {
//         // Sign in with email and password
//         authResult = await _auth.signInWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//         print('Logged in: ${authResult.user?.email}');
//       } else {
//         // Sign up with email and password
//         authResult = await _auth.createUserWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//
//         final userId = authResult.user!.uid;
//       final ref =   FirebaseStorage.instance
//             .ref()
//             .child('user_image')
//             .child(authResult.user!.uid + '.jpg');
// await ref.putFile(image).whenComplete(()=> null);
// final url = await ref.getDownloadURL();
//
//
//         await FirebaseFirestore.instance.collection('users').doc(userId).set({
//           'username': username,
//           'email': email,
//          'image_url':url
//
//         });
//
//         print('Registered user: ${authResult.user?.email}');
//       }
//     } on FirebaseAuthException catch (e) {
//       String errorMessage = 'An error occurred, please try again later.';
//
//       if (e.code == 'email-already-in-use') {
//         errorMessage = 'This email address is already in use.';
//       } else if (e.code == 'invalid-email') {
//         errorMessage = 'This is not a valid email address.';
//       } else if (e.code == 'weak-password') {
//         errorMessage = 'The password is too weak.';
//       } else if (e.code == 'user-not-found') {
//         errorMessage = 'No user found for this email.';
//       } else if (e.code == 'wrong-password') {
//         errorMessage = 'Invalid password. Please try again.';
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(errorMessage),
//           backgroundColor: Colors.black,
//         ),
//       );
//     } catch (e) {
//       print('An error occurred: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('An unexpected error occurred.'),
//           backgroundColor: Colors.black,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).primaryColor,
//       body: AuthForm(
//         _submitAuthForm,
//         _isLoading,
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widget/auth_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(
      String email,
      String password,
      String username,
      File? image,  // Made nullable
      bool isLogin,
      ) async {
    try {
      setState(() {
        _isLoading = true;
      });

      UserCredential authResult;
      if (isLogin) {
        // Sign in with email and password
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('Logged in: ${authResult.user?.email}');
      } else {
        // Sign up with email and password
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final userId = authResult.user!.uid;

        if (image != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('user_image')
              .child('$userId.jpg');
          await ref.putFile(image).whenComplete(() => null);
          final url = await ref.getDownloadURL();

          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'username': username,
            'email': email,
            'image_url': url,
          });
        } else {
          // If image is null, store without image URL
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'username': username,
            'email': email,
            'image_url': null,
          });
        }

        print('Registered user: ${authResult.user?.email}');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred, please try again later.';

      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email address is already in use.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'This is not a valid email address.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No user found for this email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Invalid password. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.black,
        ),
      );
    } catch (e) {
      print('An error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred.'),
          backgroundColor: Colors.black,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(
        _submitAuthForm,
        _isLoading,
      ),
    );
  }
}
