package app.HackBackend.repository;

import app.HackBackend.entity.Conversation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ConversationRepository extends JpaRepository<Conversation, Long> {

    @Query("SELECT c FROM Conversation c WHERE LOWER(c.customerEmail) = LOWER(:customerEmail) AND LOWER(c.resellerEmail) = LOWER(:resellerEmail)")
    Optional<Conversation> findByCustomerEmailAndResellerEmail(
            @Param("customerEmail") String customerEmail,
            @Param("resellerEmail") String resellerEmail
    );

    @Query("SELECT c FROM Conversation c WHERE LOWER(c.customerEmail) = LOWER(:userEmail) OR LOWER(c.resellerEmail) = LOWER(:userEmail) ORDER BY c.updatedAt DESC")
    List<Conversation> findAllByUserEmailOrderByUpdatedAtDesc(@Param("userEmail") String userEmail);
}
