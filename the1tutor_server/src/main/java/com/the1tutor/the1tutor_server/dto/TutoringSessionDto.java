package com.the1tutor.the1tutor_server.dto;

import lombok.Data;
import lombok.Builder;

import java.time.LocalDateTime;

public class TutoringSessionDto {
    
    @Data
    @Builder
    public static class Response {
        private Long id;
        private String subject;
        private String student; // 학생 이름
        private String tutor;   // 튜터 이름  
        private LocalDateTime nextClass;
        private String status;
    }
    
    @Data
    @Builder
    public static class StudentSubjectResponse {
        private Long id;
        private String name; // 과목명
        private String tutor; // 튜터 이름
        private LocalDateTime nextClass;
    }
} 