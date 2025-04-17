import 'package:chat_boot_app/bloc/chat_bot_bloc.dart';
import 'package:chat_boot_app/card_page.dart';
import 'package:chat_boot_app/chat_boot_page.dart';
import 'package:chat_boot_app/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => ChatBotBloc())],
      child: RootView(),
    );
  }
}

class RootView extends StatelessWidget {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.deepOrange,
        indicatorColor: Colors.blue,
      ),
      routes: {
        "/chat": (context) => ChatBootPage(),
        "/card": (context) => CardPage(),
      },
      home: HomePage(),
    );
  }
}
