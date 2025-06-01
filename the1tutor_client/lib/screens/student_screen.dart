import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../providers/auth_provider.dart';
import 'schedule_screen.dart';

class StudentScreen extends StatelessWidget {
  const StudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('=== StudentScreen build 메서드 호출됨 ===');
    return Scaffold(
      appBar: AppBar(
        title: const Text('학생 홈'),
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'schedule') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ScheduleScreen(isStudent: true),
                  ),
                );
              } else if (value == 'logout') {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                context.go('/');
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'schedule',
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.black54),
                      SizedBox(width: 8),
                      Text('시간표 보기'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.black54),
                      SizedBox(width: 8),
                      Text('로그아웃'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final profile = appState.userProfile;
          
          if (profile == null) {
            print('프로필이 null입니다. 로딩 표시');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('사용자 정보를 불러오는 중...'),
                ],
              ),
            );
          }
          
          print('프로필 로드됨: ${profile.name}');
          return StudentScreenWithTabs();
        },
      ),
    );
  }
}

class StudentScreenWithTabs extends StatefulWidget {
  const StudentScreenWithTabs({super.key});

  @override
  State<StudentScreenWithTabs> createState() => _StudentScreenWithTabsState();
}

class _StudentScreenWithTabsState extends State<StudentScreenWithTabs> {
  int selectedTabIndex = 0;
  bool _isLoading = false;

  Future<void> _refreshData() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.refreshStudentData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터 새로고침 실패: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final profile = appState.userProfile;
        final matchedSubjects = appState.matchedSubjects;
        final pendingSubjects = appState.pendingSubjects;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 섹션
              _buildProfileSection(profile!),
              const SizedBox(height: 24),
              
              // 매칭된 과목이 있거나 매칭중인 과목이 있을 때만 탭과 버튼 표시
              if (appState.hasMatchedSubjects || appState.hasPendingSubjects) ...[
                // 또다른 과외받기 버튼 (탭 위로 이동)
                if (appState.hasMatchedSubjects || appState.hasPendingSubjects) ...[
                  _buildAnotherTutoringButton(),
                  const SizedBox(height: 20),
                ],
                
                // 탭 버튼들
                _buildTabButtons(),
                const SizedBox(height: 16),
                
                // 탭 내용
                if (_isLoading) ...[
                  Container(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ] else if (selectedTabIndex == 0) ...[
                  _buildMatchedSubjectsContent(matchedSubjects),
                ] else ...[
                  _buildPendingSubjectsContent(pendingSubjects),
                ],
                
                // 새로고침 버튼 추가
                if (appState.hasMatchedSubjects || appState.hasPendingSubjects) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _refreshData,
                      icon: _isLoading 
                          ? SizedBox(
                              width: 16, 
                              height: 16, 
                              child: CircularProgressIndicator(strokeWidth: 2)
                            )
                          : Icon(Icons.refresh),
                      label: Text(_isLoading ? '새로고침 중...' : '새로고침'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ] else ...[
                // 매칭된 과목도 매칭중인 과목도 없을 때
                _buildNoMatchMessage(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedTabIndex = 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selectedTabIndex == 0 ? Colors.blue.shade500 : Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Text(
                '매칭된 과목',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selectedTabIndex == 0 ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedTabIndex = 1),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selectedTabIndex == 1 ? Colors.blue.shade500 : Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Text(
                '매칭중인 과목',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selectedTabIndex == 1 ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnotherTutoringButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.go('/matching'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade500,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, size: 24),
            const SizedBox(width: 12),
            const Text(
              '또다른 과외받기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchedSubjectsContent(List<Subject> subjects) {
    if (subjects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey.shade600,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              '매칭된 과목이 없습니다',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '매칭된 과목',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            subject.name.substring(0, 2),
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '튜터: ${subject.tutor}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '다음 수업: ${DateFormat('MM/dd HH:mm').format(subject.nextClass)}',
                                style: TextStyle(
                                  color: Colors.green.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => context.go('/chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6366f1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '과외방이 열려있습니다',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPendingSubjectsContent(List<PendingSubject> subjects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '매칭 진행중인 과목',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            IconButton(
              onPressed: () async {
                await _refreshData();
              },
              icon: Icon(Icons.refresh, color: Colors.blue.shade600),
              tooltip: '새로고침',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (subjects.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.hourglass_empty,
                  color: Colors.grey.shade600,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  '매칭 진행중인 과목이 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '새로운 과외를 요청해보세요!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: Icon(
                              Icons.schedule,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '요청일: ${DateFormat('MM/dd').format(subject.requestDate)}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '매칭중',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '학습 목표: ${subject.learningGoal}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '선호 스타일: ${subject.tutorStyle}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '희망 시간: ${subject.selectedTimeSlots.take(3).join(', ')}${subject.selectedTimeSlots.length > 3 ? ' 외 ${subject.selectedTimeSlots.length - 3}개' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildProfileSection(UserProfile profile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.grade ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (profile.school != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '학교: ${profile.school}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
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
  }

  Widget _buildNoMatchMessage() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade600,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                '아직 매칭된 과목이 없습니다',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '새로운 과외를 요청하거나\n기존 요청 상태를 확인해보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // 과외받기 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/matching'),
            icon: Icon(Icons.add_circle_outline),
            label: Text('과외받기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade500,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 새로고침 버튼
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _refreshData,
            icon: _isLoading 
                ? SizedBox(
                    width: 16, 
                    height: 16, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  )
                : Icon(Icons.refresh),
            label: Text(_isLoading ? '새로고침 중...' : '새로고침'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
} 