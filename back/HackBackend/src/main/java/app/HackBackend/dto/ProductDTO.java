package app.HackBackend.dto;

import lombok.*;

public class ProductDTO {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CreateProductRequest {
        private String title;
        private String price;
        private String category;
        private String condition;
        private String description;
        private String sellerName;
        private String sellerEmail;
        private String imageUrl;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ProductResponse {
        private boolean success;
        private String message;
        private Long productId;
        private String title;
        private String price;
        private String category;
        private String condition;
        private String sellerName;
        private String imageUrl;
        private String status;
    }
}
