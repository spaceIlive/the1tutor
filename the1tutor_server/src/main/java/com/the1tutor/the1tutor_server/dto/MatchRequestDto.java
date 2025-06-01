package com.the1tutor.the1tutor_server.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import lombok.Data;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

public class MatchRequestDto {
    
    @Data
    public static class CreateRequest {
        
        @NotBlank
        private String subject;
        
        @NotBlank
        private String learningGoal;
        
        @NotBlank
        private String tutorStyle;
        
        @NotBlank
        private String classMethod;
        
        @NotEmpty
        private List<String> selectedTimeSlots;
        
        @NotBlank
        private String motivation;
    }
    
    @Data
    @Builder
    public static class Response {
        private Long id;
        private String studentName;
        private String subject;
        private String learningGoal;
        private String tutorStyle;
        private List<String> selectedTimeSlots;
        private String motivation;
        private String status;
        private LocalDateTime createdAt;
    }
    
    @Data
    @Builder
    public static class TutorViewResponse {
        private Long id;
        private String studentName;
        private String subject;
        private String message; // learningGoal + motivation 조합
        private String status;
        private LocalDateTime createdAt;
    }
} 