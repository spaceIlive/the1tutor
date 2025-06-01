package com.the1tutor.the1tutor_server.repository;

import com.the1tutor.the1tutor_server.entity.TutoringSession;
import com.the1tutor.the1tutor_server.entity.Student;
import com.the1tutor.the1tutor_server.entity.Tutor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TutoringSessionRepository extends JpaRepository<TutoringSession, Long> {
    
    List<TutoringSession> findByStudent(Student student);
    
    List<TutoringSession> findByTutor(Tutor tutor);
    
    List<TutoringSession> findByStudentAndStatus(Student student, TutoringSession.SessionStatus status);
    
    List<TutoringSession> findByTutorAndStatus(Tutor tutor, TutoringSession.SessionStatus status);
    
    @Query("SELECT ts FROM TutoringSession ts WHERE ts.tutor.id = :tutorId")
    List<TutoringSession> findByTutorId(@Param("tutorId") Long tutorId);
    
    @Query("SELECT ts FROM TutoringSession ts WHERE ts.student.id = :studentId")
    List<TutoringSession> findByStudentId(@Param("studentId") Long studentId);
} 