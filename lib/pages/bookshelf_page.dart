import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/diary.dart';
import '../models/tag.dart';
import '../theme/app_theme.dart';
import 'diary_detail_page.dart';
import 'dart:io';
import 'tagged_diaries_page.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class BookshelfPage extends StatefulWidget {
  const BookshelfPage({super.key});

  @override
  State<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends State<BookshelfPage> {
  List<Tag> _tags = [];
  Map<String, List<Diary>> _taggedDiaries = {};
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTagsAndDiaries();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _loadTagsAndDiaries() async {
    final tagMaps = await DatabaseHelper.instance.getAllTags();
    final tags = tagMaps.map((map) => Tag.fromMap(map)).toList();
    
    final diaryMaps = await DatabaseHelper.instance.queryAllRows();
    final diaries = diaryMaps.map((map) => Diary.fromMap(map)).toList();
    
    final Map<String, List<Diary>> taggedDiaries = {};
    for (var tag in tags) {
      taggedDiaries[tag.name] = diaries.where((diary) => diary.tag == tag.name).toList();
    }

    setState(() {
      _tags = tags;
      _taggedDiaries = taggedDiaries;
    });
  }

  void _showAddTagDialog() {
    Color selectedColor = Color(0xFFFFD700); // 기본 색상

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('새 태그 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tagController,
              decoration: InputDecoration(
                labelText: '태그 이름',
                hintText: '새로운 태그 이름을 입력하세요',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // 색상 선택기 표시
                final Color? color = await showDialog<Color>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('태그 색상 선택'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: selectedColor,
                        onColorChanged: (color) {
                          selectedColor = color;
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, selectedColor),
                        child: Text('선택'),
                      ),
                    ],
                  ),
                );
                if (color != null) {
                  selectedColor = color;
                }
              },
              child: Text('태그 색상 선택'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              if (_tagController.text.isNotEmpty) {
                // 태그 중복 확인
                bool exists = await DatabaseHelper.instance.isTagExists(_tagController.text);
                if (exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('이미 존재하는 태그입니다.')),
                  );
                  return;
                }

                // 새 태그 추가
                final newTag = Tag(
                  name: _tagController.text,
                  color: selectedColor.value.toRadixString(16).padLeft(8, '0'),
                  createdAt: DateTime.now(),
                );
                await DatabaseHelper.instance.insertTag(newTag.toMap());
                
                _tagController.clear();
                if (mounted) Navigator.pop(context);
                _loadTagsAndDiaries(); // 태그 목록 새로고침
              }
            },
            child: Text('추가'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('나의 책장'),
      ),
      body: _tags.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('태그가 없습니다. 새로운 태그를 추가해보세요!'),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddTagDialog,
                    icon: Icon(Icons.add),
                    label: Text('태그 추가'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tags.length,
                    itemBuilder: (context, index) {
                      final tag = _tags[index];
                      final diaries = _taggedDiaries[tag.name] ?? [];
                      
                      // 색상 파싱 안전하게 처리
                      Color tagColor;
                      try {
                        String colorStr = tag.color;
                        if (!colorStr.startsWith('0x') && !colorStr.startsWith('FF')) {
                          colorStr = 'FF$colorStr';
                        }
                        if (colorStr.startsWith('0x')) {
                          colorStr = colorStr.substring(2);
                        }
                        tagColor = Color(int.parse(colorStr, radix: 16));
                      } catch (e) {
                        print('색상 변환 오류: $e, 태그: ${tag.name}, 색상값: ${tag.color}');
                        tagColor = Colors.black;
                      }
                      
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaggedDiariesPage(
                                tag: tag.name,
                                diaries: diaries,
                              ),
                            ),
                          ).then((_) => _loadTagsAndDiaries());
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: tagColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.bookmark, color: tagColor),
                              const SizedBox(width: 8),
                              Text(
                                tag.name,
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
                ),
                // 하단에 태그 추가 버튼
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: _showAddTagDialog,
                      icon: Icon(Icons.add),
                      label: Text('새 태그 추가'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
} 