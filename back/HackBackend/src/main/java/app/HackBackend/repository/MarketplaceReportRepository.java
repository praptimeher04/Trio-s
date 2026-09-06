package app.HackBackend.repository;

import app.HackBackend.entity.MarketplaceReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MarketplaceReportRepository extends JpaRepository<MarketplaceReport, Long> {
    List<MarketplaceReport> findByItemId(Long itemId);
    List<MarketplaceReport> findByStatus(String status);
}
