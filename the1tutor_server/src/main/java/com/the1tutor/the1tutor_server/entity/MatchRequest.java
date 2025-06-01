package com.the1tutor.the1tutor_server.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "match_requests")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MatchRequest {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tutor_id")
    private Tutor tutor; // 매칭 알고리즘에 의해 할당
    
    @Column(nullable = false)
    private String subject; // "Mathematics HL" 등
    
    @Column(nullable = false, length = 1000)
    private String learningGoal; // 수업받고싶은 부분
    
    @Column(nullable = false)
    private String tutorStyle; // 친근함/체계적/창의적
    
    @Column(nullable = false)
    private String classMethod; // 줌 온라인 (고정)
    
    @ElementCollection
    @CollectionTable(name = "match_request_time_slots", joinColumns = @JoinColumn(name = "request_id"))
    @Column(name = "time_slot")
    private List<String> selectedTimeSlots; // "월-14:00" 형태
    
    @Column(nullable = false, length = 1000)
    private String motivation; // 신청동기
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private RequestStatus status = RequestStatus.PENDING;
    
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    private LocalDateTime updatedAt;
    
    public enum RequestStatus {
        PENDING, ACCEPTED, REJECTED
    }
} 