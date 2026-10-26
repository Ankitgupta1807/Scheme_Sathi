package com.schemesathi.service;

import com.schemesathi.dto.AuthRequest;
import com.schemesathi.dto.AuthResponse;
import com.schemesathi.model.User;
import com.schemesathi.repository.UserRepository;
import com.schemesathi.security.JwtTokenProvider;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
@Transactional
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    public AuthService(UserRepository userRepository,
                       PasswordEncoder passwordEncoder,
                       JwtTokenProvider jwtTokenProvider) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    public AuthResponse register(AuthRequest request) {
        String email = request.getEmail() != null ? request.getEmail().trim().toLowerCase() : "";
        if (email.isBlank()) {
            throw new IllegalArgumentException("Email address is required.");
        }

        if (userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("An account with email " + email + " already exists.");
        }

        User user = new User();
        user.setName(request.getName() != null ? request.getName().trim() : "Citizen");
        user.setEmail(email);
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setRole(User.Role.CITIZEN);
        user.setPhone(request.getPhone());
        user.setAvatarColor(request.getAvatarColor() != null ? request.getAvatarColor() : "#2563eb");
        user.setActive(true);
        user.setVerified(true);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());

        User saved = userRepository.save(user);
        String token = jwtTokenProvider.generateToken(saved.getEmail(), saved.getId());

        return AuthResponse.builder()
                .token(token)
                .type("Bearer")
                .id(saved.getId())
                .name(saved.getName())
                .email(saved.getEmail())
                .role("Citizen")
                .avatarColor(saved.getAvatarColor())
                .profile(request.getProfile())
                .message("Account registered successfully in database.")
                .build();
    }

    public AuthResponse login(AuthRequest request) {
        String email = request.getEmail() != null ? request.getEmail().trim().toLowerCase() : "";
        Optional<User> optionalUser = userRepository.findByEmail(email);

        if (optionalUser.isEmpty()) {
            throw new IllegalArgumentException("No account found for email: " + email);
        }

        User user = optionalUser.get();
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Incorrect password entered.");
        }

        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        String token = jwtTokenProvider.generateToken(user.getEmail(), user.getId());

        return AuthResponse.builder()
                .token(token)
                .type("Bearer")
                .id(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .role("Citizen")
                .avatarColor(user.getAvatarColor())
                .profile(request.getProfile())
                .message("Login successful.")
                .build();
    }

    public AuthResponse getCurrentUser(String email) {
        Optional<User> optionalUser = userRepository.findByEmail(email);
        if (optionalUser.isEmpty()) {
            return null;
        }
        User user = optionalUser.get();
        return AuthResponse.builder()
                .id(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .role(user.getRole().name())
                .avatarColor(user.getAvatarColor())
                .build();
    }
}
