package com.the1tutor.the1tutor_server.controller;

import com.the1tutor.the1tutor_server.dto.MatchRequestDto;
import com.the1tutor.the1tutor_server.dto.TutoringSessionDto;
import com.the1tutor.the1tutor_server.service.MatchingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tutor")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class TutorController {
    
    private final MatchingService matchingService;
    
    /**
     * 튜터에게 온 매칭 요청 조회
     */
    @GetMapping("/{tutorId}/match-requests")
    public ResponseEntity<List<MatchRequestDto.TutorViewResponse>> getMatchRequests(
            @PathVariable Long tutorId) {
        try {
            List<MatchRequestDto.TutorViewResponse> requests = 
                    matchingService.getTutorMatchRequests(tutorId);
            return ResponseEntity.ok(requests);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    /**
     * 매칭 요청 수락
     */
    @PostMapping("/{tutorId}/match-requests/{requestId}/accept")
    public ResponseEntity<TutoringSessionDto.Response> acceptMatchRequest(
            @PathVariable Long tutorId,
            @PathVariable Long requestId) {
        try {
            TutoringSessionDto.Response session = 
                    matchingService.acceptMatchRequest(tutorId, requestId);
            return ResponseEntity.ok(session);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    /**
     * 매칭 요청 거절
     */
    @PostMapping("/{tutorId}/match-requests/{requestId}/reject")
    public ResponseEntity<Void> rejectMatchRequest(
            @PathVariable Long tutorId,
            @PathVariable Long requestId) {
        try {
            matchingService.rejectMatchRequest(tutorId, requestId);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    /**
     * 튜터의 진행 중인 과외 세션 조회
     */
    @GetMapping("/{tutorId}/sessions")
    public ResponseEntity<List<TutoringSessionDto.Response>> getSessions(
            @PathVariable Long tutorId) {
        try {
            List<TutoringSessionDto.Response> sessions = 
                    matchingService.getTutorSessions(tutorId);
            return ResponseEntity.ok(sessions);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
} 