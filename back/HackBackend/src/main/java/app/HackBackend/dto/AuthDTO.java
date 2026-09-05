package app.HackBackend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

public class AuthDTO {

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RegisterRequest {
        private String name;
        private String email;
        private String role;
        private String password;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LoginRequest {
        private String email;
        private String password;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AuthResponse {
        private boolean success;
        private String message;
        private String name;
        private String email;
        private String role;
        private Long userId;
    }
}
