package com.the1tutor.the1tutor_server.service;

import com.the1tutor.the1tutor_server.dto.MatchRequestDto;
import com.the1tutor.the1tutor_server.dto.TutoringSessionDto;
import com.the1tutor.the1tutor_server.entity.*;
import com.the1tutor.the1tutor_server.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.Collections;

@Service
@RequiredArgsConstructor
@Transactional
public class MatchingService {
    
    private final MatchRequestRepository matchRequestRepository;
    private final TutoringSessionRepository tutoringSessionRepository;
    private final StudentRepository studentRepository;
    private final TutorRepository tutorRepository;
    private final TutorScheduleRepository tutorScheduleRepository;
    
    /**
     * 매칭 요청 생성 및 자동 튜터 할당
     */
    public MatchRequestDto.Response createMatchRequest(Long studentId, MatchRequestDto.CreateRequest request) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다."));
        
        // 매칭 알고리즘으로 최적의 튜터 찾기
        Optional<Tutor> optimalTutor = findOptimalTutor(request);
        
        MatchRequest matchRequest = MatchRequest.builder()
                .student(student)
                .tutor(optimalTutor.orElse(null)) // 매칭된 튜터가 있으면 할당
                .subject(request.getSubject())
                .learningGoal(request.getLearningGoal())
                .tutorStyle(request.getTutorStyle())
                .classMethod(request.getClassMethod())
                .selectedTimeSlots(request.getSelectedTimeSlots())
                .motivation(request.getMotivation())
                .status(MatchRequest.RequestStatus.PENDING)
                .build();
        
        matchRequest = matchRequestRepository.save(matchRequest);
        
