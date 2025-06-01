package com.the1tutor.the1tutor_server.repository;

import com.the1tutor.the1tutor_server.entity.MatchRequest;
import com.the1tutor.the1tutor_server.entity.Student;
import com.the1tutor.the1tutor_server.entity.Tutor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MatchRequestRepository extends JpaRepository<MatchRequest, Long> {
    
    List<MatchRequest> findByStudentAndStatus(Student student, MatchRequest.RequestStatus status);
    
    List<MatchRequest> findByTutorAndStatus(Tutor tutor, MatchRequest.RequestStatus status);
    
    List<MatchRequest> findByStudent(Student student);
} 