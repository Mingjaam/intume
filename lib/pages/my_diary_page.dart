import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/diary.dart';
import '../pages/diary_detail_page.dart';

class MyDiaryPage extends StatefulWidget {
  const MyDiaryPage({super.key});

  @override
  State<MyDiaryPage> createState() => _MyDiaryPageState();
}

class _MyDiaryPageState extends State<MyDiaryPage> {
  // 일기 목록을 저장할 리스트
  List<Diary> _diaries = [];

  @override
  void initState() {
    super.initState();
    // 페이지가 생성될 때 일기 목록 불러오기
    _loadDiaries();
  }

  // 데이터베이스에서 모든 일기를 불러오는 메소드
  Future<void> _loadDiaries() async {
    final diaryMaps = await DatabaseHelper.instance.queryAllRows();
    setState(() {
      _diaries = diaryMaps.map((map) => Diary.fromMap(map)).toList();
    });
  }

  // 날짜를 'YYYY.MM.DD' 형식으로 포맷하는 메소드
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 상단 프로필 섹션
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[100],
              child: Row(
                children: [
                  // 프로필 아바타
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(width: 20),
                  // 사용자 정보 표시
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '사용자님',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '작성한 일기: ${_diaries.length}개',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 일기 목록 섹션
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadDiaries, // 아래로 당겨서 새로고침
                child: _diaries.isEmpty
                    ? const Center(
                        child: Text('작성된 일기가 없습니다.'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _diaries.length,
                        itemBuilder: (context, index) {
                          final diary = _diaries[index];
                          // 각 일기 카드 아이템
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              title: Row(
                                children: [
                                  // 내용의 첫 줄을 제목처럼 표시
                                  Expanded(
                                    child: Text(
                                      diary.content.split('\n').first, // 첫 줄만 가져오기
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // 태그를 Chip으로 표시
                                  Chip(
                                    label: Text(
                                      diary.tag,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  // 내용 표시 (첫 줄 제외)
                                  Text(
                                    diary.content.split('\n').skip(1).join('\n'), // 첫 줄을 제외한 나머지 내용
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatDate(diary.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // 일기 상세 페이지로 이동
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DiaryDetailPage(
                                      diary: diary,
                                    ),
                                  ),
                                );
                              },
                              // 길게 누르면 삭제 다이얼로그 표시
                              onLongPress: () async {
                                final delete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('일기 삭제'),
                                    content: const Text('이 일기를 삭제하시겠습니까?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text(
                                          '삭제',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                // 삭제 확인 시 데이터베이스에서 삭제하고 목록 새로고침
                                if (delete == true && diary.id != null) {
                                  await DatabaseHelper.instance.delete(diary.id!);
                                  _loadDiaries();
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
