package com.schemesathi.controller;

import com.schemesathi.dto.SchemeDto;
import com.schemesathi.service.SchemeService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/schemes")
@CrossOrigin(origins = {"http://localhost:5173", "http://127.0.0.1:5173", "http://localhost:3000", "*"})
public class SchemeController {

    private final SchemeService schemeService;

    public SchemeController(SchemeService schemeService) {
        this.schemeService = schemeService;
    }

    @GetMapping
    public ResponseEntity<List<SchemeDto>> getAllSchemes() {
        return ResponseEntity.ok(schemeService.getAllSchemes());
    }

    @GetMapping("/{slug}")
    public ResponseEntity<SchemeDto> getSchemeBySlug(@PathVariable String slug) {
        SchemeDto scheme = schemeService.getSchemeBySlug(slug);
        if (scheme == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(scheme);
    }

    @GetMapping("/category/{categoryId}")
    public ResponseEntity<List<SchemeDto>> getSchemesByCategory(@PathVariable Integer categoryId) {
        return ResponseEntity.ok(schemeService.getSchemesByCategory(categoryId));
    }

    @GetMapping("/search")
    public ResponseEntity<List<SchemeDto>> searchSchemes(@RequestParam("q") String query) {
        return ResponseEntity.ok(schemeService.searchSchemes(query));
    }
}
