package app.HackBackend.repository;

import app.HackBackend.entity.ScholarshipApplication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ScholarshipApplicationRepository extends JpaRepository<ScholarshipApplication, Long> {
    List<ScholarshipApplication> findByStudentId(Long studentId);
    List<ScholarshipApplication> findByScholarshipId(Long scholarshipId);
    List<ScholarshipApplication> findByApplicationStatus(String applicationStatus);
    List<ScholarshipApplication> findByStudentIdAndScholarshipId(Long studentId, Long scholarshipId);
}
