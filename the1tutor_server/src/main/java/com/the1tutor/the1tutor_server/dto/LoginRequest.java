package com.the1tutor.the1tutor_server.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LoginRequest {
    
    @NotBlank
    @Email
    private String email;
    
    @NotBlank
    private String password;
} 