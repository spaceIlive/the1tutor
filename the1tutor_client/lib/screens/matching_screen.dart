import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  String? selectedLevel; // HL/SL 선택
  String? selectedCategory;
  String? selectedSubject;
  String? selectedTutorStyle;
  List<String> selectedTimeSlots = [];
  
  final TextEditingController learningGoalController = TextEditingController();
  final TextEditingController motivationController = TextEditingController();

  // 1단계: 레벨 선택
  final List<String> levels = ['HL', 'SL'];

  // 2단계: 과목 카테고리
  final List<String> subjectCategories = [
    'Mathematics',
    'Sciences', 
    'Languages',
    'Humanities',
    'Arts'
  ];

  // 3단계: 세부 과목 (레벨과 카테고리에 따라 결정)
  Map<String, Map<String, List<String>>> get detailedSubjects => {
    'Mathematics': {
      'HL': ['Mathematics Analysis and Approaches HL', 'Mathematics Applications and Interpretation HL'],
      'SL': ['Mathematics Analysis and Approaches SL', 'Mathematics Applications and Interpretation SL'],
    },
    'Sciences': {
      'HL': ['Physics HL', 'Chemistry HL', 'Biology HL', 'Computer Science HL'],
      'SL': ['Physics SL', 'Chemistry SL', 'Biology SL', 'Computer Science SL'],
    },
    'Languages': {
      'HL': ['English A: Literature HL', 'English A: Language and Literature HL', 'Korean A: Literature HL'],
      'SL': ['English A: Literature SL', 'English A: Language and Literature SL', 'Korean A: Literature SL', 'English B SL'],
    },
    'Humanities': {
      'HL': ['History HL', 'Geography HL', 'Economics HL', 'Psychology HL'],
      'SL': ['History SL', 'Geography SL', 'Economics SL', 'Psychology SL'],
    },
    'Arts': {
      'HL': ['Visual Arts HL', 'Music HL', 'Theatre HL'],
      'SL': ['Visual Arts SL', 'Music SL', 'Theatre SL'],
    },
  };

  // 튜터 성향 옵션
  final List<Map<String, String>> tutorStyles = [
    {
      'id': 'friendly',
      'title': '😊 친근하고 편안한 분위기',
      'description': '부담 없이 질문하고 소통할 수 있는 튜터'
    },
    {
      'id': 'systematic',
      'title': '📚 체계적이고 꼼꼼한 지도',
      'description': '계획적이고 단계별로 체계적으로 가르치는 튜터'
    },
    {
      'id': 'creative',
      'title': '💡 창의적이고 유연한 방식',
      'description': '다양한 방법으로 재미있게 가르치는 튜터'
    },
  ];

  bool get isFormValid =>
      selectedSubject != null &&
      learningGoalController.text.isNotEmpty &&
      selectedTutorStyle != null &&
      selectedTimeSlots.isNotEmpty &&
      motivationController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('과외 매칭 신청'),
        backgroundColor: Colors.orange.shade500,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 과목 선택
            _buildSubjectSelection(),
            const SizedBox(height: 24),
            
            // 2. 수업받고싶은 부분
            _buildLearningGoalSection(),
            const SizedBox(height: 24),
            
            // 3. 튜터 성향 선택
            _buildTutorStyleSection(),
            const SizedBox(height: 24),
            
            // 4. 수업 방식 (고정)
            _buildClassMethodSection(),
            const SizedBox(height: 24),
            
            // 5. 수업 시간대
            _buildTimeSlotSection(),
            const SizedBox(height: 24),
            
            // 6. 신청동기
            _buildMotivationSection(),
            const SizedBox(height: 32),
            
            // 매칭신청하기 버튼
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. 과목 선택',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // 1단계: HL/SL 레벨
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                          ),
                        ),
                        child: const Text(
                          '레벨',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: levels.map((level) {
                            final isSelected = selectedLevel == level;
                            return ListTile(
                              dense: true,
                              title: Text(
                                level,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.orange.shade700 : Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              selected: isSelected,
                              selectedTileColor: Colors.orange.shade100,
                              onTap: () {
                                setState(() {
                                  selectedLevel = level;
                                  selectedCategory = null;
                                  selectedSubject = null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 2단계: 카테고리
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                          ),
                        ),
                        child: const Text(
                          '카테고리',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: selectedLevel == null
                            ? const Center(
                                child: Text(
                                  '레벨을 먼저\n선택해주세요',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              )
                            : ListView(
                                children: subjectCategories.map((category) {
                                  final isSelected = selectedCategory == category;
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      category,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? Colors.orange.shade700 : Colors.black,
                                        fontSize: 13,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedTileColor: Colors.orange.shade100,
                                    onTap: () {
                                      setState(() {
                                        selectedCategory = category;
                                        selectedSubject = null;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              // 3단계: 세부 과목
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                          ),
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                          ),
                        ),
                        child: const Text(
                          '세부 과목',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: selectedLevel == null || selectedCategory == null
                            ? const Center(
                                child: Text(
                                  '레벨과 카테고리를\n선택해주세요',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              )
                            : ListView(
                                children: (detailedSubjects[selectedCategory!]?[selectedLevel!] ?? []).map((subject) {
                                  final isSelected = selectedSubject == subject;
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      subject,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? Colors.orange.shade700 : Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedTileColor: Colors.orange.shade100,
                                    onTap: () {
                                      setState(() {
                                        selectedSubject = subject;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (selectedSubject != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '선택된 과목: $selectedSubject',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLearningGoalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. 수업받고싶은 부분',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: learningGoalController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '어떤 부분을 중점적으로 배우고 싶은지 자세히 적어주세요\n예: 미적분 기초 개념부터 문제 풀이까지',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orange.shade500),
            ),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildTutorStyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3. 선호하는 튜터 성향',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Column(
          children: tutorStyles.map((style) {
            final isSelected = selectedTutorStyle == style['id'];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedTutorStyle = style['id'];
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Colors.orange.shade500 : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected ? Colors.orange.shade50 : null,
                  ),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: style['id']!,
                        groupValue: selectedTutorStyle,
                        onChanged: (value) {
                          setState(() {
                            selectedTutorStyle = value;
                          });
                        },
                        activeColor: Colors.orange.shade500,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              style['title']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isSelected ? Colors.orange.shade700 : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              style['description']!,
                              style: TextStyle(
                                color: isSelected ? Colors.orange.shade600 : Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildClassMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '4. 수업 방식',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.videocam, color: Colors.blue.shade600),
              const SizedBox(width: 12),
              const Text(
                '줌에서 온라인으로 진행합니다',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '5. 가능한 수업 시간대',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _showTimeSlotSelector(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple.shade500,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.schedule),
              const SizedBox(width: 8),
              const Text(
                '시간대 고르기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        if (selectedTimeSlots.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '선택된 시간대:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: selectedTimeSlots.map((timeSlot) {
                    return Chip(
                      label: Text(timeSlot),
                      backgroundColor: Colors.purple.shade100,
                      labelStyle: TextStyle(color: Colors.purple.shade700),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMotivationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '6. 신청동기',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: motivationController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '과외를 받고싶은 이유나 목표를 자세히 적어주세요\n예: 내년 IB 시험을 대비하여 체계적으로 준비하고 싶습니다',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orange.shade500),
            ),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isFormValid ? _submitMatchingRequest : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid ? Colors.orange.shade500 : Colors.grey.shade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isFormValid ? 2 : 0,
        ),
        child: Text(
          '매칭신청하기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isFormValid ? Colors.white : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  void _showTimeSlotSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TimeSlotSelectorDialog(
          selectedTimeSlots: selectedTimeSlots,
          onTimeSlotsChanged: (newTimeSlots) {
            setState(() {
              selectedTimeSlots = newTimeSlots;
            });
          },
        );
      },
    );
  }

  void _submitMatchingRequest() async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    print('=== 매칭 요청 시작 ===');
    print('선택된 과목: $selectedSubject');
    print('학습 목표: ${learningGoalController.text}');
    print('선택된 튜터 스타일 ID: $selectedTutorStyle');
    print('선택된 시간대: $selectedTimeSlots');
    print('신청 동기: ${motivationController.text}');
    
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('매칭 요청을 생성하는 중...'),
            ],
          ),
        );
      },
    );
    
    try {
      // 튜터 스타일 제목 찾기
      final tutorStyleTitle = tutorStyles.firstWhere(
        (style) => style['id'] == selectedTutorStyle
      )['title']!;
      
      print('변환된 튜터 스타일: $tutorStyleTitle');
      
      print('=== API 호출 시작 ===');
      print('AppState.createMatchRequest 호출 중...');
      
      // 실제 API 호출
      await appState.createMatchRequest(
        subject: selectedSubject!,
        learningGoal: learningGoalController.text,
        tutorStyle: tutorStyleTitle,
        classMethod: '온라인', // 고정값
        selectedTimeSlots: selectedTimeSlots,
        motivation: motivationController.text,
      );
      
      print('=== API 호출 성공 ===');
      print('서버에서 성공적으로 매칭 요청이 생성되었습니다.');
      
      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();
      
      // 성공 메시지 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text('매칭 요청 완료'),
              ],
            ),
            content: Text('${selectedSubject!} 과외 매칭 요청이 성공적으로 접수되었습니다!\n\n곧 최적의 튜터가 매칭될 예정입니다.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // 학생 홈으로 이동
                  context.go('/student');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();
      
      print('=== API 호출 실패 ===');
      print('에러 타입: ${e.runtimeType}');
      print('에러 메시지: $e');
      print('스택 트레이스: ${StackTrace.current}');
      
      // 에러 메시지 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                const Text('매칭 요청 실패'),
              ],
            ),
            content: Text('매칭 요청 중 오류가 발생했습니다.\n\n오류 내용: ${e.toString().replaceAll('Exception: ', '')}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }
}

class TimeSlotSelectorDialog extends StatefulWidget {
  final List<String> selectedTimeSlots;
  final Function(List<String>) onTimeSlotsChanged;

  const TimeSlotSelectorDialog({
    super.key,
    required this.selectedTimeSlots,
    required this.onTimeSlotsChanged,
  });

  @override
  State<TimeSlotSelectorDialog> createState() => _TimeSlotSelectorDialogState();
}

class _TimeSlotSelectorDialogState extends State<TimeSlotSelectorDialog> {
  final List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  final List<String> timeSlots = [];
  List<String> selectedSlots = [];

  @override
  void initState() {
    super.initState();
    selectedSlots = List.from(widget.selectedTimeSlots);
    
    // 30분 간격으로 시간대 생성 (09:00 ~ 23:30, 00:00 ~ 03:30)
    // 09:00 ~ 23:30
    for (int hour = 9; hour <= 23; hour++) {
      timeSlots.add('${hour.toString().padLeft(2, '0')}:00');
      timeSlots.add('${hour.toString().padLeft(2, '0')}:30');
    }
    
    // 00:00 ~ 03:30 (다음날 새벽)
    for (int hour = 0; hour <= 3; hour++) {
      timeSlots.add('${hour.toString().padLeft(2, '0')}:00');
      timeSlots.add('${hour.toString().padLeft(2, '0')}:30');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  '가능한 모든 수업 시간대를 선택해주세요',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      const DataColumn(label: Text('시간')),
                      ...weekdays.map((day) => DataColumn(label: Text(day))),
                    ],
                    rows: timeSlots.map((time) {
                      return DataRow(
                        cells: [
                          DataCell(Text(time)),
                          ...weekdays.map((day) {
                            final slotId = '$day $time';
                            final isSelected = selectedSlots.contains(slotId);
                            return DataCell(
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedSlots.remove(slotId);
                                    } else {
                                      selectedSlots.add(slotId);
                                    }
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.purple.shade500 : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedSlots.clear();
                    });
                  },
                  child: const Text('전체 해제'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onTimeSlotsChanged(selectedSlots);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade500,
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 