import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';

class ScheduleScreen extends StatefulWidget {
  final bool isStudent;
  
  const ScheduleScreen({super.key, required this.isStudent});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ApiClient _apiClient = ApiClient();
  Map<String, Set<String>> _selectedSlots = {};
  Map<String, Map<String, String>> _bookedSlots = {};
  Map<String, Map<String, String>> _scheduledClasses = {};
  bool _isLoading = false;

  final List<String> _weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  final List<String> _timeSlots = [
    '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00',
    '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00', 
    '00:00', '01:00', '02:00', '03:00'
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appState = Provider.of<AppState>(context, listen: false);
      final profile = appState.userProfile;
      
      if (profile == null) return;
      
      final userId = profile.userId;
      
      if (widget.isStudent) {
        // 학생 시간표 로드
        final response = await _apiClient.getStudentSchedule(userId);
        setState(() {
          _scheduledClasses = Map<String, Map<String, String>>.from(
            response['scheduledClasses'] ?? {}
          );
        });
      } else {
        // 튜터 시간표 로드
        final response = await _apiClient.getTutorSchedule(userId);
        setState(() {
          final availableSlots = Set<String>.from(response['availableSlots'] ?? []);
          _selectedSlots = {};
          for (String slot in availableSlots) {
            final parts = slot.split('-');
            if (parts.length == 2) {
              final day = parts[0];
              final time = parts[1];
              _selectedSlots[day] = _selectedSlots[day] ?? <String>{};
              _selectedSlots[day]!.add(time);
            }
          }
          
          _bookedSlots = Map<String, Map<String, String>>.from(
            response['bookedSlots'] ?? {}
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('시간표를 불러오는데 실패했습니다: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSchedule() async {
    if (widget.isStudent) return; // 학생은 저장 불가
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appState = Provider.of<AppState>(context, listen: false);
      final profile = appState.userProfile;
      
      if (profile == null) return;
      
      final userId = profile.userId;
      
      // 선택된 슬롯들을 "요일-시간" 형태로 변환
      Set<String> availableSlots = {};
      _selectedSlots.forEach((day, times) {
        for (String time in times) {
          availableSlots.add('$day-$time');
        }
      });
      
      await _apiClient.updateTutorAvailableSlots(userId, availableSlots);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시간표가 성공적으로 저장되었습니다!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('시간표 저장에 실패했습니다: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleTimeSlot(String day, String time) {
    if (widget.isStudent) return; // 학생은 수정 불가
    
    final slotKey = '$day-$time';
    if (_bookedSlots.containsKey(slotKey)) return; // 매칭된 시간은 수정 불가
    
    setState(() {
      _selectedSlots[day] = _selectedSlots[day] ?? <String>{};
      if (_selectedSlots[day]!.contains(time)) {
        _selectedSlots[day]!.remove(time);
        if (_selectedSlots[day]!.isEmpty) {
          _selectedSlots.remove(day);
        }
      } else {
        _selectedSlots[day]!.add(time);
      }
    });
  }

  Color _getSlotColor(String day, String time) {
    final slotKey = '$day-$time';
    
    if (widget.isStudent) {
      // 학생: 매칭된 수업만 표시
      if (_scheduledClasses.containsKey(slotKey)) {
        return Colors.blue.shade300;
      }
      return Colors.grey.shade100;
    } else {
      // 튜터: 매칭된 시간, 선택 가능한 시간 구분
      if (_bookedSlots.containsKey(slotKey)) {
        return Colors.red.shade300; // 매칭된 시간
      } else if (_selectedSlots[day]?.contains(time) == true) {
        return Colors.green.shade300; // 선택한 가능한 시간
      }
      return Colors.grey.shade100;
    }
  }

  Widget _buildTimeSlot(String day, String time) {
    final slotKey = '$day-$time';
    final color = _getSlotColor(day, time);
    
    String? displayText;
    String? subtitle;
    
    if (widget.isStudent && _scheduledClasses.containsKey(slotKey)) {
      final classInfo = _scheduledClasses[slotKey]!;
      displayText = classInfo['subject'];
      subtitle = classInfo['tutorName'];
    } else if (!widget.isStudent && _bookedSlots.containsKey(slotKey)) {
      final sessionInfo = _bookedSlots[slotKey]!;
      displayText = sessionInfo['subject'];
      subtitle = sessionInfo['studentName'];
    }

    return GestureDetector(
      onTap: () => _toggleTimeSlot(day, time),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (displayText != null) ...[
              Text(
                displayText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isStudent ? '수업 시간표' : '튜터 시간표'),
        backgroundColor: widget.isStudent ? Colors.blue.shade500 : const Color(0xFF667eea),
        foregroundColor: Colors.white,
        actions: [
          if (!widget.isStudent)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveSchedule,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadSchedule,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 범례
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (widget.isStudent) ...[
                        _buildLegendItem(Colors.blue.shade300, '수업 시간'),
                      ] else ...[
                        _buildLegendItem(Colors.green.shade300, '선택 가능'),
                        _buildLegendItem(Colors.red.shade300, '매칭된 수업'),
                      ],
                      _buildLegendItem(Colors.grey.shade100, '빈 시간'),
                    ],
                  ),
                ),
                
                // 시간표
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // 헤더 (요일)
                        Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Container(), // 시간 컬럼을 위한 빈 공간
                            ),
                            ..._weekdays.map((day) => Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  day,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )),
                          ],
                        ),
                        
                        // 시간 슬롯들
                        ..._timeSlots.map((time) => Row(
                          children: [
                            // 시간 라벨
                            SizedBox(
                              width: 60,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  time,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            // 요일별 슬롯
                            ..._weekdays.map((day) => Expanded(
                              child: SizedBox(
                                height: 60,
                                child: _buildTimeSlot(day, time),
                              ),
                            )),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
                
                // 안내 메시지
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.isStudent 
                        ? '매칭된 수업 시간이 표시됩니다.'
                        : '시간을 클릭하여 수업 가능한 시간을 선택하고 저장하세요.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
} 