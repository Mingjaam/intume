import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/diary.dart';
import '../pages/diary_detail_page.dart';
import '../pages/add_diary_page.dart';
import '../theme/app_theme.dart';
import 'dart:io';
import '../models/tag.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Diary> _selectedDiaries = [];
  Map<DateTime, List<Diary>> _diaryEvents = {};
  List<Tag> _tags = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
    _selectedDay = _focusedDay;
    _loadTags();
    _loadDiaries();
    _loadSelectedDayDiaries();
  }

  Future<void> _loadTags() async {
    final tagMaps = await DatabaseHelper.instance.getAllTags();
    setState(() {
      _tags = tagMaps.map((map) => Tag.fromMap(map)).toList();
    });
  }

  Color _getTagColor(String tagName) {
    try {
      final tag = _tags.firstWhere(
        (tag) => tag.name == tagName,
        orElse: () => Tag(
          name: tagName,
          color: 'FF000000',
          createdAt: DateTime.now(),
        ),
      );
      
      // 색상 문자열 검증
      String colorStr = tag.color;
      if (!colorStr.startsWith('0x') && !colorStr.startsWith('FF')) {
        colorStr = 'FF$colorStr';
      }
      if (colorStr.startsWith('0x')) {
        colorStr = colorStr.substring(2);
      }
      
      return Color(int.parse(colorStr, radix: 16));
    } catch (e) {
      print('색상 변환 오류: $e, 태그명: $tagName');
      return Colors.black; // 오류 발생 시 기본 색상
    }
  }

  // 모든 일기를 불러와서 날짜별로 매핑하는 메소드
  Future<void> _loadDiaries() async {
    final diaryMaps = await DatabaseHelper.instance.queryAllRows();
    final diaries = diaryMaps.map((map) => Diary.fromMap(map)).toList();
    
    final events = <DateTime, List<Diary>>{};
    for (final diary in diaries) {
      final date = DateTime(diary.createdAt.year, diary.createdAt.month, diary.createdAt.day);
      if (events[date] == null) events[date] = [];
      events[date]!.add(diary);
    }
    
    setState(() {
      _diaryEvents = events;
    });
  }

  // 선택된 날짜의 모든 일기를 불러오는 메소드
  Future<void> _loadSelectedDayDiaries() async {
    if (_selectedDay == null) return;
    
    final startDate = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final endDate = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 23, 59, 59);
    
    final diaryMaps = await DatabaseHelper.instance.getDiariesByDateRange(startDate, endDate);
    
    setState(() {
      _selectedDiaries = diaryMaps.map((map) => Diary.fromMap(map)).toList();
    });
  }

  // 이벤트 표시를 위한 캘린더 마커 생성 메소드
  List<dynamic> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _diaryEvents[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("안녕, 민재", style: TextStyle(fontSize: 25)),
                Divider(
                  thickness: 1,
                  color: AppTheme.secondaryPink,
                ),
                TableCalendar(
                  locale: 'ko_KR',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  headerStyle: AppTheme.calendarHeaderStyle,
                  calendarStyle: AppTheme.calendarStyle,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _loadSelectedDayDiaries();
                  },
                  availableCalendarFormats: const {
                    CalendarFormat.month: '월간',
                  },
                  eventLoader: _getEventsForDay,
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return const SizedBox();
                      
                      return Positioned(
                        bottom: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: events.map((event) {
                            final diary = event as Diary;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getTagColor(diary.tag),
                              ),
                            );
                          }).take(5).toList(),
                        ),
                      );
                    },
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: AppTheme.secondaryPink,
                ),
                SizedBox(height: 16),
                _selectedDay == null
                    ? Center(
                        child: Text(
                          '날짜를 선택하면 일기를 볼 수 있어요',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('yyyy년 MM월 dd일', 'ko_KR').format(_selectedDay!),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SizedBox(height: 8),
                          _selectedDiaries.isEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    '아직 작성된 일기가 없습니다. 새 일기를 작성해보세요!',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                )
                              : Column(
                                  children: _selectedDiaries.map((diary) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DiaryDetailPage(
                                              diary: diary,
                                            ),
                                          ),
                                        ).then((_) {
                                          _loadDiaries();
                                          _loadSelectedDayDiaries();
                                        });
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.background,
                                          border: Border.all(
                                            color: _getTagColor(diary.tag),
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(0),
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 20,
                                              alignment: Alignment.centerLeft,
                                              padding: EdgeInsets.only(left: 10),
                                              child: Transform.translate(
                                                offset: Offset(0, -4),
                                                child: Icon(
                                                  Icons.bookmark,
                                                  color: _getTagColor(diary.tag),
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    diary.content.split('\n').first,
                                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  if (diary.imagePaths.isNotEmpty && diary.imagePaths[0].isNotEmpty) ...[
                                                    SizedBox(height: 8),
                                                    Container(
                                                      width: double.infinity,
                                                      height: 150,
                                                      child: ListView.builder(
                                                        scrollDirection: Axis.horizontal,
                                                        itemCount: diary.imagePaths.length,
                                                        itemBuilder: (context, index) {
                                                          if (diary.imagePaths[index].isEmpty) return SizedBox.shrink();
                                                          return Container(
                                                            width: MediaQuery.of(context).size.width - 32,
                                                            margin: EdgeInsets.only(right: index != diary.imagePaths.length - 1 ? 8 : 0),
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(4),
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
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                          SizedBox(height: 24),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const AddDiaryPage())
          ).then((_) {
            // 일기 추가 후 데이터 갱신
            _loadDiaries();
            _loadSelectedDayDiaries();
          });
        },
        backgroundColor: AppTheme.secondaryPink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
