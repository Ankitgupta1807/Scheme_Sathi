package com.schemesathi.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "family_members")
public class FamilyMember {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 120)
    private String name;

    @Column(nullable = false, length = 50)
    private String relation;

    @Column(name = "date_of_birth")
    private java.time.LocalDate dateOfBirth;

    @Column(name = "age")
    private Integer age;

    @Column(length = 30)
    private String gender;

    @Column(length = 100)
    private String state;

    @Column(length = 100)
    private String district;

    @Column(length = 80)
    private String occupation;

    @Column(name = "annual_income", precision = 12, scale = 2)
    private java.math.BigDecimal annualIncome;

    @Column(name = "social_category", length = 40)
    private String socialCategory;

    @Column(name = "education_level", length = 100)
    private String educationLevel;

    @Column(name = "has_disability", nullable = false)
    private boolean hasDisability = false;

    @Column(name = "is_minority", nullable = false)
    private boolean isMinority = false;

    @Column(name = "created_at", nullable = false, updatable = false,
            columnDefinition = "DATETIME DEFAULT CURRENT_TIMESTAMP")
    private java.time.LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false,
            columnDefinition = "DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP")
    private java.time.LocalDateTime updatedAt;
}

