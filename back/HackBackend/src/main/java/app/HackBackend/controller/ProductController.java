package app.HackBackend.controller;

import app.HackBackend.dto.ProductDTO.*;
import app.HackBackend.entity.Product;
import app.HackBackend.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class ProductController {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private app.HackBackend.repository.UserRepository userRepository;

    @PostMapping("/create")
    public ResponseEntity<ProductResponse> createProduct(@RequestBody CreateProductRequest request) {
        if (request.getTitle() == null || request.getTitle().trim().isEmpty()) {
            return ResponseEntity.badRequest().body(
                    ProductResponse.builder()
                            .success(false)
                            .message("Product title is required.")
                            .build()
            );
        }

        // Database validation: check seller email in database to ensure user_type = 1
        if (request.getSellerEmail() != null && !request.getSellerEmail().trim().isEmpty()) {
            String email = request.getSellerEmail().trim().toLowerCase();
            var sellerUserOpt = userRepository.findByEmail(email);
            if (sellerUserOpt.isPresent()) {
                var sellerUser = sellerUserOpt.get();
                if (sellerUser.getUserType() != null && sellerUser.getUserType() == 0) {
                    return ResponseEntity.status(org.springframework.http.HttpStatus.FORBIDDEN).body(
                            ProductResponse.builder()
                                    .success(false)
                                    .message("Access denied. Only reseller accounts (user_type = 1) can post product listings.")
                                    .build()
                    );
                }
            }
        }

        Product product = Product.builder()
                .title(request.getTitle().trim())
                .price(request.getPrice() != null ? request.getPrice().trim() : "₹350")
                .category(request.getCategory() != null ? request.getCategory() : "Engineering")
                .condition(request.getCondition() != null ? request.getCondition() : "Like New")
                .description(request.getDescription() != null ? request.getDescription() : "")
                .sellerName(request.getSellerName() != null ? request.getSellerName() : "Reseller")
                .sellerEmail(request.getSellerEmail() != null ? request.getSellerEmail() : "reseller@campus.edu")
                .imageUrl(request.getImageUrl() != null ? request.getImageUrl() : "")
                .status("Active")
                .views("1 view")
                .build();

        Product savedProduct = productRepository.save(product);

        return ResponseEntity.ok(
                ProductResponse.builder()
                        .success(true)
                        .message("Product listing created successfully in database!")
                        .productId(savedProduct.getId())
                        .title(savedProduct.getTitle())
                        .price(savedProduct.getPrice())
                        .category(savedProduct.getCategory())
                        .condition(savedProduct.getCondition())
                        .sellerName(savedProduct.getSellerName())
                        .imageUrl(savedProduct.getImageUrl())
                        .status(savedProduct.getStatus())
                        .build()
        );
    }

    @GetMapping("/all")
    public ResponseEntity<List<Product>> getAllProducts() {
        return ResponseEntity.ok(productRepository.findAll());
    }

    @GetMapping("/seller/{email}")
    public ResponseEntity<List<Product>> getProductsBySeller(@PathVariable String email) {
        return ResponseEntity.ok(productRepository.findBySellerEmail(email.trim().toLowerCase()));
    }
}
