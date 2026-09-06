package app.HackBackend.controller;

import app.HackBackend.entity.Scholarship;
import app.HackBackend.entity.ScholarshipApplication;
import app.HackBackend.repository.ScholarshipApplicationRepository;
import app.HackBackend.repository.ScholarshipRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/scholarships")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class ScholarshipController {

    @Autowired
    private ScholarshipRepository scholarshipRepository;

    @Autowired
    private ScholarshipApplicationRepository applicationRepository;

    @GetMapping("/available")
    public ResponseEntity<List<Scholarship>> getAvailableScholarships() {
        try {
            List<Scholarship> dbList = scholarshipRepository.findAll();
            if (!dbList.isEmpty()) {
                return ResponseEntity.ok(dbList);
            }
        } catch (Exception e) {
            System.err.println("Database fetch exception: " + e.getMessage());
        }

        List<Scholarship> list = new ArrayList<>();

        // 1. IN_APP Scholarship
        list.add(Scholarship.builder()
                .id(1L)
                .title("MSBTE Diploma & Degree Merit Scholarship")
                .provider("Maharashtra State Board of Technical Education")
                .amount("₹25,000")
                .category("MSBTE Govt")
                .criteria("Marks > 80% • Diploma / Degree Engg")
                .deadline("30 Sep 2026")
                .availableSeats("500 Seats")
                .description("Official State Technical Board scholarship for engineering & tech students. Direct in-app application form.")
                .applicationMode("IN_APP")
                .status("ACTIVE")
                .build());

        // 2. IN_APP Scholarship
        list.add(Scholarship.builder()
                .id(2L)
                .title("National Campus Innovation & Tech Fellowship")
                .provider("Ministry of Education & Innovation Council")
                .amount("₹50,000")
                .category("Merit Grant")
                .criteria("CGPA > 8.0 • Innovation / Tech Project")
                .deadline("28 Oct 2026")
                .availableSeats("200 Seats")
                .description("Direct in-app merit award for student tech innovators & builders.")
                .applicationMode("IN_APP")
                .status("ACTIVE")
                .build());

        // 3. EXTERNAL_WEBSITE Scholarship (MahaDBT)
        list.add(Scholarship.builder()
                .id(3L)
                .title("Rajarshi Chhatrapati Shahu Maharaj Fee Concession (EBC)")
                .provider("Directorate of Higher Education (MahaDBT)")
                .amount("₹19,000")
                .category("MahaDBT Govt")
                .criteria("Income < ₹8 Lakhs • General / EWS / OBC")
                .deadline("15 Oct 2026")
                .availableSeats("1,200 Seats")
                .description("50% Tuition fee concession for Economically Backward Class students via MahaDBT portal.")
                .applicationMode("EXTERNAL_WEBSITE")
                .externalWebsiteName("MahaDBT Official State Portal")
                .externalWebsiteUrl("https://mahadbt.maharashtra.gov.in")
                .externalWebsiteStatus("Portal Active & Accepting Applications")
                .status("ACTIVE")
                .build());

        // 4. EXTERNAL_WEBSITE Scholarship (NSP)
        list.add(Scholarship.builder()
                .id(4L)
                .title("National Scholarship Portal (NSP) Post-Matric Scheme")
                .provider("Ministry of Minority Affairs / Govt of India")
                .amount("₹30,000")
                .category("Central Govt")
                .criteria("Central Merit List • Minorities / General")
                .deadline("20 Oct 2026")
                .availableSeats("5,000 Seats")
                .description("Central government portal scholarship for higher education students across India.")
                .applicationMode("EXTERNAL_WEBSITE")
                .externalWebsiteName("National Scholarship Portal (NSP)")
                .externalWebsiteUrl("https://scholarships.gov.in")
                .externalWebsiteStatus("Active - Phase 1 Verification Live")
                .status("ACTIVE")
                .build());

        // 5. EXTERNAL_WEBSITE Scholarship (AICTE)
        list.add(Scholarship.builder()
                .id(5L)
                .title("AICTE Pragati & Saksham Technical Scholarship")
                .provider("All India Council for Technical Education (AICTE)")
                .amount("₹50,000 / Year")
                .category("AICTE Govt")
                .criteria("Female Degree / Diploma Tech Students")
                .deadline("05 Nov 2026")
                .availableSeats("1,000 Seats")
                .description("National council scholarship supporting female & specially-abled engineering candidates.")
                .applicationMode("EXTERNAL_WEBSITE")
                .externalWebsiteName("AICTE Portal")
                .externalWebsiteUrl("https://www.aicte-india.org/schemes/students-development-schemes")
                .externalWebsiteStatus("Active - Open for 2026-27 Batch")
                .status("ACTIVE")
                .build());

        // 6. EXTERNAL_WEBSITE Scholarship (Foundation)
        list.add(Scholarship.builder()
                .id(6L)
                .title("Tata Trust & Foundation Higher Education Grant")
                .provider("Tata Education Trust & Philanthropy Foundation")
                .amount("₹40,000")
                .category("Foundation Trust")
                .criteria("Undergraduate / Postgraduate STEM Students")
                .deadline("12 Nov 2026")
                .availableSeats("300 Seats")
                .description("Private endowment foundation scholarship for promising STEM scholars.")
                .applicationMode("EXTERNAL_WEBSITE")
                .externalWebsiteName("Tata Trusts Official Education Portal")
                .externalWebsiteUrl("https://www.tatatrusts.org/our-work/individual-grants-programme/education-grants")
                .externalWebsiteStatus("Portal Open")
                .status("ACTIVE")
                .build());

        try {
            return ResponseEntity.ok(scholarshipRepository.saveAll(list));
        } catch (Exception ex) {
            return ResponseEntity.ok(list);
        }
    }

    @GetMapping("/applications")
    public ResponseEntity<List<ScholarshipApplication>> getAllApplications() {
        return ResponseEntity.ok(applicationRepository.findAll());
    }

    @GetMapping("/applications/student/{studentId}")
    public ResponseEntity<List<ScholarshipApplication>> getStudentApplications(@PathVariable Long studentId) {
        return ResponseEntity.ok(applicationRepository.findByStudentId(studentId));
    }

    @PostMapping("/applications/apply")
    public ResponseEntity<ScholarshipApplication> applyScholarship(@RequestBody ScholarshipApplication app) {
        if (app.getAppliedDate() == null) {
            app.setAppliedDate(LocalDateTime.now());
        }
        if (app.getApplicationStatus() == null) {
            app.setApplicationStatus("Submitted");
        }
        if (app.getApplicationMode() == null) {
            app.setApplicationMode("IN_APP");
        }
        ScholarshipApplication saved = applicationRepository.save(app);
        return ResponseEntity.ok(saved);
    }

    @PostMapping("/applications/draft")
    public ResponseEntity<ScholarshipApplication> saveDraft(@RequestBody ScholarshipApplication app) {
        app.setApplicationStatus("Draft");
        if (app.getAppliedDate() == null) {
            app.setAppliedDate(LocalDateTime.now());
        }
        if (app.getApplicationMode() == null) {
            app.setApplicationMode("IN_APP");
        }
        ScholarshipApplication saved = applicationRepository.save(app);
        return ResponseEntity.ok(saved);
    }

    @PutMapping("/applications/{id}")
    public ResponseEntity<?> updateApplication(@PathVariable Long id, @RequestBody ScholarshipApplication updateData) {
        return applicationRepository.findById(id).map(existing -> {
            // Check if editable (Draft or In Progress)
            String status = existing.getApplicationStatus();
            if ("Submitted".equalsIgnoreCase(status) || "Under Verification".equalsIgnoreCase(status)
                    || "Approved".equalsIgnoreCase(status) || "Fund Released".equalsIgnoreCase(status)) {
                return ResponseEntity.badRequest().body(Map.of("message", "Application is already " + status + " and cannot be edited."));
            }

            if (updateData.getFormDataJson() != null) existing.setFormDataJson(updateData.getFormDataJson());
            if (updateData.getUploadedDocsJson() != null) existing.setUploadedDocsJson(updateData.getUploadedDocsJson());
            if (updateData.getApplicationStatus() != null) existing.setApplicationStatus(updateData.getApplicationStatus());
            if (updateData.getRemarks() != null) existing.setRemarks(updateData.getRemarks());

            ScholarshipApplication saved = applicationRepository.save(existing);
            return ResponseEntity.ok(saved);
        }).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/applications/external-visit")
    public ResponseEntity<?> logExternalVisit(@RequestBody Map<String, Object> body) {
        Long studentId = Long.valueOf(body.getOrDefault("studentId", 1).toString());
        Long scholarshipId = Long.valueOf(body.getOrDefault("scholarshipId", 0).toString());
        String websiteName = (String) body.getOrDefault("externalWebsiteName", "Official Portal");
        String websiteUrl = (String) body.getOrDefault("externalWebsiteUrl", "https://mahadbt.maharashtra.gov.in");

        List<ScholarshipApplication> existingList = applicationRepository.findByStudentIdAndScholarshipId(studentId, scholarshipId);
        ScholarshipApplication app;
        if (!existingList.isEmpty()) {
            app = existingList.get(0);
        } else {
            app = ScholarshipApplication.builder()
                    .studentId(studentId)
                    .scholarshipId(scholarshipId)
                    .applicationStatus("External Portal Opened")
                    .applicationMode("EXTERNAL_WEBSITE")
                    .externalWebsiteName(websiteName)
                    .externalWebsiteUrl(websiteUrl)
                    .externalWebsiteStatus("Portal Visited & Applications Handled Externally")
                    .build();
        }
        app.setLastOpenedDate(LocalDateTime.now());
        ScholarshipApplication saved = applicationRepository.save(app);
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/summary")
    public ResponseEntity<Map<String, Object>> getScholarshipSummary() {
        long totalApplied = applicationRepository.count();
        long approvedCount = applicationRepository.findByApplicationStatus("Approved").size()
                + applicationRepository.findByApplicationStatus("Fund Released").size();
        long pendingCount = applicationRepository.findByApplicationStatus("Submitted").size()
                + applicationRepository.findByApplicationStatus("Under Review").size()
                + applicationRepository.findByApplicationStatus("Document Verification").size();
        long rejectedCount = applicationRepository.findByApplicationStatus("Rejected").size();

        return ResponseEntity.ok(Map.of(
                "totalApplied", totalApplied > 0 ? totalApplied : 2,
                "totalApproved", approvedCount > 0 ? approvedCount : 1,
                "totalPending", pendingCount > 0 ? pendingCount : 1,
                "totalRejected", rejectedCount,
                "totalAmountReceived", 25000,
                "linkedBankAccount", "HDFC Bank •••• 4892"
        ));
    }
}
