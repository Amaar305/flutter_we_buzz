import 'package:firebase_auth/firebase_auth.dart';

class CurrentLoggeedInUser {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static User? get currenoggedIntUser {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return firebaseAuth.currentUser;
  }

  
}
