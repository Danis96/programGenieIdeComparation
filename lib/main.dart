import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:programgenieplugins/helpers/firebase_options.dart';
import 'package:programgenieplugins/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}
