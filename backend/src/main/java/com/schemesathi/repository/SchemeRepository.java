package com.schemesathi.repository;

import com.schemesathi.model.Scheme;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SchemeRepository extends JpaRepository<Scheme, Long> {
    Scheme findBySlug(String slug);
    List<Scheme> findByCategoryId(Integer categoryId);
    List<Scheme> findByNameContainingIgnoreCase(String keyword);
}

