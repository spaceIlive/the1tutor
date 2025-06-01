import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class TutorRegistrationScreen extends StatefulWidget {
  const TutorRegistrationScreen({super.key});

  @override
  State<TutorRegistrationScreen> createState() => _TutorRegistrationScreenState();
}

class _TutorRegistrationScreenState extends State<TutorRegistrationScreen> {
  String get applicationForm {
    final appState = Provider.of<AppState>(context, listen: false);
    final profile = appState.userProfile;
    
    return '''
The1Tutor 튜터 지원서

====================
기본 정보
====================
이름: 
이메일: 
대학교: 
학과: 

====================
IB 성적 (필수)
====================
IB 총점: ___/45점

각 과목별 점수:
- 과목명: ___/7점
- 과목명: ___/7점
- 과목명: ___/7점
- 과목명: ___/7점
- 과목명: ___/7점
- 과목명: ___/7점

⚠️ **중요: IB 성적을 증명할 수 있는 공식 성적표를 반드시 첨부해주세요!**

====================
지원 동기 (200자 내외)
====================
[여기에 The1Tutor 플랫폼에서 튜터로 활동하고 싶은 이유를 작성해주세요]

====================
과외 경험 (해당사항이 있는 경우)
====================
[과외 경험이 있다면 자세히 작성해주세요 (기간, 과목, 성과 등)]

====================
전문 분야
====================
[가르칠 수 있는 IB 과목들을 모두 나열해주세요]
예: Mathematics HL, Physics HL, Chemistry SL 등

====================
수업 철학
====================
[학생들을 어떻게 가르치고 싶은지, 교육에 대한 철학을 작성해주세요]


====================
수업 영상 (필수)
====================
🎥 **5분짜리 모의 수업 영상을 제작하여 첨부해주세요!**

영상 내용:
- 본인이 가장 자신있는 IB 과목 중 하나의 주제로 5분간 수업 진행
- 학생에게 설명하듯이 자연스럽게 진행
- 얼굴은 안나와도 됨

영상 업로드 방법:
- YouTube 링크 (비공개 또는 링크만 아는 사람만 볼 수 있도록 설정)
- Google Drive 링크 (공유 권한 설정)
- 기타 클라우드 저장소 링크

영상 링크: ________________

====================
기타 사항
====================
[추가로 전달하고 싶은 내용이 있다면 작성해주세요]

📋 **제출 시 반드시 첨부해야 할 서류:**
1. ⚠️ IB 공식 성적표 (스캔본 또는 사진)
2. 🎥 5분짜리 모의 수업 영상 링크

위 내용을 작성하여 gyun6266@gmail.com으로 보내주시면
검토 후 승인 여부를 알려드리겠습니다.
''';
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: applicationForm));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('지원서 양식이 클립보드에 복사되었습니다!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/'),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '튜터 등록 신청',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 56), // 아이콘 버튼 공간 확보
                  ],
                ),
              ),

              // 메인 콘텐츠
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // 안내 메시지
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                                  const SizedBox(width: 8),
                                  Text(
                                    '튜터 승인 대기 중',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'The1Tutor 플랫폼에서 튜터로 활동하기 위해서는 관리자 승인이 필요합니다.',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '아래 지원서 양식을 복사하여 작성 후 이메일로 보내주세요.',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 지원서 양식 제목 - 가운데 정렬
                        Text(
                          '지원서 양식',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        
                        // 지원서 양식 컨테이너
                        Expanded(
                          child: Center(
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 600), // 최대 너비 제한
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  applicationForm,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade800,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // 지원서 복사 버튼만 남기기 - 가운데 배치
                        Center(
                          child: SizedBox(
                            width: 200,
                            child: ElevatedButton.icon(
                              onPressed: _copyToClipboard,
                              icon: const Icon(Icons.copy),
                              label: const Text('지원서 복사'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF667eea),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 