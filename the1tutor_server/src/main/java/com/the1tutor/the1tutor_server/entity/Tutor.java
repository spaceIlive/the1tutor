package com.the1tutor.the1tutor_server.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.util.List;

@Entity
@Table(name = "tutors")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Tutor {
    
    @Id
    private Long id;
    
    @OneToOne(cascade = CascadeType.ALL)
    @MapsId
    @JoinColumn(name = "user_id")
    private User user;
    
    @Column(nullable = false)
    private String major; // 전공
    
    @ElementCollection
    @CollectionTable(name = "tutor_subjects", joinColumns = @JoinColumn(name = "tutor_id"))
    @Column(name = "subject")
    private List<String> specializedSubjects; // 전문 과목들
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private ApprovalStatus approvalStatus = ApprovalStatus.PENDING;
    
    public enum ApprovalStatus {
        PENDING, APPROVED, REJECTED
    }
} 