        return MatchRequestDto.Response.builder()
                .id(matchRequest.getId())
                .studentName(student.getUser().getName())
                .subject(matchRequest.getSubject())
                .learningGoal(matchRequest.getLearningGoal())
                .tutorStyle(matchRequest.getTutorStyle())
                .selectedTimeSlots(matchRequest.getSelectedTimeSlots())
                .motivation(matchRequest.getMotivation())
                .status(matchRequest.getStatus().name())
                .createdAt(matchRequest.getCreatedAt())
                .build();
    }
    
    /**
     * 매칭 알고리즘: 최적의 튜터 찾기
     */
    private Optional<Tutor> findOptimalTutor(MatchRequestDto.CreateRequest request) {
        // 1. 해당 과목을 가르칠 수 있는 승인된 튜터들 조회
        List<Tutor> availableTutors = tutorRepository.findApprovedTutorsBySubject(request.getSubject());
        
        if (availableTutors.isEmpty()) {
            return Optional.empty();
        }
        
        // 2. 시간표 매칭 체크 및 점수 계산
        Tutor bestTutor = null;
        int highestScore = -1;
        
        for (Tutor tutor : availableTutors) {
            int score = calculateMatchingScore(tutor, request);
            if (score > highestScore) {
                highestScore = score;
                bestTutor = tutor;
            }
        }
        
        return Optional.ofNullable(bestTutor);
    }
    
    /**
     * 튜터-요청 매칭 점수 계산
     */
    private int calculateMatchingScore(Tutor tutor, MatchRequestDto.CreateRequest request) {
        int score = 0;
        
        // 1. 과목 전문성 (이미 필터링되어 있음) +10점
        score += 10;
        
        // 2. 시간대 겹침 체크
        TutorSchedule schedule = tutorScheduleRepository.findById(tutor.getId()).orElse(null);
        if (schedule != null) {
            long matchingTimeSlots = request.getSelectedTimeSlots().stream()
                    .filter(timeSlot -> schedule.getAvailableSlots().contains(timeSlot))
                    .count();
            
            // 매칭되는 시간대가 많을수록 높은 점수
            score += (int) (matchingTimeSlots * 5);
        }
        
        // 3. 튜터 성향 매칭 (추후 튜터 엔티티에 성향 필드 추가 가능)
        // 현재는 기본 점수만 부여
        score += 3;
        
        return score;
    }
    
    /**
     * 튜터가 매칭 요청 수락
     */
    public TutoringSessionDto.Response acceptMatchRequest(Long tutorId, Long requestId) {
        MatchRequest matchRequest = matchRequestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("매칭 요청을 찾을 수 없습니다."));
        
        Tutor tutor = tutorRepository.findById(tutorId)
                .orElseThrow(() -> new RuntimeException("튜터를 찾을 수 없습니다."));
        
        // 권한 체크
        if (!matchRequest.getTutor().getId().equals(tutorId)) {
            throw new RuntimeException("해당 매칭 요청에 대한 권한이 없습니다.");
        }
        
        // 매칭 요청 상태 변경
        matchRequest.setStatus(MatchRequest.RequestStatus.ACCEPTED);
        matchRequestRepository.save(matchRequest);
        
        // 과외 세션 생성
        TutoringSession session = TutoringSession.builder()
                .student(matchRequest.getStudent())
                .tutor(tutor)
                .matchRequest(matchRequest)
                .subject(matchRequest.getSubject())
                .scheduledTime(calculateNextClassTime(matchRequest.getSelectedTimeSlots()))
                .status(TutoringSession.SessionStatus.SCHEDULED)
                .build();
        
        session = tutoringSessionRepository.save(session);
        
        // 튜터 시간표에 고정 시간 추가
        updateTutorFixedSlots(tutorId, matchRequest.getSelectedTimeSlots());
        
        return TutoringSessionDto.Response.builder()
                .id(session.getId())
                .subject(session.getSubject())
                .student(session.getStudent().getUser().getName())
                .tutor(session.getTutor().getUser().getName())
                .nextClass(session.getScheduledTime())
                .status(session.getStatus().name())
                .build();
    }
    
    /**
     * 튜터가 매칭 요청 거절
     */
    public void rejectMatchRequest(Long tutorId, Long requestId) {
        MatchRequest matchRequest = matchRequestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("매칭 요청을 찾을 수 없습니다."));
        
        // 권한 체크
        if (!matchRequest.getTutor().getId().equals(tutorId)) {
            throw new RuntimeException("해당 매칭 요청에 대한 권한이 없습니다.");
        }
        
        // 매칭 요청 상태 변경
        matchRequest.setStatus(MatchRequest.RequestStatus.REJECTED);
        matchRequest.setTutor(null); // 튜터 할당 해제
        
        matchRequestRepository.save(matchRequest);
        
        // TODO: 다른 튜터에게 재할당하는 로직 구현 가능
    }
    
    /**
     * 다음 수업 시간 계산
     */
    private LocalDateTime calculateNextClassTime(List<String> timeSlots) {
        // 간단한 구현: 첫 번째 시간대를 기준으로 다음 주 동일 시간으로 설정
        // 실제로는 더 복잡한 스케줄링 로직 필요
        return LocalDateTime.now().plusDays(1).withHour(14).withMinute(0);
    }
    
    /**
     * 튜터 시간표에 고정 시간 추가
     */
    private void updateTutorFixedSlots(Long tutorId, List<String> newFixedSlots) {
        TutorSchedule schedule = tutorScheduleRepository.findById(tutorId)
                .orElse(TutorSchedule.builder()
                        .id(tutorId)
                        .tutor(tutorRepository.getReferenceById(tutorId))
                        .availableSlots(Collections.emptySet())
                        .fixedSlots(Collections.emptySet())
                        .build());
        
        schedule.getFixedSlots().addAll(newFixedSlots);
        tutorScheduleRepository.save(schedule);
    }
    
    /**
     * 학생의 매칭된 과목 조회
     */
    @Transactional(readOnly = true)
    public List<TutoringSessionDto.StudentSubjectResponse> getStudentMatchedSubjects(Long studentId) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다."));
        
        List<TutoringSession> sessions = tutoringSessionRepository
                .findByStudentAndStatus(student, TutoringSession.SessionStatus.SCHEDULED);
        
        return sessions.stream()
                .map(session -> TutoringSessionDto.StudentSubjectResponse.builder()
                        .id(session.getId())
                        .name(session.getSubject())
                        .tutor(session.getTutor().getUser().getName())
                        .nextClass(session.getScheduledTime())
                        .build())
                .collect(Collectors.toList());
    }
    
    /**
     * 학생의 대기 중인 매칭 요청 조회
     */
    @Transactional(readOnly = true)
    public List<MatchRequestDto.Response> getStudentPendingRequests(Long studentId) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("학생을 찾을 수 없습니다."));
        
        List<MatchRequest> pendingRequests = matchRequestRepository
                .findByStudentAndStatus(student, MatchRequest.RequestStatus.PENDING);
        
        return pendingRequests.stream()
                .map(request -> MatchRequestDto.Response.builder()
                        .id(request.getId())
                        .studentName(request.getStudent().getUser().getName())
                        .subject(request.getSubject())
                        .learningGoal(request.getLearningGoal())
                        .tutorStyle(request.getTutorStyle())
                        .selectedTimeSlots(request.getSelectedTimeSlots())
                        .motivation(request.getMotivation())
                        .status(request.getStatus().name())
                        .createdAt(request.getCreatedAt())
                        .build())
                .collect(Collectors.toList());
    }
    
    /**
     * 튜터에게 온 매칭 요청 조회
     */
    @Transactional(readOnly = true)
    public List<MatchRequestDto.TutorViewResponse> getTutorMatchRequests(Long tutorId) {
        Tutor tutor = tutorRepository.findById(tutorId)
                .orElseThrow(() -> new RuntimeException("튜터를 찾을 수 없습니다."));
        
        List<MatchRequest> requests = matchRequestRepository
                .findByTutorAndStatus(tutor, MatchRequest.RequestStatus.PENDING);
        
        return requests.stream()
                .map(request -> MatchRequestDto.TutorViewResponse.builder()
                        .id(request.getId())
                        .studentName(request.getStudent().getUser().getName())
                        .subject(request.getSubject())
                        .message(request.getLearningGoal() + " / " + request.getMotivation())
                        .status(request.getStatus().name())
                        .createdAt(request.getCreatedAt())
                        .build())
                .collect(Collectors.toList());
    }
    
    /**
     * 튜터의 진행 중인 과외 세션 조회
     */
    @Transactional(readOnly = true)
    public List<TutoringSessionDto.Response> getTutorSessions(Long tutorId) {
        Tutor tutor = tutorRepository.findById(tutorId)
                .orElseThrow(() -> new RuntimeException("튜터를 찾을 수 없습니다."));
        
        List<TutoringSession> sessions = tutoringSessionRepository
                .findByTutorAndStatus(tutor, TutoringSession.SessionStatus.SCHEDULED);
        
        return sessions.stream()
                .map(session -> TutoringSessionDto.Response.builder()
                        .id(session.getId())
                        .subject(session.getSubject())
                        .student(session.getStudent().getUser().getName())
                        .tutor(session.getTutor().getUser().getName())
                        .nextClass(session.getScheduledTime())
                        .status(session.getStatus().name())
                        .build())
                .collect(Collectors.toList());
    }
} 