import 'package:flutter/material.dart';
import '../widgets/CustomBottomNavigationBar.dart';
import 'main_page.dart';  // 메인 페이지
import 'add_diary_page.dart';  // 일기 추가 페이지
import './my_diary_page.dart';  // 마이 페이지
import './bookshelf_page.dart';  // 책장 페이지

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MainPage(),      // 메인 페이지
    const BookshelfPage(), // 책장 페이지
    const AddDiaryPage(),  // 일기 추가 페이지
    const MyDiaryPage(),   // 마이 페이지
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
} 