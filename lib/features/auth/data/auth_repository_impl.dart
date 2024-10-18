import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/auth_repository.dart';
import '../domain/entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({required this.firebaseAuth, required this.sharedPreferences});


  @override
  Future<User?> login(String email, String password) async {

    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      return User(uid: credential.user!.uid, email: credential.user!.email!);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User?> signUp(String email, String password, String name, String phone) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.updateDisplayName(name);


      return User(
        uid: credential.user!.uid,
        email: credential.user!.email!,
        name: name,
        phone: phone,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
    await sharedPreferences.clear();

  }

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser != null) {
      return User(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        name: firebaseUser.displayName ?? '',
      );
    } else {
      return null;
    }
  }
}
