package app.HackBackend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "fee_records")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FeeRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "student_id", nullable = false)
    private Long studentId;

    @Column(name = "total_fee", nullable = false)
    private Double totalFee;

    @Column(name = "scholarship_amount")
    private Double scholarshipAmount;

    @Column(name = "paid_amount", nullable = false)
    private Double paidAmount;

    @Column(name = "pending_amount", nullable = false)
    private Double pendingAmount;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    protected void onSave() {
        this.updatedAt = LocalDateTime.now();
        if (this.scholarshipAmount == null) this.scholarshipAmount = 0.0;
        if (this.paidAmount == null) this.paidAmount = 0.0;
        if (this.totalFee == null) this.totalFee = 0.0;
        this.pendingAmount = Math.max(0.0, this.totalFee - this.paidAmount - this.scholarshipAmount);
    }
}
