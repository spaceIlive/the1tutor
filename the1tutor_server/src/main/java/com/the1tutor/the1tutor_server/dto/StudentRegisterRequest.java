package com.the1tutor.the1tutor_server.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class StudentRegisterRequest {
    
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
    private String grade; // Year 7-12 (MYP 2 ~ DP 2)
} 