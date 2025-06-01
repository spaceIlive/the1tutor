package com.the1tutor.the1tutor_server.controller;

import com.the1tutor.the1tutor_server.service.ScheduleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@RestController
@RequestMapping("/api/schedule")
public class ScheduleController {

    @Autowired
    private ScheduleService scheduleService;

    // 튜터 시간표 조회
    @GetMapping("/tutor/{tutorId}")
    public ResponseEntity<Map<String, Object>> getTutorSchedule(@PathVariable Long tutorId) {
        try {
            Map<String, Object> schedule = scheduleService.getTutorSchedule(tutorId);
            return ResponseEntity.ok(schedule);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // 튜터 가능한 시간 저장/업데이트
    @PostMapping("/tutor/{tutorId}/available")
    public ResponseEntity<Map<String, Object>> updateTutorAvailableSlots(
            @PathVariable Long tutorId,
            @RequestBody Map<String, Object> request) {
        try {
            @SuppressWarnings("unchecked")
            List<String> availableSlotsList = (List<String>) request.get("availableSlots");
            Set<String> availableSlots = new HashSet<>(availableSlotsList);
            
            scheduleService.updateTutorAvailableSlots(tutorId, availableSlots);
            return ResponseEntity.ok(Map.of("message", "시간표가 성공적으로 저장되었습니다."));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // 학생 시간표 조회 (매칭된 수업들)
    @GetMapping("/student/{studentId}")
    public ResponseEntity<Map<String, Object>> getStudentSchedule(@PathVariable Long studentId) {
        try {
            Map<String, Object> schedule = scheduleService.getStudentSchedule(studentId);
            return ResponseEntity.ok(schedule);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
} 