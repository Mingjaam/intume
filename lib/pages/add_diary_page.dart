import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/diary.dart';
import 'bottom_nav.dart';

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
  // 제목과 내용을 입력받을 컨트롤러
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 수정 모드일 경우 기존 데이터로 초기화
    if (widget.diary != null) {
      _titleController.text = widget.diary!.title;
      _contentController.text = widget.diary!.content;
    }
  }

  // 일기 저장 메소드
  Future<void> _saveDiary() async {
    // 제목이나 내용이 비어있으면 저장하지 않음
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      return;
    }

    // 수정 모드인지 새로운 일기 작성 모드인지 확인
    if (widget.diary != null) {
      // 수정 모드: 기존 일기 업데이트
      final updatedDiary = Diary(
        id: widget.diary!.id,
        title: _titleController.text,
        content: _contentController.text,
        createdAt: widget.diary!.createdAt,
      );

      await DatabaseHelper.instance.update(updatedDiary.toMap());
      
      if (mounted) {
        // 수정된 일기 데이터를 이전 페이지로 전달
        Navigator.pop(context, updatedDiary);
      }
    } else {
      // 새로운 일기 작성 모드
      final diary = Diary(
        title: _titleController.text,
        content: _contentController.text,
        createdAt: DateTime.now(),
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
    // 수정 모드인지 새로운 일기 작성 모드인지에 따라 타이틀 변경
    final isEditMode = widget.diary != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? '일기 수정' : '일기 작성'),
        actions: [
          // 저장 버튼
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
              // 제목 입력 필드
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // 내용 입력 필드 (확장 가능)
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: '내용',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  expands: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  // 페이지가 종료될 때 컨트롤러 해제
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
