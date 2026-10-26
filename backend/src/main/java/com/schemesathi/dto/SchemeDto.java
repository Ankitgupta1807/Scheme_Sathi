package com.schemesathi.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SchemeDto {
    private String id;
    private Long dbId;
    private String schemeCode;
    private String slug;
    private String name;
    private String category;
    private String categoryColor;
    private String icon;
    private String department;
    private String ministry;
    private String shortDescription;
    private String detailedDescription;
    private String benefitsSummary;
    private List<String> detailedBenefits;
    private Integer minAge;
    private Integer maxAge;
    private BigDecimal incomeLimit;
    private List<String> states;
    private List<String> occupations;
    private List<String> genders;
    private List<String> education;
    private boolean disabilityRequired;
    private boolean minorityRequired;
    private boolean farmerOnly;
    private List<String> documents;
    private List<String> applicationProcess;
    private String officialLink;
    private String portalName;
    private String deadline;
    private boolean active;
}
