package app.HackBackend.repository;

import app.HackBackend.entity.ScholarshipDocument;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ScholarshipDocumentRepository extends JpaRepository<ScholarshipDocument, Long> {
    List<ScholarshipDocument> findByStudentId(Long studentId);
}
