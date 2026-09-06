package app.HackBackend.controller;

import app.HackBackend.dto.ChatDTO.*;
import app.HackBackend.entity.ChatMessage;
import app.HackBackend.entity.Conversation;
import app.HackBackend.entity.ConversationParticipant;
import app.HackBackend.repository.ChatMessageRepository;
import app.HackBackend.repository.ConversationParticipantRepository;
import app.HackBackend.repository.ConversationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/chat")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class ChatController {

    @Autowired
    private ConversationRepository conversationRepository;

    @Autowired
    private ConversationParticipantRepository participantRepository;

    @Autowired
    private ChatMessageRepository messageRepository;

    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("h:mm a");

    @PostMapping("/get-or-create")
    public ResponseEntity<ConversationResponse> getOrCreateConversation(@RequestBody StartConversationRequest request) {
        if (request.getCustomerEmail() == null || request.getResellerEmail() == null) {
            return ResponseEntity.badRequest().build();
        }

        String customerEmail = request.getCustomerEmail().trim().toLowerCase();
        String resellerEmail = request.getResellerEmail().trim().toLowerCase();
        String customerName = request.getCustomerName() != null && !request.getCustomerName().trim().isEmpty()
                ? request.getCustomerName().trim() : "Customer";
        String resellerName = request.getResellerName() != null && !request.getResellerName().trim().isEmpty()
                ? request.getResellerName().trim() : "Reseller";

        Optional<Conversation> existing = conversationRepository.findByCustomerEmailAndResellerEmail(customerEmail, resellerEmail);

        Conversation conversation;
        if (existing.isPresent()) {
            conversation = existing.get();
            if (request.getProductTitle() != null && !request.getProductTitle().trim().isEmpty()) {
                conversation.setProductTitle(request.getProductTitle().trim());
                conversation = conversationRepository.save(conversation);
            }
        } else {
            conversation = Conversation.builder()
                    .customerEmail(customerEmail)
                    .customerName(customerName)
                    .resellerEmail(resellerEmail)
                    .resellerName(resellerName)
                    .productTitle(request.getProductTitle() != null ? request.getProductTitle().trim() : "Campus Item")
                    .build();
            conversation = conversationRepository.save(conversation);

            // Add participants
            ConversationParticipant p1 = ConversationParticipant.builder()
                    .conversationId(conversation.getId())
                    .userEmail(customerEmail)
                    .userName(customerName)
                    .userType(0)
                    .build();

            ConversationParticipant p2 = ConversationParticipant.builder()
                    .conversationId(conversation.getId())
                    .userEmail(resellerEmail)
                    .userName(resellerName)
                    .userType(1)
                    .build();

            participantRepository.save(p1);
            participantRepository.save(p2);
        }

        return ResponseEntity.ok(buildConversationResponse(conversation, customerEmail));
    }

    @GetMapping("/conversations/{userEmail}")
    public ResponseEntity<List<ConversationResponse>> getUserConversations(@PathVariable String userEmail) {
        String cleanEmail = userEmail.trim().toLowerCase();
        List<Conversation> conversations = conversationRepository.findAllByUserEmailOrderByUpdatedAtDesc(cleanEmail);

        List<ConversationResponse> responseList = new ArrayList<>();
        for (Conversation c : conversations) {
            responseList.add(buildConversationResponse(c, cleanEmail));
        }

        return ResponseEntity.ok(responseList);
    }

    @GetMapping("/messages/{conversationId}")
    public ResponseEntity<List<MessageResponse>> getConversationMessages(@PathVariable Long conversationId) {
        List<ChatMessage> messages = messageRepository.findByConversationIdOrderByCreatedAtAsc(conversationId);
        List<MessageResponse> list = new ArrayList<>();
        for (ChatMessage m : messages) {
            list.add(buildMessageResponse(m));
        }
        return ResponseEntity.ok(list);
    }

    @PostMapping("/send")
    public ResponseEntity<List<MessageResponse>> sendMessage(@RequestBody SendMessageRequest request) {
        if (request.getConversationId() == null || request.getMessageText() == null || request.getMessageText().trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        Optional<Conversation> convOpt = conversationRepository.findById(request.getConversationId());
        if (convOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Conversation conv = convOpt.get();

        String senderEmail = request.getSenderEmail() != null ? request.getSenderEmail().trim().toLowerCase() : "";
        String receiverEmail = request.getReceiverEmail() != null ? request.getReceiverEmail().trim().toLowerCase() : "";

        if (receiverEmail.isEmpty()) {
            receiverEmail = senderEmail.equalsIgnoreCase(conv.getCustomerEmail())
                    ? conv.getResellerEmail() : conv.getCustomerEmail();
        }

        ChatMessage msg = ChatMessage.builder()
                .conversationId(conv.getId())
                .senderEmail(senderEmail)
                .senderName(request.getSenderName() != null ? request.getSenderName().trim() : "User")
                .receiverEmail(receiverEmail)
                .messageText(request.getMessageText().trim())
                .imagePath(request.getImagePath())
                .messageType(request.getMessageType() != null ? request.getMessageType() : "text")
                .isRead(false)
                .build();

        messageRepository.save(msg);

        // Update conversation timestamp
        conv.setUpdatedAt(LocalDateTime.now());
        conversationRepository.save(conv);

        // Return ALL messages of the conversation in 1 single API call response
        List<ChatMessage> allMessages = messageRepository.findByConversationIdOrderByCreatedAtAsc(conv.getId());
        List<MessageResponse> responseList = new ArrayList<>();
        for (ChatMessage m : allMessages) {
            responseList.add(buildMessageResponse(m));
        }

        return ResponseEntity.ok(responseList);
    }

    @PostMapping("/mark-read/{conversationId}")
    public ResponseEntity<Void> markRead(@PathVariable Long conversationId, @RequestParam String userEmail) {
        String cleanEmail = userEmail.trim().toLowerCase();
        List<ChatMessage> unread = messageRepository.findByConversationIdOrderByCreatedAtAsc(conversationId);
        for (ChatMessage m : unread) {
            if (m.getReceiverEmail() != null && m.getReceiverEmail().equalsIgnoreCase(cleanEmail) && !Boolean.TRUE.equals(m.getIsRead())) {
                m.setIsRead(true);
                messageRepository.save(m);
            }
        }
        return ResponseEntity.ok().build();
    }

    private ConversationResponse buildConversationResponse(Conversation conv, String currentUserEmail) {
        boolean isCustomer = currentUserEmail.equalsIgnoreCase(conv.getCustomerEmail());
        String peerEmail = isCustomer ? conv.getResellerEmail() : conv.getCustomerEmail();
        String peerName = isCustomer ? conv.getResellerName() : conv.getCustomerName();
        String peerAvatar = (peerName != null && !peerName.isEmpty()) ? peerName.substring(0, 1).toUpperCase() : "P";

        Optional<ChatMessage> lastMsgOpt = messageRepository.findFirstByConversationIdOrderByCreatedAtDesc(conv.getId());
        String lastMsg = lastMsgOpt.isPresent() ? lastMsgOpt.get().getMessageText() : "Started conversation";
        String lastMsgTime = lastMsgOpt.isPresent() && lastMsgOpt.get().getCreatedAt() != null
                ? lastMsgOpt.get().getCreatedAt().format(TIME_FORMATTER)
                : "Just now";

        long unreadCount = messageRepository.countUnreadMessages(conv.getId(), currentUserEmail);

        return ConversationResponse.builder()
                .conversationId(conv.getId())
                .customerEmail(conv.getCustomerEmail())
                .customerName(conv.getCustomerName())
                .resellerEmail(conv.getResellerEmail())
                .resellerName(conv.getResellerName())
                .peerEmail(peerEmail)
                .peerName(peerName)
                .peerAvatar(peerAvatar)
                .productTitle(conv.getProductTitle())
                .lastMessage(lastMsg)
                .lastMessageTime(lastMsgTime)
                .unreadCount(unreadCount)
                .updatedAt(conv.getUpdatedAt())
                .build();
    }

    private MessageResponse buildMessageResponse(ChatMessage m) {
        String timeStr = m.getCreatedAt() != null ? m.getCreatedAt().format(TIME_FORMATTER) : "Just now";
        return MessageResponse.builder()
                .id(m.getId())
                .conversationId(m.getConversationId())
                .senderEmail(m.getSenderEmail())
                .senderName(m.getSenderName())
                .receiverEmail(m.getReceiverEmail())
                .text(m.getMessageText())
                .imagePath(m.getImagePath())
                .type(m.getMessageType())
                .isRead(m.getIsRead())
                .time(timeStr)
                .createdAt(m.getCreatedAt())
                .build();
    }
}
