package com.the1tutor.the1tutor_server.service;

import com.the1tutor.the1tutor_server.entity.Student;
import com.the1tutor.the1tutor_server.entity.Tutor;
import com.the1tutor.the1tutor_server.entity.TutorSchedule;
import com.the1tutor.the1tutor_server.entity.TutoringSession;
import com.the1tutor.the1tutor_server.repository.StudentRepository;
import com.the1tutor.the1tutor_server.repository.TutorRepository;
import com.the1tutor.the1tutor_server.repository.TutorScheduleRepository;
import com.the1tutor.the1tutor_server.repository.TutoringSessionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

@Service
@Transactional
public class ScheduleService {

    @Autowired
    private TutorScheduleRepository tutorScheduleRepository;

    @Autowired
    private TutorRepository tutorRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private TutoringSessionRepository tutoringSessionRepository;

    // 튜터 시간표 조회
    public Map<String, Object> getTutorSchedule(Long tutorId) {
        Optional<Tutor> tutorOpt = tutorRepository.findById(tutorId);
        if (tutorOpt.isEmpty()) {
            throw new RuntimeException("튜터를 찾을 수 없습니다.");
        }

        Optional<TutorSchedule> scheduleOpt = tutorScheduleRepository.findById(tutorId);
        
        Map<String, Object> result = new HashMap<>();
        
        if (scheduleOpt.isPresent()) {
            TutorSchedule schedule = scheduleOpt.get();
            result.put("availableSlots", schedule.getAvailableSlots());
            result.put("fixedSlots", schedule.getFixedSlots());
        } else {
            result.put("availableSlots", new HashSet<>());
            result.put("fixedSlots", new HashSet<>());
        }

        // 매칭된 수업들 정보 추가
        List<TutoringSession> sessions = tutoringSessionRepository.findByTutorId(tutorId);
        Map<String, Map<String, String>> bookedSlots = new HashMap<>();
        
        for (TutoringSession session : sessions) {
            if (session.getScheduledTime() != null) {
                String timeSlot = formatTimeSlot(session.getScheduledTime());
                Map<String, String> sessionInfo = new HashMap<>();
                sessionInfo.put("studentName", session.getStudent().getUser().getName());
                sessionInfo.put("subject", session.getSubject());
                sessionInfo.put("status", session.getStatus().name());
                bookedSlots.put(timeSlot, sessionInfo);
            }
        }
        
        result.put("bookedSlots", bookedSlots);
        
        return result;
    }

    // 튜터 가능한 시간 업데이트
    public void updateTutorAvailableSlots(Long tutorId, Set<String> availableSlots) {
        Optional<Tutor> tutorOpt = tutorRepository.findById(tutorId);
        if (tutorOpt.isEmpty()) {
            throw new RuntimeException("튜터를 찾을 수 없습니다.");
        }

        Tutor tutor = tutorOpt.get();
        
        Optional<TutorSchedule> scheduleOpt = tutorScheduleRepository.findById(tutorId);
        TutorSchedule schedule;
        
        if (scheduleOpt.isPresent()) {
            schedule = scheduleOpt.get();
        } else {
            schedule = TutorSchedule.builder()
                    .id(tutorId)
                    .tutor(tutor)
                    .availableSlots(new HashSet<>())
                    .fixedSlots(new HashSet<>())
                    .build();
        }
        
        schedule.setAvailableSlots(availableSlots);
        tutorScheduleRepository.save(schedule);
    }

    // 학생 시간표 조회
    public Map<String, Object> getStudentSchedule(Long studentId) {
        Optional<Student> studentOpt = studentRepository.findById(studentId);
        if (studentOpt.isEmpty()) {
            throw new RuntimeException("학생을 찾을 수 없습니다.");
        }

        List<TutoringSession> sessions = tutoringSessionRepository.findByStudentId(studentId);
        Map<String, Map<String, String>> scheduledClasses = new HashMap<>();
        
        for (TutoringSession session : sessions) {
            if (session.getScheduledTime() != null) {
                String timeSlot = formatTimeSlot(session.getScheduledTime());
                Map<String, String> sessionInfo = new HashMap<>();
                sessionInfo.put("tutorName", session.getTutor().getUser().getName());
                sessionInfo.put("subject", session.getSubject());
                sessionInfo.put("status", session.getStatus().name());
                scheduledClasses.put(timeSlot, sessionInfo);
            }
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("scheduledClasses", scheduledClasses);
        
        return result;
    }

    // 시간을 "요일-시간" 형태로 포맷
    private String formatTimeSlot(java.time.LocalDateTime dateTime) {
        String[] weekdays = {"일", "월", "화", "수", "목", "금", "토"};
        String dayOfWeek = weekdays[dateTime.getDayOfWeek().getValue() % 7];
        String time = String.format("%02d:00", dateTime.getHour());
        return dayOfWeek + "-" + time;
    }
} 