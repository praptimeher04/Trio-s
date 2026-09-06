package app.HackBackend.controller;

import app.HackBackend.entity.Scholarship;
import app.HackBackend.repository.ScholarshipRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/scholarships")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class ScholarshipController {

    @Autowired
    private ScholarshipRepository scholarshipRepository;

    @GetMapping("/available")
    public ResponseEntity<List<Scholarship>> getAvailableScholarships() {
        List<Scholarship> dbList = scholarshipRepository.findAll();
        if (dbList.isEmpty()) {
            // Seed initial default scholarships
            List<Scholarship> list = new ArrayList<>();
            list.add(Scholarship.builder()
                    .title("National Merit Fellowship 2026")
                    .provider("Ministry of Higher Education")
                    .amount("₹50,000")
                    .category("Merit Based")
                    .criteria("GPA > 8.5 • All Departments")
                    .deadline("30 Sep 2026")
                    .description("Full financial support for high-performing undergraduate & postgraduate campus students.")
                    .build());

            list.add(Scholarship.builder()
                    .title("Women in Tech Leadership Award")
                    .provider("Ada Lovelace Tech Foundation")
                    .amount("₹35,000")
                    .category("Diversity Grant")
                    .criteria("Female Engineering & Science Students")
                    .deadline("15 Oct 2026")
                    .description("Empowering future women leaders in Computer Science, AI, and Engineering disciplines.")
                    .build());

            list.add(Scholarship.builder()
                    .title("Merit-cum-Means Financial Aid")
                    .provider("Campus Alumni Endowment Fund")
                    .amount("₹20,000")
                    .category("Financial Aid")
                    .criteria("Annual Family Income < ₹4.5 Lakhs")
                    .deadline("25 Sep 2026")
                    .description("Need-based tuition assistance sponsored by distinguished campus alumni.")
                    .build());

            return ResponseEntity.ok(scholarshipRepository.saveAll(list));
        }
        return ResponseEntity.ok(dbList);
    }

    @PostMapping("/create")
    public ResponseEntity<Scholarship> createScholarship(@RequestBody Scholarship scholarship) {
        if (scholarship.getProvider() == null) {
            scholarship.setProvider("Campus Administration");
        }
        if (scholarship.getCategory() == null) {
            scholarship.setCategory("Merit Based");
        }
        Scholarship saved = scholarshipRepository.save(scholarship);
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/summary")
    public ResponseEntity<Map<String, Object>> getScholarshipSummary() {
        long totalCount = scholarshipRepository.count();
        return ResponseEntity.ok(Map.of(
                "totalGrantedAmount", 105000,
                "availableGrants", totalCount > 0 ? totalCount : 4,
                "appliedScholarships", 2,
                "approvedGrants", 1,
                "pendingReview", 1,
                "linkedBankAccount", "HDFC Bank •••• 4892"
        ));
    }
}
