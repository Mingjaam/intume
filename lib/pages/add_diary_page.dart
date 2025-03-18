import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/diary.dart';
import 'bottom_nav.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../utils/image_helper.dart';

class AddDiaryPage extends StatefulWidget {
  // 수정할 일기 데이터 (새로운 일기 작성시에는 null)
  final Diary? diary;

  const AddDiaryPage({
    super.key,
    this.diary,
  });

  @override
  State<AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  final _contentController = TextEditingController();
  // 태그 목록과 선택된 태그
  final List<String> _tags = ['MY', '운동일지', '영화일지', 'instagram'];
  String _selectedTag = 'MY';  // 기본값
  List<String> _imagePaths = [];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 수정 모드일 경우 기존 데이터로 초기화
    if (widget.diary != null) {
      _contentController.text = widget.diary!.content;
      _selectedTag = widget.diary!.tag;
      _imagePaths = widget.diary!.imagePaths;
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final imagePath = await ImageHelper.saveImage(File(image.path));
      setState(() {
        _imagePaths.add(imagePath);
      });
    }
  }

  Future<void> _saveDiary() async {
    // 내용이 비어있으면 저장하지 않음
    if (_contentController.text.isEmpty) {
      return;
    }

    if (widget.diary != null) {
      // 수정 모드: 기존 이미지 중 삭제된 이미지들 처리
      final removedImages = widget.diary!.imagePaths
          .where((path) => !_imagePaths.contains(path))
          .toList();
      await ImageHelper.deleteAllImagesForDiary(removedImages);

      final updatedDiary = Diary(
        id: widget.diary!.id,
        content: _contentController.text,
        tag: _selectedTag,           // 선택된 태그 저장
        createdAt: widget.diary!.createdAt,
        imagePaths: _imagePaths,
      );

      await DatabaseHelper.instance.update(updatedDiary.toMap());
      
      if (mounted) {
        Navigator.pop(context, updatedDiary);
      }
    } else {
      // 새로운 일기 작성 모드
      final diary = Diary(
        content: _contentController.text,
        tag: _selectedTag,           // 선택된 태그 저장
        createdAt: DateTime.now(),
        imagePaths: _imagePaths,
      );

      await DatabaseHelper.instance.insert(diary.toMap());
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BottomNav()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.diary != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? '일기 수정' : '일기 작성'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveDiary,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 태그 선택 드롭다운
              DropdownButtonFormField<String>(
                value: _selectedTag,
                decoration: const InputDecoration(
                  labelText: '태그 선택',
                  border: OutlineInputBorder(),
                ),
                items: _tags.map((String tag) {
                  return DropdownMenuItem(
                    value: tag,
                    child: Text(tag),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedTag = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // 이미지 프리뷰
              if (_imagePaths.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imagePaths.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.file(
                              File(_imagePaths[index]),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _imagePaths.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              // 내용 입력 필드
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: '내용',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
