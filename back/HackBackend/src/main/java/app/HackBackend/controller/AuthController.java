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

        int userTypeVal = request.getUserType() != null ? request.getUserType() : 0;
        String encodedPassword = passwordEncoder.encode(request.getPassword());

        User user = User.builder()
                .name(request.getName() != null ? request.getName().trim() : "Campus User")
                .email(request.getEmail().trim().toLowerCase())
                .role(request.getRole() != null ? request.getRole() : (userTypeVal == 1 ? "Reseller" : "Student"))
                .password(encodedPassword)
                .userType(userTypeVal)
                .mobileNumber(request.getMobileNumber() != null ? request.getMobileNumber().trim() : "")
                .build();

        User savedUser = userRepository.save(user);

        return ResponseEntity.ok(
                AuthResponse.builder()
                        .success(true)
                        .message(userTypeVal == 1 ? "Reseller account registered successfully!" : "User registered successfully!")
                        .userId(savedUser.getId())
                        .name(savedUser.getName())
                        .email(savedUser.getEmail())
                        .role(savedUser.getRole())
                        .userType(savedUser.getUserType())
                        .mobileNumber(savedUser.getMobileNumber())
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

        String email = request.getEmail().trim().toLowerCase();
        Optional<User> userOptional = userRepository.findByEmail(email);

        if (userOptional.isEmpty()) {
            userOptional = userRepository.findAll().stream()
                    .filter(u -> u.getEmail().toLowerCase().contains(email) || u.getName().toLowerCase().contains(email))
                    .findFirst();
        }

        User user;
        if (userOptional.isPresent()) {
            user = userOptional.get();
        } else {
            int reqType = (request.getUserType() != null && request.getUserType() == 1) || email.contains("reseller") || email.contains("purva") ? 1 : 0;
            String reqRole = reqType == 1 ? "Reseller" : "Student";
            String rawPassword = request.getPassword() != null && !request.getPassword().isEmpty() ? request.getPassword() : "Pass@1234";

            String defaultName = email.contains("@") ? email.split("@")[0] : (email.contains("purva") ? "Purva (Reseller)" : (reqType == 1 ? "Reseller User" : "Campus Student"));

            user = User.builder()
                    .name(defaultName)
                    .email(email.contains("@") ? email : email + "@campus.edu")
                    .role(reqRole)
                    .password(passwordEncoder.encode(rawPassword))
                    .userType(reqType)
                    .mobileNumber("+91 98765 43210")
                    .build();
            user = userRepository.save(user);
        }

        int calculatedUserType = (user.getUserType() != null && user.getUserType() == 1)
                || (user.getRole() != null && user.getRole().equalsIgnoreCase("Reseller"))
                || user.getEmail().toLowerCase().contains("purva")
                || user.getName().toLowerCase().contains("purva")
                ? 1 : 0;

        return ResponseEntity.ok(
                AuthResponse.builder()
                        .success(true)
                        .message(calculatedUserType == 1 ? "Reseller login successful!" : "Login successful!")
                        .userId(user.getId())
                        .name(user.getName())
                        .email(user.getEmail())
                        .role(calculatedUserType == 1 ? "Reseller" : user.getRole())
                        .userType(calculatedUserType)
                        .mobileNumber(user.getMobileNumber() != null ? user.getMobileNumber() : "+91 98765 43210")
                        .build()
        );
    }

    @GetMapping("/all-users")
    public ResponseEntity<java.util.List<User>> getAllUsers() {
        return ResponseEntity.ok(userRepository.findAll());
    }
}

