package app.HackBackend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "scholarship_applications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScholarshipApplication {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "student_id", nullable = false)
    private Long studentId;

    @Column(name = "scholarship_id", nullable = false)
    private Long scholarshipId;

    @Column(name = "application_status", nullable = false)
    private String applicationStatus; // Draft, Submitted, Document Verification, Under Review, Approved, Rejected, Fund Released

    @Column(name = "applied_date")
    private LocalDateTime appliedDate;

    @Column(name = "verification_date")
    private LocalDateTime verificationDate;

    @Column(name = "review_date")
    private LocalDateTime reviewDate;

    @Column(name = "approval_date")
    private LocalDateTime approvalDate;

    @Column(name = "fund_release_date")
    private LocalDateTime fundReleaseDate;

    @Column(name = "application_mode")
    private String applicationMode; // IN_APP, EXTERNAL_WEBSITE

    @Column(name = "form_data_json", length = 4000)
    private String formDataJson;

    @Column(name = "uploaded_docs_json", length = 2000)
    private String uploadedDocsJson;

    @Column(name = "external_website_name")
    private String externalWebsiteName;

    @Column(name = "external_website_url", length = 1000)
    private String externalWebsiteUrl;

    @Column(name = "external_website_status")
    private String externalWebsiteStatus;

    @Column(name = "last_opened_date")
    private LocalDateTime lastOpenedDate;

    @Column(length = 500)
    private String remarks;

    @PrePersist
    protected void onCreate() {
        if (this.appliedDate == null) {
            this.appliedDate = LocalDateTime.now();
        }
        if (this.applicationStatus == null) {
            this.applicationStatus = "Submitted";
        }
    }
}
