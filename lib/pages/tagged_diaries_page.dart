import 'package:flutter/material.dart';
import 'dart:io';
import '../models/diary.dart';
import '../theme/app_theme.dart';
import 'diary_detail_page.dart';

class TaggedDiariesPage extends StatelessWidget {
  final String tag;
  final List<Diary> diaries;

  const TaggedDiariesPage({
    super.key,
    required this.tag,
    required this.diaries,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('$tag (${diaries.length})'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: diaries.length,
        itemBuilder: (context, index) {
          final diary = diaries[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryDetailPage(diary: diary),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.getTagColor(tag)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diary.content.split('\n').first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (diary.imagePaths.isNotEmpty)
                    Container(
                      height: 100,
                      margin: const EdgeInsets.only(top: 8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: diary.imagePaths.length,
                        itemBuilder: (context, imageIndex) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Image.file(
                              File(diary.imagePaths[imageIndex]),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 