package com.schemesathi.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "schemes")
public class Scheme {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "scheme_code", nullable = false, unique = true, length = 100)
    private String schemeCode;

    @Column(nullable = false, unique = true, length = 180)
    private String slug;

    @Column(nullable = false, length = 255)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Column(length = 20)
    private String icon;

    @Column(length = 255)
    private String department;

    @Column(length = 255)
    private String ministry;

    @Column(name = "short_description", columnDefinition = "TEXT")
    private String shortDescription;

    @Column(name = "detailed_description", columnDefinition = "TEXT")
    private String detailedDescription;

    @Column(name = "benefits_summary", columnDefinition = "TEXT")
    private String benefitsSummary;

    @Column(name = "official_link", length = 1000)
    private String officialLink;

    @Column(name = "portal_name", length = 255)
    private String portalName;

    @Column(length = 255)
    private String deadline;

    @Column(name = "min_age")
    private Integer minAge;

    @Column(name = "max_age")
    private Integer maxAge;

    @Column(name = "income_limit", precision = 12, scale = 2)
    private java.math.BigDecimal incomeLimit;

    @Column(name = "disability_required", nullable = false)
    private boolean disabilityRequired = false;

    @Column(name = "minority_required", nullable = false)
    private boolean minorityRequired = false;

    @Column(name = "farmer_only", nullable = false)
    private boolean farmerOnly = false;

    @Column(name = "is_active", nullable = false)
    private boolean active = true;

    @Column(name = "created_at", nullable = false, updatable = false,
            columnDefinition = "DATETIME DEFAULT CURRENT_TIMESTAMP")
    private java.time.LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false,
            columnDefinition = "DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP")
    private java.time.LocalDateTime updatedAt;
}

