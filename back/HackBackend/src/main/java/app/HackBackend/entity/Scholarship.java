package app.HackBackend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "scholarships")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Scholarship {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "scholarship_name")
    private String scholarshipName;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private String provider;

    @Column(nullable = false)
    private String amount;

    @Column(nullable = false)
    private String category;

    private String criteria;

    private String eligibility;

    private String deadline;

    @Column(name = "available_seats")
    private String availableSeats;

    @Column(length = 1000)
    private String description;

    @Column(name = "application_mode")
    private String applicationMode; // IN_APP, EXTERNAL_WEBSITE

    @Column(name = "external_website_url", length = 1000)
    private String externalWebsiteUrl;

    @Column(name = "external_website_name")
    private String externalWebsiteName;

    @Column(name = "external_website_status")
    private String externalWebsiteStatus;

    @Column(name = "status")
    private String status; // ACTIVE, INACTIVE

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        if (this.scholarshipName == null) {
            this.scholarshipName = this.title;
        }
        if (this.title == null) {
            this.title = this.scholarshipName;
        }
        if (this.eligibility == null) {
            this.eligibility = this.criteria;
        }
        if (this.criteria == null) {
            this.criteria = this.eligibility;
        }
        if (this.status == null) {
            this.status = "ACTIVE";
        }
        if (this.applicationMode == null) {
            this.applicationMode = "IN_APP";
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
