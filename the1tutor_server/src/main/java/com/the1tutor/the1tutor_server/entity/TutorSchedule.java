package com.the1tutor.the1tutor_server.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.util.Set;

@Entity
@Table(name = "tutor_schedules")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TutorSchedule {
    
    @Id
    private Long id;
    
    @OneToOne(cascade = CascadeType.ALL)
    @MapsId
    @JoinColumn(name = "tutor_id")
    private Tutor tutor;
    
    @ElementCollection
    @CollectionTable(name = "tutor_available_slots", joinColumns = @JoinColumn(name = "schedule_id"))
    @Column(name = "time_slot")
    private Set<String> availableSlots; // "월-14:00" 형태
    
    @ElementCollection
    @CollectionTable(name = "tutor_fixed_slots", joinColumns = @JoinColumn(name = "schedule_id"))
    @Column(name = "time_slot")
    private Set<String> fixedSlots; // 매칭된 시간 (수정 불가)
} 