package app.HackBackend.repository;

import app.HackBackend.entity.SavingsReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SavingsReportRepository extends JpaRepository<SavingsReport, Long> {
    List<SavingsReport> findByStudentId(Long studentId);
}
