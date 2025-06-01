package com.the1tutor.the1tutor_server.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "tutoring_sessions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TutoringSession {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tutor_id", nullable = false)
    private Tutor tutor;
    
    @OneToOne
    @JoinColumn(name = "match_request_id")
    private MatchRequest matchRequest; // 원본 매칭 요청
    
    @Column(nullable = false)
    private String subject; // "Mathematics HL" 등
    
    @Column(nullable = false)
    private LocalDateTime scheduledTime; // 다음 수업 시간
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private SessionStatus status = SessionStatus.SCHEDULED;
    
    @Column(length = 2000)
    private String sessionNotes; // 수업 노트
    
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    private LocalDateTime updatedAt;
    
    public enum SessionStatus {
        SCHEDULED, COMPLETED, CANCELLED
    }
} 