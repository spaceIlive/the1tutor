package com.the1tutor.the1tutor_server.dto;

import lombok.Data;
import lombok.Builder;

@Data
@Builder
public class LoginResponse {
    
    private String token;
    private Long userId;
    private String userType;
    private String message;
    private String approvalStatus; // 튜터 승인 상태 (PENDING, APPROVED, REJECTED)
} 