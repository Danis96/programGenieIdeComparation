import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:programgenieplugins/app/helpers/firebase_options.dart';
import 'package:programgenieplugins/app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}
