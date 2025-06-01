package com.the1tutor.the1tutor_server.controller;

import com.the1tutor.the1tutor_server.dto.MatchRequestDto;
import com.the1tutor.the1tutor_server.dto.TutoringSessionDto;
import com.the1tutor.the1tutor_server.service.MatchingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/student")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class StudentController {
    
    private final MatchingService matchingService;
    
    /**
     * 매칭 요청 생성
     */
    @PostMapping("/{studentId}/match-request")
    public ResponseEntity<MatchRequestDto.Response> createMatchRequest(
            @PathVariable Long studentId,
            @Valid @RequestBody MatchRequestDto.CreateRequest request) {
        
        log.info("=== 매칭 요청 생성 시작 ===");
        log.info("학생 ID: {}", studentId);
        log.info("요청 데이터:");
        log.info("  - 과목: {}", request.getSubject());
        log.info("  - 학습 목표: {}", request.getLearningGoal());
        log.info("  - 튜터 스타일: {}", request.getTutorStyle());
        log.info("  - 수업 방식: {}", request.getClassMethod());
        log.info("  - 선택된 시간대: {}", request.getSelectedTimeSlots());
        log.info("  - 신청 동기: {}", request.getMotivation());
        
        try {
            MatchRequestDto.Response response = matchingService.createMatchRequest(studentId, request);
            
            log.info("=== 매칭 요청 생성 성공 ===");
            log.info("생성된 요청 ID: {}", response.getId());
            log.info("요청 상태: {}", response.getStatus());
            log.info("=====================================");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("=== 매칭 요청 생성 실패 ===");
            log.error("에러 메시지: {}", e.getMessage(), e);
            log.error("============================");
            return ResponseEntity.badRequest().build();
        }
    }
    
    /**
     * 학생의 매칭된 과목 목록 조회
     */
    @GetMapping("/{studentId}/matched-subjects")
    public ResponseEntity<List<TutoringSessionDto.StudentSubjectResponse>> getMatchedSubjects(
            @PathVariable Long studentId) {
        try {
            List<TutoringSessionDto.StudentSubjectResponse> subjects = 
                    matchingService.getStudentMatchedSubjects(studentId);
            return ResponseEntity.ok(subjects);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    /**
     * 학생의 대기 중인 매칭 요청 조회
     */
    @GetMapping("/{studentId}/pending-requests")
    public ResponseEntity<List<MatchRequestDto.Response>> getPendingRequests(
            @PathVariable Long studentId) {
        try {
            List<MatchRequestDto.Response> requests = 
                    matchingService.getStudentPendingRequests(studentId);
            return ResponseEntity.ok(requests);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
} 