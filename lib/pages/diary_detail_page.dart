import 'package:flutter/material.dart';
import '../models/diary.dart';
import '../database/database_helper.dart';
import '../pages/add_diary_page.dart';
import '../theme/app_theme.dart';
import 'dart:io';

// 일기 상세 내용을 보여주는 페이지
class DiaryDetailPage extends StatelessWidget {
  final Diary diary;

  const DiaryDetailPage({
    super.key,
    required this.diary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일기 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddDiaryPage(diary: diary),
                ),
              ).then((value) {
                if (value != null) {
                  Navigator.pop(context, true);
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('일기 삭제'),
                  content: Text('이 일기를 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      child: Text('취소'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: Text('삭제'),
                      onPressed: () async {
                        await DatabaseHelper.instance.delete(diary.id!);
                        if (context.mounted) {
                          Navigator.pop(context); // 다이얼로그 닫기
                          Navigator.pop(context, true); // 상세 페이지 닫기
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 태그 표시
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.getTagColor(diary.tag).withOpacity(0.1),
                    border: Border.all(
                      color: AppTheme.getTagColor(diary.tag),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    diary.tag,
                    style: TextStyle(
                      color: AppTheme.getTagColor(diary.tag),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // 이미지가 있는 경우 이미지 표시
                if (diary.imagePaths.isNotEmpty && diary.imagePaths[0].isNotEmpty) ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,  // 한 줄에 2개의 이미지
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: diary.imagePaths.length,
                    itemBuilder: (context, index) {
                      if (diary.imagePaths[index].isEmpty) return SizedBox.shrink();
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                backgroundColor: Colors.black,
                                appBar: AppBar(
                                  backgroundColor: Colors.black,
                                  iconTheme: IconThemeData(color: Colors.white),
                                ),
                                body: Center(
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    boundaryMargin: EdgeInsets.all(20),
                                    minScale: 0.5,
                                    maxScale: 4,
                                    child: Image.file(
                                      File(diary.imagePaths[index]),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(diary.imagePaths[index]),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return SizedBox.shrink();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                ],
                // 일기 내용
                Text(
                  diary.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 