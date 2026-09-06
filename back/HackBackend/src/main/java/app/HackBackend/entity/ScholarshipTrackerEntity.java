package app.HackBackend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "scholarship_tracker")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScholarshipTrackerEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "application_id", nullable = false)
    private Long applicationId;

    @Column(name = "current_stage", nullable = false)
    private String currentStage; // Profile Completed, Documents Uploaded, Application Submitted, Document Verification, Under Review, Approved, Rejected, Fund Released

    @Column(name = "progress_percentage")
    private Integer progressPercentage;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    protected void onSave() {
        this.updatedAt = LocalDateTime.now();
        if (this.progressPercentage == null) {
            this.progressPercentage = calculateProgress(this.currentStage);
        }
    }

    public static int calculateProgress(String stage) {
        if (stage == null) return 0;
        switch (stage) {
            case "Profile Completed": return 15;
            case "Documents Uploaded": return 30;
            case "Application Submitted": return 45;
            case "Document Verification":
            case "Verification": return 60;
            case "Under Review": return 75;
            case "Approved": return 90;
            case "Fund Released": return 100;
            case "Rejected": return 0;
            default: return 45;
        }
    }
}
