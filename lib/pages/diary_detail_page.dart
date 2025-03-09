import 'package:flutter/material.dart';
import '../models/diary.dart';
import '../pages/add_diary_page.dart';

// 일기 상세 내용을 보여주는 페이지
class DiaryDetailPage extends StatefulWidget {
  final Diary diary;

  const DiaryDetailPage({
    super.key,
    required this.diary,
  });

  @override
  State<DiaryDetailPage> createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<DiaryDetailPage> {
  // 현재 표시할 일기 데이터
  late Diary _currentDiary;

  @override
  void initState() {
    super.initState();
    _currentDiary = widget.diary;
  }

  // 날짜를 'YYYY.MM.DD' 형식으로 포맷하는 메소드
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일기 상세'),
        actions: [
          // 수정 버튼
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // AddDiaryPage를 수정 모드로 열기
              final updatedDiary = await Navigator.push<Diary>(
                context,
                MaterialPageRoute(
                  builder: (context) => AddDiaryPage(diary: _currentDiary),
                ),
              );
              
              // 수정된 데이터가 있으면 화면 갱신
              if (updatedDiary != null) {
                setState(() {
                  _currentDiary = updatedDiary;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              _currentDiary.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // 작성 날짜
            Text(
              _formatDate(_currentDiary.createdAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            // 일기 내용
            Text(
              _currentDiary.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 