package com.the1tutor.the1tutor_server.service;

import com.the1tutor.the1tutor_server.dto.*;
import com.the1tutor.the1tutor_server.entity.*;
import com.the1tutor.the1tutor_server.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;

@Service
@RequiredArgsConstructor
@Transactional
public class AuthService {
    
    private final UserRepository userRepository;
    private final StudentRepository studentRepository;
    private final TutorRepository tutorRepository;
    private final TutorScheduleRepository tutorScheduleRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    
    public LoginResponse registerStudent(StudentRegisterRequest request) {
        // 이메일 중복 체크
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("이미 존재하는 이메일입니다.");
        }
        
        // User 생성
        User user = User.builder()
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .name(request.getName())
                .phone(request.getPhone())
                .birthdate(request.getBirthdate())
                .school(request.getSchool())
                .userType(User.UserType.STUDENT)
                .build();
        
        user = userRepository.save(user);
        
        // Student 생성
        Student student = Student.builder()
                .user(user)
                .grade(request.getGrade())
                .build();
        
        studentRepository.save(student);
        
        // JWT 토큰 생성
        String token = jwtService.generateToken(user.getEmail(), "STUDENT", user.getId());
        
        // 로그인 응답 생성
        return LoginResponse.builder()
                .userId(user.getId())
                .token(token)
                .userType("STUDENT")
                .message("학생 회원가입이 완료되었습니다.")
                .build();
    }
    
    public LoginResponse registerTutor(TutorRegisterRequest request) {
        // 이메일 중복 체크
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("이미 존재하는 이메일입니다.");
        }
        
        // User 생성
        User user = User.builder()
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .name(request.getName())
                .phone(request.getPhone())
                .birthdate(request.getBirthdate())
                .school(request.getSchool())
                .userType(User.UserType.TUTOR)
                .build();
        
        user = userRepository.save(user);
        
        // Tutor 생성 (기본 승인 상태: PENDING - 관리자 승인 필요)
        Tutor tutor = Tutor.builder()
                .user(user)
                .major(request.getMajor())
                .specializedSubjects(request.getSpecializedSubjects())
                .approvalStatus(Tutor.ApprovalStatus.PENDING)
                .build();
        
        tutor = tutorRepository.save(tutor);
        
        // 기본 시간표 생성
        TutorSchedule schedule = TutorSchedule.builder()
                .tutor(tutor)
                .availableSlots(Collections.emptySet())
                .fixedSlots(Collections.emptySet())
                .build();
        
        tutorScheduleRepository.save(schedule);
        
        // JWT 토큰 생성
        String token = jwtService.generateToken(user.getEmail(), "TUTOR", user.getId());
        
        // 로그인 응답 생성
        return LoginResponse.builder()
                .userId(user.getId())
                .token(token)
                .userType("TUTOR")
                .message("튜터 회원가입이 완료되었습니다.")
                .build();
    }
    
    public LoginResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));
        
        System.out.println("=== 로그인 디버깅 ===");
        System.out.println("사용자 이메일: " + user.getEmail());
        System.out.println("사용자 타입: " + user.getUserType());
        
        // 비밀번호 검증
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("비밀번호가 일치하지 않습니다.");
        }
        
        // JWT 토큰 생성
        String token = jwtService.generateToken(user.getEmail(), user.getUserType().name(), user.getId());
        
        // 기본 응답 생성
        LoginResponse.LoginResponseBuilder responseBuilder = LoginResponse.builder()
                .userId(user.getId())
                .token(token)
                .userType(user.getUserType().name())
                .message("로그인이 성공했습니다.");
        
        // 튜터인 경우 승인 상태 확인
        if (user.getUserType() == User.UserType.TUTOR) {
            System.out.println("튜터 로그인 - 승인 상태 조회 시작");
            
            Tutor tutor = tutorRepository.findByUser(user)
                    .orElseThrow(() -> new RuntimeException("튜터 정보를 찾을 수 없습니다."));
            
            System.out.println("튜터 ID: " + tutor.getId());
            System.out.println("튜터 승인 상태 (원본): " + tutor.getApprovalStatus());
            System.out.println("튜터 승인 상태 (문자열): " + tutor.getApprovalStatus().name());
            
            responseBuilder.approvalStatus(tutor.getApprovalStatus().name());
            
            System.out.println("ResponseBuilder에 설정된 승인 상태: " + tutor.getApprovalStatus().name());
        } else {
            System.out.println("학생 로그인 - 승인 상태 null로 설정");
            // 학생인 경우 승인 상태는 null 또는 빈 문자열
            responseBuilder.approvalStatus(null);
        }
        
        LoginResponse response = responseBuilder.build();
        System.out.println("최종 응답 승인 상태: " + response.getApprovalStatus());
        System.out.println("=== 로그인 디버깅 끝 ===");
        
        return response;
    }
    
    public UserProfileResponse getUserProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));
        
        UserProfileResponse.UserProfileResponseBuilder builder = UserProfileResponse.builder()
                .userId(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .school(user.getSchool())
                .userType(user.getUserType().name())
                .createdAt(user.getCreatedAt());
        
        if (user.getUserType() == User.UserType.STUDENT) {
            Student student = studentRepository.findByUser(user)
                    .orElseThrow(() -> new RuntimeException("학생 정보를 찾을 수 없습니다."));
            builder.grade(student.getGrade());
        } else if (user.getUserType() == User.UserType.TUTOR) {
            Tutor tutor = tutorRepository.findByUser(user)
                    .orElseThrow(() -> new RuntimeException("튜터 정보를 찾을 수 없습니다."));
            builder.major(tutor.getMajor())
                   .specializedSubjects(tutor.getSpecializedSubjects());
        }
        
        return builder.build();
    }
} 