import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/diary.dart';
import '../theme/app_theme.dart';
import 'diary_detail_page.dart';
import 'dart:io';
import 'tagged_diaries_page.dart';

class BookshelfPage extends StatefulWidget {
  const BookshelfPage({super.key});

  @override
  State<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends State<BookshelfPage> {
  final List<String> _tags = ['MY', '운동일지', '영화일지', 'instagram'];
  Map<String, List<Diary>> _taggedDiaries = {};

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    final diaryMaps = await DatabaseHelper.instance.queryAllRows();
    final diaries = diaryMaps.map((map) => Diary.fromMap(map)).toList();
    
    final Map<String, List<Diary>> taggedDiaries = {};
    for (var tag in _tags) {
      taggedDiaries[tag] = diaries.where((diary) => diary.tag == tag).toList();
    }

    setState(() {
      _taggedDiaries = taggedDiaries;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('나의 책장'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tags.length,
        itemBuilder: (context, index) {
          final tag = _tags[index];
          final diaries = _taggedDiaries[tag] ?? [];
          
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaggedDiariesPage(
                    tag: tag,
                    diaries: diaries,
                  ),
                ),
              ).then((_) => _loadDiaries());
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.getTagColor(tag)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.bookmark, color: AppTheme.getTagColor(tag)),
                  const SizedBox(width: 8),
                  Text(
                    tag,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${diaries.length})',
                    style: Theme.of(context).textTheme.bodyMedium,
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