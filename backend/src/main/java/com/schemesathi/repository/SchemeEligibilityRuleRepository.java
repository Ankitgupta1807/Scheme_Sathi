package com.schemesathi.repository;

import com.schemesathi.model.SchemeEligibilityRule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SchemeEligibilityRuleRepository extends JpaRepository<SchemeEligibilityRule, Long> {
    List<SchemeEligibilityRule> findBySchemeId(Long schemeId);
}

