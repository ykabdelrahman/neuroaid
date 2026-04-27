import 'package:flutter/material.dart';

import 'package:neuroaid/src/features/chat_ai/chat_ai_screen.dart';
import 'package:neuroaid/src/features/doctors/doctors_list_screen.dart';
import 'package:neuroaid/src/features/home/CustomBottomNavigationBar.dart';
import 'package:neuroaid/src/features/home/HomeTab.dart';
import 'package:neuroaid/src/features/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  void _onItemTapped(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: const [
            // --------------
            HomeTab(), // AHMED
            DoctorsListScreen(), // AHEMD
            // -------------------------
            ChatAIScreen(), //MALLK
            ProfileScreen(), // MALK
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _index,
        onTap: _onItemTapped,
      ),
    );
  }
}
