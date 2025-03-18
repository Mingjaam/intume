import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AppTheme {
  // 기본 색상 팔레트
  static const Color primaryYellow = Color(0xFFFFD700); // 메인 노란색
  static const Color secondaryPink = Color(0xFFF08080); // 보조 분홍색
  static const Color accentBlue = Color(0xFF00BFFF);    // 강조 하늘색
  static const Color lightPurple = Color(0xFFC9C3E6); // 연한보라색
  
  //태그별 색상
  static const Color tagMy =Color(0xFFFFD700);
  static const Color tagExercise = Color.fromARGB(255, 29, 243, 236);
  static const Color tagMovie = Color.fromARGB(255, 246, 88, 88);
  static const Color tagInstagram = Color.fromARGB(255, 243, 109, 245);

  // 텍스트 색상
  static const Color textPrimary = Color(0xFF333333);   // 기본 텍스트
  static const Color textSecondary = Color(0xFF666666); // 보조 텍스트
  static const Color textLight = Color(0xFF999999);     // 옅은 텍스트
  
  // 배경 색상
  static const Color background = Colors.white;         // 기본 배경
  static const Color backgroundLight = Color(0xFFF5F5F5); // 옅은 배경
  
  // 상태 색상
  static const Color success = Color(0xFF4CAF50);       // 성공 표시
  static const Color error = Color(0xFFE53935);         // 오류 표시
  static const Color warning = Color(0xFFFFC107);       // 경고 표시
  
  // 메인화면 일기 테두리 (수정필요)
  static BoxDecoration diaryBoxDecoration = BoxDecoration(
    color: background,
    border: Border.all(color: primaryYellow),
    borderRadius: BorderRadius.circular(8),
  );
  
  static BoxDecoration selectedBoxDecoration = BoxDecoration(
    color: background,
    border: Border.all(color: secondaryPink),
    borderRadius: BorderRadius.circular(8),
  );
  
  // 캘린더 스타일
  static CalendarStyle calendarStyle = CalendarStyle(
    markersMaxCount: 2,
    markerDecoration: BoxDecoration(
      color: primaryYellow,
      shape: BoxShape.circle,
    ),
    todayDecoration: BoxDecoration(
      color: Colors.transparent,
      shape: BoxShape.circle,
      border: Border.all(color: accentBlue, width: 1.5),
    ),
    selectedDecoration: BoxDecoration(
      color: Colors.transparent,
      shape: BoxShape.circle,
      border: Border.all(color: lightPurple, width: 1.5),
    ),
    todayTextStyle: TextStyle(
      color: textPrimary,
      fontWeight: FontWeight.bold,
    ),
    selectedTextStyle: TextStyle(
      color: textPrimary,
      fontWeight: FontWeight.bold,
    ),
  );
  
  // 헤더 스타일
  static HeaderStyle calendarHeaderStyle = HeaderStyle(
    formatButtonVisible: false,
    titleCentered: true,
    titleTextStyle: TextStyle(
      color: textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    leftChevronIcon: Icon(
      Icons.chevron_left,
      color: lightPurple,
    ),
    rightChevronIcon: Icon(
      Icons.chevron_right,
      color: lightPurple,
    ),
  );
  
  // 라이트 테마 정의
  static ThemeData lightTheme = ThemeData(
    primaryColor: lightPurple,
    scaffoldBackgroundColor: background,
    dividerColor: Colors.grey[300],
    
    // AppBar 테마
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    
    // 텍스트 테마
    textTheme: TextTheme(
      displayLarge: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: textPrimary, fontSize: 14),
      bodySmall: TextStyle(color: textSecondary, fontSize: 12),
    ),
    

    
    // 기타 테마 설정
    colorScheme: ColorScheme.light(
      primary: primaryYellow,
      secondary: secondaryPink,
      tertiary: accentBlue,
    ),
  );

  static Color getTagColor(String tag) {
    switch (tag) {
      case 'MY':
        return tagMy;
      case '운동일지':
        return tagExercise;
      case '영화일지':
        return tagMovie;
      case 'instagram':
        return tagInstagram;
      default:
        return primaryYellow;
    }
  }
} 