package com.the1tutor.the1tutor_server.controller;

import com.the1tutor.the1tutor_server.dto.*;
import com.the1tutor.the1tutor_server.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {
    
    private final AuthService authService;
    
    /**
     * 학생 회원가입
     */
    @PostMapping("/register/student")
    public ResponseEntity<LoginResponse> registerStudent(@Valid @RequestBody StudentRegisterRequest request) {
        try {
            LoginResponse response = authService.registerStudent(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    /**
     * 튜터 회원가입
     */
    @PostMapping("/register/tutor")
    public ResponseEntity<LoginResponse> registerTutor(@Valid @RequestBody TutorRegisterRequest request) {
        try {
            LoginResponse response = authService.registerTutor(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    /**
     * 로그인
     */
    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        System.out.println("=== AuthController.login 시작 ===");
        System.out.println("요청 이메일: " + request.getEmail());
        
        try {
            System.out.println("AuthService.login 호출 시작");
            LoginResponse response = authService.login(request);
            System.out.println("AuthService.login 호출 성공");
            System.out.println("응답: " + response.toString());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.out.println("=== AuthController.login 예외 발생 ===");
            System.out.println("예외 타입: " + e.getClass().getSimpleName());
            System.out.println("예외 메시지: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(401).build();
        }
    }
    
    /**
     * 사용자 프로필 조회
     */
    @GetMapping("/profile/{userId}")
    public ResponseEntity<UserProfileResponse> getUserProfile(@PathVariable Long userId) {
        try {
            UserProfileResponse response = authService.getUserProfile(userId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
} 