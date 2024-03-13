import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:norqmachinetest/Providers/product_provider.dart';
import 'package:norqmachinetest/Screens/signin_screen.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProductProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fake Store App',
        theme: ThemeData(

          colorScheme: ColorScheme.fromSeed(seedColor: Colors.amberAccent),
          useMaterial3: true,
        ),
        home:  const SignInScreen(),
      ),
    );
  }
}
