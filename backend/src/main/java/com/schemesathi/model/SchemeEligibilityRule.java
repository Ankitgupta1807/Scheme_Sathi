package com.schemesathi.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "scheme_eligibility_rules")
public class SchemeEligibilityRule {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "scheme_id", nullable = false)
    private Scheme scheme;

    @Column(name = "field_name", nullable = false, length = 80)
    private String fieldName;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Operator operator;

    @Column(name = "value_text", length = 255)
    private String valueText;

    @Column(name = "value_number", precision = 14, scale = 2)
    private java.math.BigDecimal valueNumber;

    @Column(name = "value_json", columnDefinition = "JSON")
    private String valueJson; // store JSON as string

    @Column(nullable = false, precision = 5, scale = 2)
    private java.math.BigDecimal points = java.math.BigDecimal.ZERO;

    @Column(name = "is_mandatory", nullable = false)
    private boolean mandatory = false;

    @Column(name = "rule_group", length = 80)
    private String ruleGroup;

    @Column(length = 500)
    private String description;

    @Column(name = "created_at", nullable = false, updatable = false,
            columnDefinition = "DATETIME DEFAULT CURRENT_TIMESTAMP")
    private java.time.LocalDateTime createdAt;

    public enum Operator {
        EQ, NEQ, GT, GTE, LT, LTE, IN, NOT_IN, BOOLEAN
    }
}

