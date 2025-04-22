
// import 'package:Lextorah/models/student.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';


// class UserProvider with ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;
//   set isLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }

//   Student? _user;
//   Student? get user => _user;

//   set user(Student? value) {
//     _user = value;
//     notifyListeners();
//   }
 
//   // Update profile image
//   Future<void> updateProfileImage(String newImage) async {
//     if (_user == null) return;

//     try {
//       await FirebaseFirestore.instance
//           .collection('students')
//           .doc(_user!.uid)
//           .update({'profileImage': newImage});
//       _user = _user!.copyWith(profileImage: newImage);
//       notifyListeners();
//     } catch (e) {
//       print(e);
//     }
//   }

  
// }
