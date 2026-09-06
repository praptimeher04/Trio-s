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
            // Auto-create user if purva/reseller or type 1 is selected
            int reqType = (request.getUserType() != null && request.getUserType() == 1) ||
                    email.contains("purva") || email.contains("reseller") ? 1 : 0;
            String reqRole = reqType == 1 ? "Reseller" : "Student";
            String rawPassword = request.getPassword() != null && !request.getPassword().isEmpty() ? request.getPassword() : "Pass@1234";
            String defaultName = email.contains("@") ? email.split("@")[0] : (email.equalsIgnoreCase("purva") ? "Purva Reseller" : "Campus User");

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

        if ((request.getUserType() != null && request.getUserType() == 1) ||
                (user.getRole() != null && user.getRole().equalsIgnoreCase("Reseller")) ||
                (user.getEmail() != null && (user.getEmail().toLowerCase().contains("purva") || user.getEmail().toLowerCase().contains("reseller"))) ||
                (user.getName() != null && user.getName().toLowerCase().contains("purva"))) {
            user.setUserType(1);
            user.setRole("Reseller");
            user = userRepository.save(user);
        }

        int calculatedUserType = user.getUserType() != null ? user.getUserType() : 0;

        return ResponseEntity.ok(
                AuthResponse.builder()
                        .success(true)
                        .message(calculatedUserType == 1 ? "Reseller login successful!" : "Login successful!")
                        .userId(user.getId())
                        .name(user.getName())
                        .email(user.getEmail())
                        .role(calculatedUserType == 1 ? "Reseller" : (user.getRole() != null ? user.getRole() : "Student"))
                        .userType(calculatedUserType)
                        .mobileNumber(user.getMobileNumber() != null ? user.getMobileNumber() : "+91 98765 43210")
                        .build()
        );
    }

    @GetMapping("/user/{id}")
    public ResponseEntity<AuthResponse> getUserById(@PathVariable Long id) {
        Optional<User> userOptional = userRepository.findById(id);
        if (userOptional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(
                    AuthResponse.builder()
                            .success(false)
                            .message("User record not found in database.")
                            .build()
            );
        }

        User user = userOptional.get();
        if ((user.getRole() != null && user.getRole().equalsIgnoreCase("Reseller")) ||
                (user.getEmail() != null && (user.getEmail().toLowerCase().contains("purva") || user.getEmail().toLowerCase().contains("reseller"))) ||
                (user.getName() != null && user.getName().toLowerCase().contains("purva"))) {
            user.setUserType(1);
            user.setRole("Reseller");
            user = userRepository.save(user);
        }

        int userTypeVal = user.getUserType() != null ? user.getUserType() : 0;

        return ResponseEntity.ok(
                AuthResponse.builder()
                        .success(true)
                        .message("User details retrieved successfully.")
                        .userId(user.getId())
                        .name(user.getName())
                        .email(user.getEmail())
                        .role(userTypeVal == 1 ? "Reseller" : (user.getRole() != null ? user.getRole() : "Student"))
                        .userType(userTypeVal)
                        .mobileNumber(user.getMobileNumber() != null ? user.getMobileNumber() : "+91 98765 43210")
                        .build()
        );
    }

    @GetMapping("/verify-reseller/{id}")
    public ResponseEntity<AuthResponse> verifyReseller(@PathVariable Long id) {
        Optional<User> userOptional = userRepository.findById(id);
        if (userOptional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(
                    AuthResponse.builder()
                            .success(false)
                            .message("User record not found.")
                            .build()
            );
        }

        User user = userOptional.get();
        if (user.getUserType() != null && user.getUserType() == 1) {
            return ResponseEntity.ok(
                    AuthResponse.builder()
                            .success(true)
                            .message("User is an authorized reseller (user_type = 1).")
                            .userId(user.getId())
                            .userType(1)
                            .build()
            );
        }

        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(
                AuthResponse.builder()
                        .success(false)
                        .message("Access denied. User is not a reseller (user_type = 0).")
                        .userId(user.getId())
                        .userType(0)
                        .build()
        );
    }

    @GetMapping("/all-users")
    public ResponseEntity<java.util.List<User>> getAllUsers() {
        return ResponseEntity.ok(userRepository.findAll());
    }
}

