package com.the1tutor.the1tutor_server.repository;

import com.the1tutor.the1tutor_server.entity.Student;
import com.the1tutor.the1tutor_server.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface StudentRepository extends JpaRepository<Student, Long> {
    Optional<Student> findByUser(User user);
} 