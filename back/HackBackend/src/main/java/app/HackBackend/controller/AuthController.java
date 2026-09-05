package app.HackBackend.controller;

import app.HackBackend.dto.AuthDTO.*;
import app.HackBackend.entity.User;
import app.HackBackend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody RegisterRequest request) {
        if (request.getEmail() == null || request.getEmail().trim().isEmpty()) {
            return ResponseEntity.badRequest().body(
                    AuthResponse.builder()
                            .success(false)
                            .message("Email is required.")
                            .build()
            );
        }

        if (userRepository.existsByEmail(request.getEmail().trim().toLowerCase())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(
                    AuthResponse.builder()
                            .success(false)
                            .message("Email is already registered. Please sign in.")
                            .build()
            );
        }

        String encodedPassword = passwordEncoder.encode(request.getPassword());
        User user = User.builder()
                .name(request.getName() != null ? request.getName().trim() : "Campus User")
                .email(request.getEmail().trim().toLowerCase())
                .role(request.getRole() != null ? request.getRole() : "Student")
                .password(encodedPassword)
                .build();

        User savedUser = userRepository.save(user);

        return ResponseEntity.ok(
                AuthResponse.builder()
                        .success(true)
                        .message("User registered successfully!")
                        .userId(savedUser.getId())
                        .name(savedUser.getName())
                        .email(savedUser.getEmail())
                        .role(savedUser.getRole())
                        .build()
        );
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest request) {
        if (request.getEmail() == null || request.getEmail().trim().isEmpty()) {
            return ResponseEntity.badRequest().body(
                    AuthResponse.builder()
                            .success(false)
                            .message("Email or Campus ID is required.")
                            .build()
            );
        }

        Optional<User> userOptional = userRepository.findByEmail(request.getEmail().trim().toLowerCase());

        if (userOptional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                    AuthResponse.builder()
                            .success(false)
                            .message("User not found with this email.")
                            .build()
            );
        }

        User user = userOptional.get();

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                    AuthResponse.builder()
                            .success(false)
                            .message("Invalid password credentials.")
                            .build()
            );
        }

        return ResponseEntity.ok(
                AuthResponse.builder()
                        .success(true)
                        .message("Login successful!")
                        .userId(user.getId())
                        .name(user.getName())
                        .email(user.getEmail())
                        .role(user.getRole())
                        .build()
        );
    }
}
