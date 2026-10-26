package com.schemesathi.service;

import com.schemesathi.dto.SchemeDto;
import com.schemesathi.model.Category;
import com.schemesathi.model.Scheme;
import com.schemesathi.repository.SchemeRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class SchemeService {

    private final SchemeRepository schemeRepository;

    public SchemeService(SchemeRepository schemeRepository) {
        this.schemeRepository = schemeRepository;
    }

    public List<SchemeDto> getAllSchemes() {
        return schemeRepository.findAll().stream()
                .filter(Scheme::isActive)
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public SchemeDto getSchemeBySlug(String slug) {
        Scheme scheme = schemeRepository.findBySlug(slug);
        return scheme != null ? mapToDto(scheme) : null;
    }

    public List<SchemeDto> getSchemesByCategory(Integer categoryId) {
        return schemeRepository.findByCategoryId(categoryId).stream()
                .filter(Scheme::isActive)
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public List<SchemeDto> searchSchemes(String keyword) {
        return schemeRepository.findByNameContainingIgnoreCase(keyword).stream()
                .filter(Scheme::isActive)
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    private SchemeDto mapToDto(Scheme entity) {
        Category category = entity.getCategory();
        String categoryName = (category != null && category.getName() != null) ? category.getName() : "General";

        return SchemeDto.builder()
                .id(entity.getSchemeCode())
                .dbId(entity.getId())
                .schemeCode(entity.getSchemeCode())
                .slug(entity.getSlug())
                .name(entity.getName())
                .category(categoryName)
                .categoryColor(getCategoryColor(categoryName))
                .icon(entity.getIcon() != null ? entity.getIcon() : "🏛️")
                .department(entity.getDepartment())
                .ministry(entity.getMinistry())
                .shortDescription(entity.getShortDescription())
                .detailedDescription(entity.getDetailedDescription())
                .benefitsSummary(entity.getBenefitsSummary())
                .detailedBenefits(splitOrSingle(entity.getBenefitsSummary()))
                .minAge(entity.getMinAge())
                .maxAge(entity.getMaxAge())
                .incomeLimit(entity.getIncomeLimit())
                .states(Collections.singletonList("All"))
                .occupations(entity.isFarmerOnly() ? Collections.singletonList("Farmer") : Collections.singletonList("All"))
                .genders(Collections.singletonList("All"))
                .education(Collections.singletonList("All"))
                .disabilityRequired(entity.isDisabilityRequired())
                .minorityRequired(entity.isMinorityRequired())
                .farmerOnly(entity.isFarmerOnly())
                .documents(getDefaultDocumentsForCategory(categoryName))
                .applicationProcess(getDefaultApplicationProcess(entity.getPortalName()))
                .officialLink(entity.getOfficialLink())
                .portalName(entity.getPortalName())
                .deadline(entity.getDeadline() != null ? entity.getDeadline() : "Open Throughout The Year")
                .active(entity.isActive())
                .build();
    }

    private List<String> splitOrSingle(String summary) {
        List<String> list = new ArrayList<>();
        if (summary != null && !summary.isBlank()) {
            list.add(summary);
        }
        return list;
    }

    private String getCategoryColor(String category) {
        switch (category.toLowerCase()) {
            case "agriculture": return "#10b981";
            case "education": return "#3b82f6";
            case "employment": return "#f59e0b";
            case "business": return "#8b5cf6";
            case "skill development": return "#06b6d4";
            case "healthcare": return "#ef4444";
            case "housing": return "#14b8a6";
            case "women & child": return "#ec4899";
            case "senior citizens": return "#64748b";
            case "disability support": return "#6366f1";
            default: return "#2563eb";
        }
    }

    private List<String> getDefaultDocumentsForCategory(String category) {
        List<String> docs = new ArrayList<>();
        docs.add("Aadhaar Card (Aadhaar linked with Mobile)");
        docs.add("Active Bank Account / Passbook copy");
        docs.add("Income / Residence Certificate");
        return docs;
    }

    private List<String> getDefaultApplicationProcess(String portalName) {
        List<String> steps = new ArrayList<>();
        steps.add("Visit the official " + (portalName != null ? portalName : "Government") + " portal.");
        steps.add("Register or login using your Aadhaar or Mobile number.");
        steps.add("Fill in the scheme application form and upload required documents.");
        steps.add("Submit and keep the Application Reference Number for tracking.");
        return steps;
    }
}
