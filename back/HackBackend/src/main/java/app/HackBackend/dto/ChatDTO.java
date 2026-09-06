package app.HackBackend.dto;

import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

public class ChatDTO {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class StartConversationRequest {
        private String customerEmail;
        private String customerName;
        private String resellerEmail;
        private String resellerName;
        private String productTitle;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SendMessageRequest {
        private Long conversationId;
        private String senderEmail;
        private String senderName;
        private String receiverEmail;
        private String messageText;
        private String imagePath;
        private String messageType;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ConversationResponse {
        private Long conversationId;
        private String customerEmail;
        private String customerName;
        private String resellerEmail;
        private String resellerName;
        private String peerEmail;
        private String peerName;
        private String peerAvatar;
        private String productTitle;
        private String lastMessage;
        private String lastMessageTime;
        private long unreadCount;
        private LocalDateTime updatedAt;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class MessageResponse {
        private Long id;
        private Long conversationId;
        private String senderEmail;
        private String senderName;
        private String receiverEmail;
        private String text;
        private String imagePath;
        private String type;
        private Boolean isRead;
        private String time;
        private LocalDateTime createdAt;
    }
}
