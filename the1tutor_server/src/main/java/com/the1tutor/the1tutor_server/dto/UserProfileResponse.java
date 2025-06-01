package com.the1tutor.the1tutor_server.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class UserProfileResponse {
    private Long userId;
    private String name;
    private String email;
    private String phone;
    private String school;
    private String userType;
    private LocalDateTime createdAt;
    
    // 학생 전용 필드
    private String grade;
    
    // 튜터 전용 필드
    private String major;
    private List<String> specializedSubjects;
} 