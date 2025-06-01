package com.the1tutor.the1tutor_server.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

@Entity
@Table(name = "students")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Student {
    
    @Id
    @Column(name = "user_id")
    private Long id;
    
    @OneToOne(cascade = CascadeType.ALL)
    @MapsId
    @JoinColumn(name = "user_id")
    private User user;
    
    @Column(nullable = false)
    private String grade; // Year 7-12 (MYP 2 ~ DP 2)
} 