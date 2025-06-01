import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../providers/auth_provider.dart';
import 'schedule_screen.dart';

class TutorHomeScreen extends StatelessWidget {
  const TutorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('=== TutorHomeScreen build 메서드 호출됨 ===');
    return Scaffold(
      appBar: AppBar(
        title: const Text('튜터 홈'),
        backgroundColor: Color(0xFF667eea),
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
                    builder: (context) => const ScheduleScreen(isStudent: false),
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
            print('튜터 프로필이 null입니다. 로딩 표시');
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
          
          print('튜터 프로필 로드됨: ${profile.name}');
          return TutorScreenWithTabs();
        },
      ),
    );
  }
}

class TutorScreenWithTabs extends StatefulWidget {
  const TutorScreenWithTabs({super.key});

  @override
  State<TutorScreenWithTabs> createState() => _TutorScreenWithTabsState();
}

class _TutorScreenWithTabsState extends State<TutorScreenWithTabs> {
  int selectedTabIndex = 0;
  bool _isLoading = false;

  Future<void> _refreshData() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.refreshTutorData();
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
        final tutoringSessions = appState.tutoringSessions;
        final matchRequests = appState.matchRequests;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 섹션
              _buildProfileSection(profile!),
              const SizedBox(height: 24),
              
              // 탭과 컨텐츠
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 탭 버튼들
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTabButton(
                              title: '매칭된 과목',
                              icon: Icons.school,
                              isSelected: selectedTabIndex == 0,
                              count: tutoringSessions.length,
                              onTap: () => setState(() => selectedTabIndex = 0),
                            ),
                          ),
                          Expanded(
                            child: _buildTabButton(
                              title: '매칭 요청',
                              icon: Icons.notifications,
                              isSelected: selectedTabIndex == 1,
                              count: matchRequests.length,
                              onTap: () => setState(() => selectedTabIndex = 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 탭 내용
                    Container(
                      height: 400,
                      padding: const EdgeInsets.all(16),
                      child: _isLoading 
                          ? Center(child: CircularProgressIndicator())
                          : selectedTabIndex == 0
                              ? _buildMatchedSubjectsTab(tutoringSessions)
                              : _buildMatchRequestsTab(matchRequests),
                    ),
                    
                    // 새로고침 버튼 추가
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(UserProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(
              Icons.psychology,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '전문 과목: ${profile.subjects?.join(', ') ?? ''}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: title == '매칭된 과목' ? Radius.circular(12) : Radius.zero,
            topRight: title == '매칭 요청' ? Radius.circular(12) : Radius.zero,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, -1),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xFF667eea) : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Color(0xFF667eea) : Colors.grey.shade600,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF667eea) : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMatchedSubjectsTab(List<TutoringSession> sessions) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '매칭된 과외가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFF667eea).withOpacity(0.1),
                  child: Text(
                    session.subject[0],
                    style: TextStyle(
                      color: Color(0xFF667eea),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.subject,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '학생: ${session.student}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '다음 수업: ${DateFormat('MM/dd HH:mm').format(session.time)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF667eea),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => context.go('/chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('채팅'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchRequestsTab(List<MatchRequest> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '새로운 매칭 요청이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Text(
                        request.studentName[0],
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.studentName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '과목: ${request.subject}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  request.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        // 거절 로직
                        try {
                          final appState = Provider.of<AppState>(context, listen: false);
                          await appState.rejectMatchRequest(request.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('매칭 요청을 거절했습니다.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('거절 처리 실패: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                        side: BorderSide(color: Colors.red.shade600),
                      ),
                      child: const Text('거절'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        // 수락 로직
                        try {
                          final appState = Provider.of<AppState>(context, listen: false);
                          await appState.acceptMatchRequest(request.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('매칭 요청을 수락했습니다!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('수락 처리 실패: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF667eea),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('수락'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 