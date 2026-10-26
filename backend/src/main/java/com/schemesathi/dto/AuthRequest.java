package com.schemesathi.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthRequest {
    private String name;
    private String email;
    private String password;
    private String phone;
    private String role;
    private String avatarColor;
    private Map<String, Object> profile;
}
