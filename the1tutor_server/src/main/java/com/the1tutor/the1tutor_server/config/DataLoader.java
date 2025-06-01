package com.the1tutor.the1tutor_server.config;

import com.the1tutor.the1tutor_server.entity.*;
import com.the1tutor.the1tutor_server.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.HashSet;

@Component
@RequiredArgsConstructor
public class DataLoader implements CommandLineRunner {
    
    private final StudentRepository studentRepository;
    private final TutorRepository tutorRepository;
    private final TutorScheduleRepository tutorScheduleRepository;
    private final PasswordEncoder passwordEncoder;
    
    @Override
    @Transactional
    public void run(String... args) throws Exception {
        // 테스트 학생 생성 (User는 cascade로 함께 저장)
        User studentUser = User.builder()
                .email("student@test.com")
                .password(passwordEncoder.encode("password123"))
                .name("김학생")
                .phone("010-1234-5678")
                .birthdate(LocalDate.of(2005, 3, 15))
                .school("국제학교")
                .userType(User.UserType.STUDENT)
                .build();
        
        Student student = Student.builder()
                .user(studentUser)  // cascade로 User도 함께 저장됨
                .grade("Year 11")
                .build();
        
        student = studentRepository.save(student);
        
        // 테스트 튜터 생성 (User는 cascade로 함께 저장)
        User tutorUser = User.builder()
                .email("tutor@test.com")
                .password(passwordEncoder.encode("password123"))
                .name("박튜터")
                .phone("010-9876-5432")
                .birthdate(LocalDate.of(1995, 8, 20))
                .school("서울대학교")
                .userType(User.UserType.TUTOR)
                .build();
        
        Tutor tutor = Tutor.builder()
                .user(tutorUser)  // cascade로 User도 함께 저장됨
                .major("수학교육")
                .specializedSubjects(Arrays.asList("Mathematics HL", "Mathematics SL", "Physics HL"))
                .approvalStatus(Tutor.ApprovalStatus.APPROVED)
                .build();
        
        tutor = tutorRepository.save(tutor);
        
        // 튜터 시간표 생성 (Tutor는 이미 저장된 상태)
        TutorSchedule schedule = TutorSchedule.builder()
                .tutor(tutor)  // 이미 저장된 tutor 사용
                .availableSlots(new HashSet<>(Arrays.asList(
                        "월-14:00", "월-15:00", "화-14:00", "화-15:00",
                        "수-14:00", "수-15:00", "목-14:00", "목-15:00",
                        "금-14:00", "금-15:00"
                )))
                .fixedSlots(new HashSet<>())
                .build();
        
        tutorScheduleRepository.save(schedule);
        
        System.out.println("테스트 데이터가 로드되었습니다.");
        System.out.println("학생 로그인: student@test.com / password123");
        System.out.println("튜터 로그인: tutor@test.com / password123");
    }
} 