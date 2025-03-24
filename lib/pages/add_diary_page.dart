import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/diary.dart';
import 'bottom_nav.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../utils/image_helper.dart';
import '../models/tag.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';


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
  List<Tag> _tags = [];
  String _selectedTag = 'MY';
  List<String> _imagePaths = [];
  final _picker = ImagePicker();
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTags();
    if (widget.diary != null) {
      _contentController.text = widget.diary!.content;
      _selectedTag = widget.diary!.tag;
      _imagePaths = widget.diary!.imagePaths;
    }
  }

  Future<void> _loadTags() async {
    final tagMaps = await DatabaseHelper.instance.getAllTags();
    setState(() {
      _tags = tagMaps.map((map) => Tag.fromMap(map)).toList();
      if (_tags.isNotEmpty && _selectedTag.isEmpty) {
        _selectedTag = _tags[0].name;
      }
    });
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
        tag: _selectedTag,
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
        tag: _selectedTag,
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

  void _showAddTagDialog() {
    Color selectedColor = Colors.amber; // 기본 색상을 Material 색상으로 변경
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // StatefulBuilder 추가
        builder: (context, setState) => AlertDialog(
          title: const Text('새 태그 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: '태그 이름',
                  hintText: '새로운 태그 이름을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final Color? color = await showDialog<Color>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('태그 색상 선택'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: selectedColor,
                          onColorChanged: (color) {
                            setState(() => selectedColor = color); // setState 추가
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, selectedColor),
                          child: const Text('선택'),
                        ),
                      ],
                    ),
                  );
                  if (color != null) {
                    setState(() => selectedColor = color); // setState 추가
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedColor, // 선택된 색상 표시
                ),
                child: const Text('태그 색상 선택'),
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
                  
                  setState(() {
                    _tags.add(newTag);
                    _selectedTag = newTag.name;
                  });
                  
                  _tagController.clear();
                  if (mounted) Navigator.pop(context);
                }
              },
              child: Text('추가'),
            ),
          ],
        ),
      ),
    );
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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedTag,
                      decoration: const InputDecoration(
                        labelText: '태그 선택',
                        border: OutlineInputBorder(),
                      ),
                      items: _tags.map((Tag tag) {
                        return DropdownMenuItem(
                          value: tag.name,
                          child: Text(tag.name),
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
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: _showAddTagDialog,
                    tooltip: '새 태그 추가',
                  ),
                ],
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
    _tagController.dispose();
    super.dispose();
  }
}
