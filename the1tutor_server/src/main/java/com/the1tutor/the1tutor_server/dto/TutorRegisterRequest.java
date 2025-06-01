package com.the1tutor.the1tutor_server.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class TutorRegisterRequest {
    
    @NotBlank
    private String name;
    
    @NotBlank
    @Email
    private String email;
    
    @NotBlank
    private String password;
    
    @NotNull
    private LocalDate birthdate;
    
    @NotBlank
    private String phone;
    
    @NotBlank
    private String school;
    
    @NotBlank
    private String major; // 전공
    
    private List<String> specializedSubjects; // 전문 과목들
} 