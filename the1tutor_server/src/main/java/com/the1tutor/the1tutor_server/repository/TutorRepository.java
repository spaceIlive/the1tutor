package com.the1tutor.the1tutor_server.repository;

import com.the1tutor.the1tutor_server.entity.Tutor;
import com.the1tutor.the1tutor_server.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TutorRepository extends JpaRepository<Tutor, Long> {
    
    Optional<Tutor> findByUser(User user);
    
    @Query("SELECT t FROM Tutor t WHERE t.approvalStatus = 'APPROVED' AND :subject MEMBER OF t.specializedSubjects")
    List<Tutor> findBySpecializedSubjectsContaining(@Param("subject") String subject);
    
    @Query("SELECT t FROM Tutor t WHERE t.approvalStatus = 'APPROVED' AND :subject MEMBER OF t.specializedSubjects")
    List<Tutor> findApprovedTutorsBySubject(@Param("subject") String subject);
    
    List<Tutor> findByApprovalStatus(Tutor.ApprovalStatus status);
} 