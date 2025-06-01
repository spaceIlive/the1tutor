package com.the1tutor.the1tutor_server.repository;

import com.the1tutor.the1tutor_server.entity.TutorSchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TutorScheduleRepository extends JpaRepository<TutorSchedule, Long> {
} 