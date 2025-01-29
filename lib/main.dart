import 'package:flutter/material.dart';
import 'package:orkut/pages/home_page.dart';
import 'package:orkut/pages/login_page.dart';
import 'package:orkut/pages/register_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
//import '/Users/OOTSO/snapbin/lib/services/firebase_service.dart';
import 'package:orkut/services/firebase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:orkut/services/supabase_service.dart';
import 'package:orkut/pages/home_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "AIzaSyBY94q3VqVTh7xXPxQPGZuFLGpDqreWLfQ",
    authDomain: "snapbin-4aa92.firebaseapp.com",
    projectId: "snapbin-4aa92",
    storageBucket: "snapbin-4aa92.appspot.com",
    messagingSenderId: "337083452326",
    appId: "1:337083452326:web:a0de11ce40e63b431b9d67",
    measurementId: "G-N968REE5MQ",
  ),
);
await Supabase.initialize(
    url: 'https://ewhwtsfuxyarwqikdzxd.supabase.co',  // Get this from your Supabase dashboard
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3aHd0c2Z1eHlhcndxaWtkenhkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgxMjEwNjAsImV4cCI6MjA1MzY5NzA2MH0.LamA-fuXj5GSsoAvTMIzMA1-3SFWqkKQdR9EqCgOUAk',
      // Get this from your Supabase dashboard
  );
GetIt.instance.registerSingleton<FirebaseService>(
  FirebaseService());
  GetIt.instance.registerSingleton<SupabaseService>(SupabaseService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snapbin',
      theme: ThemeData(
   
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: 'login',
     routes : {
      'register' : (context) => RegisterPage(),
      'login' : (context) => LoginPage(),
      'home': (context)=> Home_Page(),
     },
    );
  }
}

