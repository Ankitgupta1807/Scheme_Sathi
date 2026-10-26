-- ================================================================
-- SCHEME SATHI - MySQL 8.0+ Database Schema + Seed Data
-- Generated from the current Scheme Sathi frontend dataset.
-- The frontend currently contains 28 schemes, a 100-point matcher,
-- a 5-step wizard, saved schemes and a 5-stage application tracker.
-- ================================================================

CREATE DATABASE IF NOT EXISTS scheme_sathi CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE scheme_sathi;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS application_status_history;
DROP TABLE IF EXISTS application_documents;
DROP TABLE IF EXISTS applications;
DROP TABLE IF EXISTS saved_schemes;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS password_reset_tokens;
DROP TABLE IF EXISTS family_members;
DROP TABLE IF EXISTS student_profiles;
DROP TABLE IF EXISTS scheme_application_steps;
DROP TABLE IF EXISTS scheme_documents;
DROP TABLE IF EXISTS scheme_benefits;
DROP TABLE IF EXISTS scheme_eligibility_rules;
DROP TABLE IF EXISTS schemes;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20) NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('CITIZEN','ADMIN') NOT NULL DEFAULT 'CITIZEN',
    avatar_color VARCHAR(30) NULL,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_users_role (role),
    INDEX idx_users_active (is_active)
) ENGINE=InnoDB;

CREATE TABLE categories (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE,
    icon VARCHAR(20) NULL,
    description VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE student_profiles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    date_of_birth DATE NULL,
    age TINYINT UNSIGNED NULL,
    gender VARCHAR(30) NULL,
    state VARCHAR(100) NULL,
    district VARCHAR(100) NULL,
    area_type ENUM('RURAL','URBAN','SEMI_URBAN','UNKNOWN') NOT NULL DEFAULT 'UNKNOWN',
    occupation VARCHAR(80) NULL,
    annual_family_income DECIMAL(12,2) NULL,
    income_bracket VARCHAR(50) NULL,
    social_category VARCHAR(40) NULL,
    education_level VARCHAR(100) NULL,
    course VARCHAR(120) NULL,
    college VARCHAR(180) NULL,
    year_of_study VARCHAR(30) NULL,
    percentage DECIMAL(5,2) NULL,
    land_holding VARCHAR(80) NULL,
    business_type VARCHAR(80) NULL,
    has_disability BOOLEAN NOT NULL DEFAULT FALSE,
    is_minority BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_profile_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_profile_state (state),
    INDEX idx_profile_occupation (occupation),
    INDEX idx_profile_income (annual_family_income)
) ENGINE=InnoDB;

CREATE TABLE family_members (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(120) NOT NULL,
    relation VARCHAR(50) NOT NULL,
    date_of_birth DATE NULL,
    age TINYINT UNSIGNED NULL,
    gender VARCHAR(30) NULL,
    state VARCHAR(100) NULL,
    district VARCHAR(100) NULL,
    occupation VARCHAR(80) NULL,
    annual_income DECIMAL(12,2) NULL,
    social_category VARCHAR(40) NULL,
    education_level VARCHAR(100) NULL,
    has_disability BOOLEAN NOT NULL DEFAULT FALSE,
    is_minority BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_family_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_family_user (user_id)
) ENGINE=InnoDB;

CREATE TABLE schemes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    scheme_code VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(180) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    category_id INT UNSIGNED NOT NULL,
    icon VARCHAR(20) NULL,
    department VARCHAR(255) NULL,
    ministry VARCHAR(255) NULL,
    short_description TEXT NULL,
    detailed_description TEXT NULL,
    benefits_summary TEXT NULL,
    official_link VARCHAR(1000) NULL,
    portal_name VARCHAR(255) NULL,
    deadline VARCHAR(255) NULL,
    min_age TINYINT UNSIGNED NULL,
    max_age TINYINT UNSIGNED NULL,
    income_limit DECIMAL(12,2) NULL,
    disability_required BOOLEAN NOT NULL DEFAULT FALSE,
    minority_required BOOLEAN NOT NULL DEFAULT FALSE,
    farmer_only BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_scheme_category FOREIGN KEY (category_id) REFERENCES categories(id),
    INDEX idx_scheme_category (category_id),
    INDEX idx_scheme_active (is_active),
    INDEX idx_scheme_deadline (deadline(50))
) ENGINE=InnoDB;

CREATE TABLE scheme_eligibility_rules (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    scheme_id BIGINT UNSIGNED NOT NULL,
    field_name VARCHAR(80) NOT NULL,
    operator ENUM('=','!=','>','>=','<','<=','IN','NOT_IN','BOOLEAN') NOT NULL,
    value_text VARCHAR(255) NULL,
    value_number DECIMAL(14,2) NULL,
    value_json JSON NULL,
    points DECIMAL(5,2) NOT NULL DEFAULT 0,
    is_mandatory BOOLEAN NOT NULL DEFAULT FALSE,
    rule_group VARCHAR(80) NULL,
    description VARCHAR(500) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rule_scheme FOREIGN KEY (scheme_id) REFERENCES schemes(id) ON DELETE CASCADE,
    INDEX idx_rules_scheme (scheme_id),
    INDEX idx_rules_field (field_name)
) ENGINE=InnoDB;

CREATE TABLE scheme_benefits (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    scheme_id BIGINT UNSIGNED NOT NULL,
    benefit_name VARCHAR(255) NOT NULL,
    amount DECIMAL(14,2) NULL,
    frequency VARCHAR(50) NULL,
    description TEXT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_benefit_scheme FOREIGN KEY (scheme_id) REFERENCES schemes(id) ON DELETE CASCADE,
    INDEX idx_benefit_scheme (scheme_id)
) ENGINE=InnoDB;

CREATE TABLE scheme_documents (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    scheme_id BIGINT UNSIGNED NOT NULL,
    document_name VARCHAR(255) NOT NULL,
    is_mandatory BOOLEAN NOT NULL DEFAULT TRUE,
    description VARCHAR(500) NULL,
    sort_order INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_document_scheme FOREIGN KEY (scheme_id) REFERENCES schemes(id) ON DELETE CASCADE,
    INDEX idx_document_scheme (scheme_id)
) ENGINE=InnoDB;

CREATE TABLE scheme_application_steps (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    scheme_id BIGINT UNSIGNED NOT NULL,
    step_number INT NOT NULL,
    step_text TEXT NOT NULL,
    CONSTRAINT fk_step_scheme FOREIGN KEY (scheme_id) REFERENCES schemes(id) ON DELETE CASCADE,
    UNIQUE KEY uq_scheme_step (scheme_id, step_number)
) ENGINE=InnoDB;

CREATE TABLE saved_schemes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    scheme_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_saved_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_saved_scheme FOREIGN KEY (scheme_id) REFERENCES schemes(id) ON DELETE CASCADE,
    UNIQUE KEY uq_saved_scheme (user_id, scheme_id),
    INDEX idx_saved_user (user_id)
) ENGINE=InnoDB;

CREATE TABLE applications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    scheme_id BIGINT UNSIGNED NOT NULL,
    family_member_id BIGINT UNSIGNED NULL,
    eligibility_score DECIMAL(5,2) NULL,
    status ENUM('INTERESTED','DOCUMENTS_PENDING','APPLIED','UNDER_REVIEW','APPROVED','REJECTED','COMPLETED','WITHDRAWN') NOT NULL DEFAULT 'INTERESTED',
    application_reference VARCHAR(150) NULL,
    applied_at DATETIME NULL,
    rejection_reason TEXT NULL,
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_app_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_app_scheme FOREIGN KEY (scheme_id) REFERENCES schemes(id) ON DELETE CASCADE,
    CONSTRAINT fk_app_family FOREIGN KEY (family_member_id) REFERENCES family_members(id) ON DELETE SET NULL,
    INDEX idx_app_user (user_id),
    INDEX idx_app_scheme (scheme_id),
    INDEX idx_app_status (status),
    UNIQUE KEY uq_user_scheme_family (user_id, scheme_id, family_member_id)
) ENGINE=InnoDB;

CREATE TABLE application_status_history (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    application_id BIGINT UNSIGNED NOT NULL,
    old_status VARCHAR(40) NULL,
    new_status VARCHAR(40) NOT NULL,
    remarks TEXT NULL,
    changed_by BIGINT UNSIGNED NULL,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_application FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE,
    CONSTRAINT fk_history_user FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_history_application (application_id),
    INDEX idx_history_changed_at (changed_at)
) ENGINE=InnoDB;

CREATE TABLE application_documents (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    application_id BIGINT UNSIGNED NOT NULL,
    scheme_document_id BIGINT UNSIGNED NOT NULL,
    file_path VARCHAR(1000) NULL,
    document_status ENUM('PENDING','UPLOADED','VERIFIED','REJECTED') NOT NULL DEFAULT 'PENDING',
    rejection_reason TEXT NULL,
    uploaded_at DATETIME NULL,
    verified_at DATETIME NULL,
    verified_by BIGINT UNSIGNED NULL,
    CONSTRAINT fk_appdoc_application FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE,
    CONSTRAINT fk_appdoc_scheme_document FOREIGN KEY (scheme_document_id) REFERENCES scheme_documents(id) ON DELETE CASCADE,
    CONSTRAINT fk_appdoc_verifier FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY uq_application_document (application_id, scheme_document_id),
    INDEX idx_appdoc_application (application_id)
) ENGINE=InnoDB;

CREATE TABLE notifications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type ENUM('INFO','SUCCESS','WARNING','DEADLINE','APPLICATION','SYSTEM') NOT NULL DEFAULT 'INFO',
    related_scheme_id BIGINT UNSIGNED NULL,
    related_application_id BIGINT UNSIGNED NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_notification_scheme FOREIGN KEY (related_scheme_id) REFERENCES schemes(id) ON DELETE SET NULL,
    CONSTRAINT fk_notification_application FOREIGN KEY (related_application_id) REFERENCES applications(id) ON DELETE SET NULL,
    INDEX idx_notification_user_read (user_id, is_read),
    INDEX idx_notification_created (created_at)
) ENGINE=InnoDB;

CREATE TABLE password_reset_tokens (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    used_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reset_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_reset_expiry (expires_at)
) ENGINE=InnoDB;

-- Categories from the current frontend dataset

INSERT INTO categories (id,name) VALUES (1,'Agriculture');
INSERT INTO categories (id,name) VALUES (2,'Education');
INSERT INTO categories (id,name) VALUES (3,'Employment');
INSERT INTO categories (id,name) VALUES (4,'Business');
INSERT INTO categories (id,name) VALUES (5,'Skill Development');
INSERT INTO categories (id,name) VALUES (6,'Healthcare');
INSERT INTO categories (id,name) VALUES (7,'Housing');
INSERT INTO categories (id,name) VALUES (8,'Women & Child');
INSERT INTO categories (id,name) VALUES (9,'Senior Citizens');
INSERT INTO categories (id,name) VALUES (10,'Disability Support');

-- 28 schemes from SCHEMES_DATA

INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('pm-kisan', 'pm-kisan-samman-nidhi', 'PM-KISAN (Pradhan Mantri Kisan Samman Nidhi)', 1, '🌾', 'Department of Agriculture & Farmers Welfare', 'Ministry of Agriculture and Farmers Welfare', 'Direct income support of ₹6,000 per year in three equal installments to landholding farmer families across India.', 'Pradhan Mantri Kisan Samman Nidhi (PM-KISAN) is a central sector scheme with 100% funding from the Government of India. It aims to augment the income of all landholding farmer families to enable them to procure agricultural inputs such as seeds, fertilizers, and equipment, and to support other domestic needs.', '₹6,000 / year (₹2,000 every 4 months directly via DBT)', 'https://pmkisan.gov.in/', 'PM-KISAN Portal', 'Open Throughout The Year', 18, 100, 1000000, 0, 0, 1);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('pmfby', 'pm-fasal-bima-yojana', 'PM Fasal Bima Yojana (PMFBY)', 1, '🌱', 'Department of Agriculture & Farmers Welfare', 'Ministry of Agriculture and Farmers Welfare', 'Comprehensive low-premium crop insurance against natural calamities, pests, droughts, floods, and unseasonal rainfall.', 'PMFBY provides comprehensive crop insurance from pre-sowing to post-harvest against non-preventable natural risks. Farmers pay a uniform minimal premium of only 2% for Kharif crops, 1.5% for Rabi crops, and 5% for annual commercial/horticultural crops, with the remaining premium heavily subsidized by the government.', 'Up to 100% Crop Loss Compensation at 1.5% - 2% Premium', 'https://pmfby.gov.in/', 'PMFBY National Crop Insurance Portal', 'Seasonal (July 31 for Kharif / Dec 31 for Rabi)', 18, 100, 99999999, 0, 0, 1);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('kcc', 'kisan-credit-card', 'Kisan Credit Card (KCC) Scheme', 1, '💳', 'Department of Financial Services / NABARD', 'Ministry of Finance & Agriculture', 'Adequate and timely institutional credit up to ₹3 Lakh for cultivation, post-harvest expenses, and allied dairy/fisheries.', 'The Kisan Credit Card scheme provides simple, single-window credit to farmers for their cultivation needs, purchase of seeds, fertilizers, pesticides, and allied activities such as animal husbandry and fisheries at an effective concessional interest rate of only 4% per annum upon timely repayment.', 'Concessional Credit up to ₹3 Lakh @ 4% Interest Rate', 'https://agricoop.nic.in/', 'Department of Agriculture & Farmers Welfare', 'Open Throughout The Year', 18, 75, 99999999, 0, 0, 1);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('pm-kusum', 'pm-kusum-solar-pump', 'PM-KUSUM (Pradhan Mantri Kisan Urja Suraksha)', 1, '☀️', 'Ministry of New and Renewable Energy', 'Ministry of New and Renewable Energy (MNRE)', 'Up to 60% government subsidy to install standalone off-grid and grid-connected solar agricultural water pumps.', 'PM-KUSUM empowers farmers to generate solar energy on their barren or cultivable land, replace diesel-powered water pumps with solar pumps, and sell surplus clean electricity back to state power DISCOMs to earn extra annual income.', '60% Solar Pump Subsidy + Clean Power Income', 'https://pmkusum.mnre.gov.in/', 'PM-KUSUM National Portal', 'Rolling State Allotment', 18, 80, 99999999, 0, 0, 1);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('pmmsy', 'pm-matsya-sampada-yojana', 'PM Matsya Sampada Yojana (PMMSY)', 1, '🐟', 'Department of Fisheries', 'Ministry of Fisheries, Animal Husbandry and Dairying', 'Up to 60% financial assistance for setting up fish farms, hatcheries, biofloc systems, and cold storage units.', 'PMMSY is a flagship scheme designed to address critical gaps in fish production, productivity, post-harvest infrastructure, and modernization across coastal and inland states. Subsidies reach up to 60% for SC, ST, and Women beneficiaries, and 40% for General categories.', '40% - 60% Capital Subsidy for Aquaculture & Fisheries', 'https://pmmsy.dof.gov.in/', 'PMMSY Official Portal', 'Open Throughout The Year', 18, 70, 1000000, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('post-matric-scholarship', 'post-matric-scholarship-sc-st-obc', 'Post-Matric Scholarship for SC/ST/OBC Students', 2, '🎓', 'Department of Social Justice and Empowerment', 'Ministry of Social Justice and Empowerment', 'Full tuition fee reimbursement and maintenance allowance for higher education after Class 10.', 'This flagship centrally sponsored scholarship supports Scheduled Caste, Scheduled Tribe, and Other Backward Class students pursuing post-matriculation courses (Class 11, 12, ITI, Diploma, Undergraduate, Postgraduate, and Professional degrees) with complete tuition reimbursement and monthly maintenance stipends.', '100% Tuition Fee Waiver + Up to ₹20,000/year Allowance', 'https://scholarships.gov.in/', 'National Scholarship Portal (NSP)', '31st October (Annual)', 15, 35, 250000, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('csss-scholarship', 'central-sector-scholarship-college', 'Central Sector Scheme of Scholarship for College Students', 2, '📚', 'Department of Higher Education', 'Ministry of Education', 'Merit-cum-means scholarship of ₹12,000 to ₹20,000 per year for students in top 20th percentile of Class 12.', 'The Central Sector Scheme of Scholarship for College and University Students aims to provide financial assistance to meritorious students from low-income families to meet day-to-day expenses while pursuing regular undergraduate and postgraduate courses in recognized colleges/universities across India.', '₹12,000/yr (UG) & ₹20,000/yr (PG) Merit Financial Aid', 'https://scholarships.gov.in/', 'National Scholarship Portal (NSP)', '30th November (Annual)', 17, 25, 450000, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('aicte-pragati', 'aicte-pragati-scholarship-girls', 'AICTE Pragati Scholarship Scheme for Girls', 2, '👩‍🎓', 'All India Council for Technical Education', 'Ministry of Education', '₹50,000 per year grant to support female students pursuing technical degree or diploma courses.', 'AICTE Pragati Scholarship is a pioneering scheme aimed at providing assistance to female students to empower them to pursue technical education (B.Tech, B.E., B.Arch, or Polytechnic Diploma). Up to two girls per family are eligible for ₹50,000 annual aid.', '₹50,000 per year towards tuition & laptop/books', 'https://www.aicte-india.org/', 'AICTE / NSP Portal', '31st December (Annual)', 16, 28, 800000, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('begum-hazrat-mahal', 'begum-hazrat-mahal-scholarship', 'Begum Hazrat Mahal National Scholarship', 2, '🧕', 'Maulana Azad Education Foundation', 'Ministry of Minority Affairs', 'Direct financial scholarship for meritorious minority schoolgirl students studying in Classes 9 to 12.', 'This scholarship encourages minority girl students belonging to Muslim, Christian, Sikh, Buddhist, Jain, and Parsi communities who have secured at least 50% marks in the aggregate in previous exams to continue their schooling and avoid dropout.', '₹6,000 (Class 9-10) to ₹12,000 (Class 11-12) Stipend', 'https://scholarships.gov.in/', 'National Scholarship Portal (NSP)', '31st October (Annual)', 13, 20, 200000, 0, 1, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('pm-svanidhi', 'pm-svanidhi-scheme', 'PM SVANidhi (Street Vendor''s AtmaNirbhar Nidhi)', 3, '🛒', 'Ministry of Housing and Urban Affairs', 'Ministry of Housing and Urban Affairs (MoHUA)', 'Collateral-free micro-credit working capital loans from ₹10,000 up to ₹50,000 with 7% interest subsidy.', 'PM SVANidhi is a special micro-credit facility for urban and semi-urban street vendors and hawkers to resume their livelihoods. It offers an initial loan of ₹10,000, which increases to ₹20,000 and ₹50,000 on timely repayments, along with digital cashback incentives up to ₹1,200 annually.', 'Collateral-Free Loan up to ₹50,000 + 7% Interest Subsidy', 'https://pmsvanidhi.mohua.gov.in/', 'PM SVANidhi Official Portal', 'Open Throughout The Year', 18, 65, 500000, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('pm-mudra', 'pm-mudra-yojana', 'Pradhan Mantri MUDRA Yojana (PMMY)', 4, '🏪', 'Department of Financial Services', 'Ministry of Finance', 'Collateral-free institutional loans up to ₹10 Lakhs for micro and small enterprises under Shishu, Kishore, and Tarun.', 'PMMY enables non-corporate, non-farm small/micro enterprises to access credit from commercial banks, RRBs, Small Finance Banks, and NBFCs. The scheme categorizes loans into Shishu (up to ₹50,000), Kishore (₹50,000 to ₹5 Lakh), and Tarun (₹5 Lakh to ₹10 Lakh).', 'Collateral-Free Business Loan up to ₹10 Lakhs', 'https://www.mudra.org.in/', 'MUDRA Official Portal', 'Open Throughout The Year', 18, 65, 99999999, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('stand-up-india', 'stand-up-india-scheme', 'Stand-Up India Scheme', 4, '🚀', 'Department of Financial Services / SIDBI', 'Ministry of Finance', 'Bank loans between ₹10 Lakh and ₹1 Crore to Scheduled Caste, Scheduled Tribe, and Women entrepreneurs for greenfield ventures.', 'Stand-Up India facilitates bank loans between ₹10 Lakh and ₹1 Crore to at least one SC or ST borrower and at least one woman borrower per bank branch for setting up a greenfield enterprise in manufacturing, services, agri-allied activities, or the trading sector.', '₹10 Lakh to ₹1 Crore Bank Loan for SC/ST & Women', 'https://www.standupmitra.in/', 'Stand-Up Mitra Portal', 'Open Throughout The Year', 18, 65, 99999999, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('pmegp', 'pmegp-subsidy-scheme', 'Prime Minister''s Employment Generation Programme (PMEGP)', 4, '🏭', 'Khadi and Village Industries Commission (KVIC)', 'Ministry of Micro, Small and Medium Enterprises (MSME)', 'Credit-linked capital subsidy of up to 35% on project costs up to ₹50 Lakh for manufacturing and ₹20 Lakh for services.', 'PMEGP is a major credit-linked subsidy program aimed at generating self-employment opportunities through establishment of micro-enterprises in non-farm sectors. Beneficiaries contribute only 5-10% margin money, while the government provides up to 35% subsidy.', 'Up to 35% Government Subsidy on Loans up to ₹50 Lakh', 'https://www.kviconline.gov.in/pmegpeportal/', 'KVIC PMEGP Portal', 'Open Throughout The Year', 18, 65, 99999999, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('pm-vishwakarma', 'pm-vishwakarma-yojana', 'PM Vishwakarma Scheme', 5, '🛠️', 'Ministry of MSME & Skill Development', 'Ministry of MSME & Skill Development', '₹15,000 modern toolkit incentive, certified skill training with ₹500/day stipend, and subsidized loans up to ₹3 Lakh @ 5%.', 'PM Vishwakarma provides holistic end-to-end support to traditional artisans and craftspeople working across 18 traditional trades (Carpenters, Blacksmiths, Potters, Sculptors, Cobblers, Tailors, Masons, etc.). It offers recognition via Vishwakarma ID, modern tools grant, and collateral-free enterprise credit.', '₹15,000 Free Toolkit Grant + ₹3 Lakh Loan @ 5% Concessional Interest', 'https://pmvishwakarma.gov.in/', 'PM Vishwakarma Portal', 'Open Throughout The Year', 18, 70, 600000, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('pmkvy', 'pmkvy-skill-development', 'Pradhan Mantri Kaushal Vikas Yojana (PMKVY 4.0)', 5, '⚙️', 'National Skill Development Corporation (NSDC)', 'Ministry of Skill Development and Entrepreneurship', 'Free industry-certified vocational training in modern job roles with monetary reward, toolkit aid, and placement support.', 'PMKVY 4.0 focuses on on-demand industry skilling including futuristic skills such as Coding, AI, Robotics, Mechatronics, IoT, 3D Printing, Drones, and Green Hydrogen. Training is 100% free with government assessment and recognized NSDC certification.', '100% Free Government Skill Certification + Placement Support', 'https://www.pmkvyofficial.org/', 'Skill India Digital Hub', 'Open Throughout The Year', 15, 45, 99999999, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('naps', 'national-apprenticeship-promotion-scheme', 'National Apprenticeship Promotion Scheme (NAPS)', 5, '👨‍🔧', 'Directorate General of Training (DGT)', 'Ministry of Skill Development and Entrepreneurship', 'Paid industrial on-the-job training with government co-funded stipend up to ₹1,500/month.', 'NAPS connects youth with top private and public industrial enterprises for paid practical apprenticeships. The Government reimburses 25% of the prescribed monthly stipend (up to ₹1,500 per month) directly to the apprentice via DBT.', 'Direct Monthly Government Stipend Support + Industry Experience', 'https://www.apprenticeshipindia.gov.in/', 'Apprenticeship India Portal', 'Open Throughout The Year', 16, 35, 99999999, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('pm-jay', 'ayushman-bharat-pmjay', 'Ayushman Bharat PM-JAY', 6, '🏥', 'National Health Authority (NHA)', 'Ministry of Health and Family Welfare', 'Cashless free health insurance cover of ₹5 Lakh per family per year for secondary and tertiary hospital care.', 'Ayushman Bharat Pradhan Mantri Jan Arogya Yojana (PM-JAY) is the world’s largest government-funded health assurance scheme. It provides a health cover of ₹5,00,000 per family per year across over 27,000 empanelled public and private hospitals nationwide, covering all pre-existing conditions from Day 1.', '₹5,00,000 / Year Free Cashless Hospital Treatment', 'https://pmjay.gov.in/', 'National Health Authority Portal', 'Open Throughout The Year', 0, 100, 250000, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('pmay-u', 'pmay-urban-housing', 'Pradhan Mantri Awas Yojana - Urban (PMAY-U)', 7, '🏢', 'Ministry of Housing and Urban Affairs', 'Ministry of Housing and Urban Affairs', 'Up to ₹2.67 Lakh upfront interest subsidy on home loans for building, purchasing, or renovating urban houses.', 'PMAY-U addresses urban housing shortage among EWS, LIG, and MIG categories. Under the Credit Linked Subsidy Scheme (CLSS) and Beneficiary Led Construction (BLC), eligible urban families receive significant upfront central subsidies to ensure a pucca house with clean tap water, toilet, and electricity.', 'Up to ₹2.67 Lakh Upfront Home Loan Interest Subsidy', 'https://pmay-urban.gov.in/', 'PMAY Urban Official Portal', 'Open Throughout The Year', 18, 70, 1000000, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('pmay-g', 'pmay-gramin-housing', 'Pradhan Mantri Awas Yojana - Gramin (PMAY-G)', 7, '🏡', 'Department of Rural Development', 'Ministry of Rural Development', 'Direct financial assistance of ₹1.20 Lakh to ₹1.30 Lakh for rural homeless families to construct a pucca house.', 'PMAY-G aims to provide a pucca house with basic amenities to all rural families living in kutcha or dilapidated houses. Beneficiaries are identified using SECC data and Gram Sabha verification, receiving funds directly in installments linked to geotagged construction progress.', '₹1,20,000 - ₹1,30,000 Direct Construction Grant', 'https://pmayg.nic.in/', 'PMAY Gramin Portal', 'Open Throughout The Year', 18, 100, 150000, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('pm-ujjwala', 'pm-ujjwala-lpg-scheme', 'Pradhan Mantri Ujjwala Yojana (PMUY 2.0)', 8, '🔥', 'Ministry of Petroleum and Natural Gas', 'Ministry of Petroleum and Natural Gas', 'Free deposit-free LPG gas connection with first cylinder refill and gas stove provided free to adult women of poor households.', 'Ujjwala 2.0 provides clean cooking fuel to rural and deprived women who previously used hazardous fossil fuels. It offers a free LPG connection with no security deposit, along with a free first cylinder and hotplate stove, plus an ongoing ₹300 subsidy per refill cylinder.', '100% Free LPG Gas Connection + Free Stove & First Refill', 'https://www.pmuy.gov.in/', 'PM Ujjwala Official Portal', 'Open Throughout The Year', 18, 90, 250000, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('ssy', 'sukanya-samriddhi-yojana', 'Sukanya Samriddhi Yojana (SSY)', 8, '👧', 'Department of Economic Affairs / India Post', 'Ministry of Finance & Women and Child Development', 'High-interest sovereign savings scheme offering 8.2% tax-free returns for the higher education and marriage of the girl child.', 'Sukanya Samriddhi Yojana is a government-backed small savings scheme under "Beti Bachao, Beti Padhao". It can be opened for any girl child from birth up to 10 years of age with a minimum deposit of only ₹250 per year, featuring triple tax exemption (EEE) under Section 80C.', '8.2% Sovereign Annual Interest + 100% Triple Tax Exemption', 'https://www.indiapost.gov.in/', 'India Post Portal', 'Open Throughout The Year', 0, 10, 99999999, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('pmmvy', 'pm-matru-vandana-yojana', 'Pradhan Mantri Matru Vandana Yojana (PMMVY)', 8, '🤰', 'Ministry of Women and Child Development', 'Ministry of Women and Child Development (MoWCD)', 'Maternity cash benefit of ₹5,000 to ₹6,000 for pregnant women and lactating mothers for improved health and nutrition.', 'PMMVY provides partial wage compensation and nutritional cash incentives directly into the bank accounts of pregnant women and lactating mothers. For the first child, ₹5,000 is provided in two installments; for a second girl child, an incentive of ₹6,000 is provided in a single installment.', '₹5,000 - ₹6,000 Direct Cash Transfer for Mothers', 'https://pmmvy.wcd.gov.in/', 'PMMVY Official Portal', 'Within 570 days of pregnancy', 19, 45, 800000, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('lakhpati-didi', 'lakhpati-didi-initiative', 'Lakhpati Didi Initiative', 8, '💎', 'Deendayal Antyodaya Yojana - NRLM', 'Ministry of Rural Development', 'Empowering women in Self-Help Groups (SHGs) with micro-credit, business skills, and market access to earn ₹1 Lakh+ annually.', 'The Lakhpati Didi initiative aims to enable 3 Crore rural women in Self-Help Groups to earn a sustainable annual income of at least ₹1,00,000. Beneficiaries receive entrepreneurship training, drone piloting skills (Drone Didi), digital financial tools, and easy credit linkages.', 'SHG Micro-Credit Linkage + Training to Earn ₹1 Lakh+/Year', 'https://aajeevika.gov.in/', 'DAY-NRLM Portal', 'Open Throughout The Year', 18, 60, 300000, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('apy', 'atal-pension-yojana', 'Atal Pension Yojana (APY)', 9, '👴', 'Pension Fund Regulatory and Development Authority (PFRDA)', 'Ministry of Finance', 'Government-guaranteed monthly pension of ₹1,000 to ₹5,000 per month from age 60 for unorganized sector workers.', 'Atal Pension Yojana is a flagship social security scheme open to all Indian citizens aged 18 to 40. Under APY, subscribers receive a guaranteed monthly pension of ₹1,000, ₹2,000, ₹3,000, ₹4,000, or ₹5,000 from the age of 60 years based on nominal monthly contributions.', 'Guaranteed Monthly Pension of ₹1,000 to ₹5,000 for Life', 'https://www.npscra.nsdl.co.in/scheme-details.php', 'PFRDA / Protean Portal', 'Open Throughout The Year', 18, 40, 99999999, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('nsap-oap', 'nsap-indira-gandhi-old-age-pension', 'National Social Assistance Programme (NSAP - Old Age Pension)', 9, '👵', 'Ministry of Rural Development', 'Ministry of Rural Development', 'Monthly social security non-contributory pension for elderly citizens living below the poverty line.', 'The Indira Gandhi National Old Age Pension Scheme (IGNOAPS) provides monthly non-contributory pensions to senior citizens aged 60 and above belonging to Below Poverty Line (BPL) households, co-funded by the Central and respective State governments.', 'Monthly Direct Pension of ₹500 to ₹2,500 via DBT', 'https://nsap.nic.in/', 'NSAP National Portal', 'Open Throughout The Year', 60, 100, 100000, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('rvy', 'rashtriya-vayoshri-yojana', 'Rashtriya Vayoshri Yojana (RVY)', 9, '🦯', 'Department of Social Justice and Empowerment', 'Ministry of Social Justice and Empowerment', 'Free physical assisted-living aids and assistive devices for senior citizens with age-related disabilities or infirmities.', 'Rashtriya Vayoshri Yojana provides free assistive devices to senior citizens belonging to the BPL category or earning under ₹15,000 per month who suffer from age-related disabilities such as low vision, hearing impairment, tooth loss, or locomotor issues.', '100% Free Wheelchairs, Hearing Aids, Dentures & Glasses', 'https://socialjustice.gov.in/', 'ALIMCO / Social Justice Portal', 'Open Throughout The Year', 60, 100, 180000, 0, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('adip-disability', 'adip-scheme-disabled-persons', 'ADIP Scheme (Assistance to Disabled Persons)', 10, '♿', 'Department of Empowerment of Persons with Disabilities', 'Ministry of Social Justice and Empowerment', 'Free sophisticated aids, motorized tricycles, braille kits, hearing implants, and smart canes for persons with disabilities.', 'The ADIP Scheme assists needy persons with disabilities in procuring durable, sophisticated, and scientifically manufactured aids and appliances to promote their physical, social, and psychological rehabilitation and enhance their economic potential.', '100% Free Motorized Tricycles, Hearing Implants & Braille Kits', 'https://alimco.in/', 'ALIMCO Official Portal', 'Open Throughout The Year', 0, 100, 250000, 1, 0, 0);
INSERT INTO schemes (scheme_code,slug,name,category_id,icon,department,ministry,short_description,detailed_description,benefits_summary,official_link,portal_name,deadline,min_age,max_age,income_limit,disability_required,minority_required,farmer_only) VALUES ('ndfdc-loans', 'ndfdc-disability-concessional-loans', 'NDFDC Concessional Loans for Divyangjan', 10, '💼', 'National Divyangjan Finance and Development Corporation', 'Ministry of Social Justice and Empowerment', 'Concessional interest rate business and education loans from ₹50,000 up to ₹25 Lakhs for persons with disabilities.', 'NDFDC provides concessional finance to Divyangjan (persons with disability of 40% or more) for setting up self-employment ventures, pursuing professional higher education, or purchasing adapted commercial vehicles at concessional interest rates of 4% to 8% p.a.', 'Concessional Business Loans up to ₹25 Lakh @ 4% - 8% Interest', 'https://www.nhfdc.nic.in/', 'NDFDC Portal', 'Open Throughout The Year', 18, 65, 99999999, 1, 0, 0);

INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kisan'),'occupation','IN',CAST('["Farmer", "Self Employed"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kisan'),'age','>=',18,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kisan'),'age','<=',100,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kisan'),'annual_family_income','<=',1000000,20,1,'Maximum annual family income');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kisan'),'occupation','IN',CAST('["Farmer"]' AS JSON),5,1,'Farmer-only requirement');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmfby'),'occupation','IN',CAST('["Farmer"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmfby'),'age','>=',18,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmfby'),'age','<=',100,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmfby'),'occupation','IN',CAST('["Farmer"]' AS JSON),5,1,'Farmer-only requirement');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='kcc'),'occupation','IN',CAST('["Farmer", "Self Employed", "Worker"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='kcc'),'age','>=',18,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='kcc'),'age','<=',75,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='kcc'),'occupation','IN',CAST('["Farmer"]' AS JSON),5,1,'Farmer-only requirement');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kusum'),'occupation','IN',CAST('["Farmer", "Self Employed"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kusum'),'age','>=',18,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kusum'),'age','<=',80,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kusum'),'occupation','IN',CAST('["Farmer"]' AS JSON),5,1,'Farmer-only requirement');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmsy'),'occupation','IN',CAST('["Farmer", "Worker", "Self Employed"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmsy'),'age','>=',18,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmsy'),'age','<=',70,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmsy'),'annual_family_income','<=',1000000,20,1,'Maximum annual family income');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),'occupation','IN',CAST('["Student", "Job Seeker"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),'age','>=',15,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),'age','<=',35,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),'annual_family_income','<=',250000,20,1,'Maximum annual family income');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),'education_level','IN',CAST('["School 10th/12th", "Diploma/ITI", "Undergraduate", "Postgraduate", "PhD"]' AS JSON),5,1,'Education eligibility');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='csss-scholarship'),'occupation','IN',CAST('["Student"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='csss-scholarship'),'age','>=',17,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='csss-scholarship'),'age','<=',25,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='csss-scholarship'),'annual_family_income','<=',450000,20,1,'Maximum annual family income');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='csss-scholarship'),'education_level','IN',CAST('["Undergraduate", "Postgraduate"]' AS JSON),5,1,'Education eligibility');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),'occupation','IN',CAST('["Student"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),'age','>=',16,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),'age','<=',28,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),'annual_family_income','<=',800000,20,1,'Maximum annual family income');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),'gender','IN',CAST('["Female"]' AS JSON),5,1,'Gender suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),'education_level','IN',CAST('["Diploma/ITI", "Undergraduate"]' AS JSON),5,1,'Education eligibility');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),'occupation','IN',CAST('["Student"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),'age','>=',13,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),'age','<=',20,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),'annual_family_income','<=',200000,20,1,'Maximum annual family income');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),'gender','IN',CAST('["Female"]' AS JSON),5,1,'Gender suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),'education_level','IN',CAST('["School 10th/12th"]' AS JSON),2.5,1,'Education eligibility');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_text,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),'is_minority','BOOLEAN','true',2.5,1,'Minority requirement');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-svanidhi'),'occupation','IN',CAST('["Worker", "Self Employed", "Other"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-svanidhi'),'age','>=',18,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-svanidhi'),'age','<=',65,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-svanidhi'),'annual_family_income','<=',500000,20,1,'Maximum annual family income');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-mudra'),'occupation','IN',CAST('["Business Owner", "Self Employed", "Job Seeker", "Homemaker"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-mudra'),'age','>=',18,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-mudra'),'age','<=',65,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='stand-up-india'),'occupation','IN',CAST('["Business Owner", "Self Employed", "Homemaker"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='stand-up-india'),'age','>=',18,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='stand-up-india'),'age','<=',65,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='stand-up-india'),'gender','IN',CAST('["Female", "Male"]' AS JSON),5,1,'Gender suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmegp'),'occupation','IN',CAST('["Business Owner", "Job Seeker", "Self Employed"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmegp'),'age','>=',18,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmegp'),'age','<=',65,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmegp'),'education_level','IN',CAST('["School 10th/12th", "Diploma/ITI", "Undergraduate", "Postgraduate", "PhD"]' AS JSON),5,1,'Education eligibility');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-vishwakarma'),'occupation','IN',CAST('["Worker", "Self Employed", "Job Seeker", "Other"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-vishwakarma'),'age','>=',18,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-vishwakarma'),'age','<=',70,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-vishwakarma'),'annual_family_income','<=',600000,20,1,'Maximum annual family income');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmkvy'),'occupation','IN',CAST('["Job Seeker", "Student", "Worker", "Other"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmkvy'),'age','>=',15,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmkvy'),'age','<=',45,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='naps'),'occupation','IN',CAST('["Student", "Job Seeker", "Worker"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='naps'),'age','>=',16,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='naps'),'age','<=',35,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='naps'),'education_level','IN',CAST('["Diploma/ITI", "Undergraduate", "School 10th/12th"]' AS JSON),5,1,'Education eligibility');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-jay'),'age','>=',0,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-jay'),'age','<=',100,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-jay'),'annual_family_income','<=',250000,20,1,'Maximum annual family income');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-u'),'age','>=',18,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-u'),'age','<=',70,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-u'),'annual_family_income','<=',1000000,20,1,'Maximum annual family income');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-g'),'occupation','IN',CAST('["Worker", "Farmer", "Homemaker", "Other"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-g'),'age','>=',18,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-g'),'age','<=',100,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-g'),'annual_family_income','<=',150000,20,1,'Maximum annual family income');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-ujjwala'),'occupation','IN',CAST('["Homemaker", "Worker", "Other"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-ujjwala'),'age','>=',18,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-ujjwala'),'age','<=',90,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-ujjwala'),'annual_family_income','<=',250000,20,1,'Maximum annual family income');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-ujjwala'),'gender','IN',CAST('["Female"]' AS JSON),5,1,'Gender suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='ssy'),'age','>=',0,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='ssy'),'age','<=',10,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='ssy'),'gender','IN',CAST('["Female"]' AS JSON),5,1,'Gender suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmvy'),'occupation','IN',CAST('["Homemaker", "Worker", "Self Employed", "Other"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmvy'),'age','>=',19,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmvy'),'age','<=',45,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmvy'),'annual_family_income','<=',800000,20,1,'Maximum annual family income');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmvy'),'gender','IN',CAST('["Female"]' AS JSON),5,1,'Gender suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='lakhpati-didi'),'occupation','IN',CAST('["Homemaker", "Self Employed", "Worker"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='lakhpati-didi'),'age','>=',18,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='lakhpati-didi'),'age','<=',60,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='lakhpati-didi'),'annual_family_income','<=',300000,20,1,'Maximum annual family income');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='lakhpati-didi'),'gender','IN',CAST('["Female"]' AS JSON),5,1,'Gender suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='apy'),'occupation','IN',CAST('["Worker", "Self Employed", "Farmer", "Homemaker", "Other"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='apy'),'age','>=',18,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='apy'),'age','<=',40,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='nsap-oap'),'occupation','IN',CAST('["Senior Citizen", "Other"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='nsap-oap'),'age','>=',60,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='nsap-oap'),'age','<=',100,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='nsap-oap'),'annual_family_income','<=',100000,20,1,'Maximum annual family income');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='rvy'),'occupation','IN',CAST('["Senior Citizen", "Other"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='rvy'),'age','>=',60,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='rvy'),'age','<=',100,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='rvy'),'annual_family_income','<=',180000,20,1,'Maximum annual family income');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='adip-disability'),'age','>=',0,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='adip-disability'),'age','<=',100,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='adip-disability'),'annual_family_income','<=',250000,20,1,'Maximum annual family income');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_text,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='adip-disability'),'has_disability','BOOLEAN','true',5,1,'Disability requirement');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_json,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='ndfdc-loans'),'occupation','IN',CAST('["Job Seeker", "Business Owner", "Self Employed", "Student"]' AS JSON),40,1,'Occupation suitability');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='ndfdc-loans'),'age','>=',18,7.5,1,'Minimum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_number,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='ndfdc-loans'),'age','<=',65,7.5,1,'Maximum age');
INSERT INTO scheme_eligibility_rules (scheme_id,field_name,operator,value_text,points,is_mandatory,description) VALUES ((SELECT id FROM schemes WHERE scheme_code='ndfdc-loans'),'has_disability','BOOLEAN','true',5,1,'Disability requirement');

INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kisan'),'Benefit 1','₹6,000 per year paid in three equal 4-monthly installments of ₹2,000.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kisan'),'Benefit 2','Direct Benefit Transfer (DBT) directly into Aadhaar-seeded bank accounts.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kisan'),'Benefit 3','Cashless and hassle-free central income guarantee for rural agricultural families.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kisan'),'Aadhaar Card (Aadhaar linked with Mobile)',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kisan'),'Landholding Record / RoR / Khasra-Khatauni',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kisan'),'Active Bank Passbook (Aadhaar Seeded & NPCI Mapped)',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kisan'),'Citizenship Proof / Ration Card',1,4);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kisan'),1,'Visit the official portal pmkisan.gov.in or your nearest Common Services Centre (CSC).');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kisan'),2,'Click on "New Farmer Registration" and verify your identity using your Aadhaar number.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kisan'),3,'Select your state, district, sub-district, block, and village, and enter your land survey details.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kisan'),4,'Complete mandatory e-KYC via Aadhaar OTP or biometric fingerprint scan at any CSC.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kisan'),5,'Submit the form to generate your Farmer Application Reference Number.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmfby'),'Benefit 1','Full sum insured payout for complete crop failure due to drought, floods, hailstorms, or cyclones.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmfby'),'Benefit 2','Post-harvest loss coverage for up to 14 days for crops kept in ‘cut and spread’ condition.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmfby'),'Benefit 3','Localized calamity assistance for landslides, hailstorms, and inundation within 72 hours of intimation.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmfby'),'Aadhaar Card',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmfby'),'Land Possession Certificate (LPC) or Record of Rights (RoR)',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmfby'),'Sowing Certificate / Declaration issued by Patwari or Village Officer',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmfby'),'Cancelled Cheque / Bank Passbook Copy',1,4);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmfby'),'Tenant Farmer Agreement (if applicable)',1,5);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmfby'),1,'Access pmfby.gov.in or apply through your local bank branch / primary agriculture cooperative.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmfby'),2,'Select your crop season (Kharif / Rabi), state, and district.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmfby'),3,'Upload your land title details and sowing certificate.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmfby'),4,'Pay the nominal farmer share premium online or at the bank counter.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmfby'),5,'Obtain your insurance policy certificate for tracking claim status.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='kcc'),'Benefit 1','Revolving cash credit with ATM-enabled RuPay Kisan Card for easy withdrawals.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='kcc'),'Benefit 2','No collateral required for loans up to ₹1.60 Lakh.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='kcc'),'Benefit 3','7% base interest rate with 3% prompt repayment incentive, reducing net interest to 4% p.a.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='kcc'),'Aadhaar Card / Voter ID Card',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='kcc'),'Land Records / Khatauni / Village Revenue Records',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='kcc'),'Declaration of crops sown and proposed acreage',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='kcc'),'PAN Card / Form 60',1,4);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='kcc'),'Passport size photographs',1,5);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='kcc'),1,'Download the 1-page KCC application form from any nationalized bank or agricoop.nic.in.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='kcc'),2,'Attach copies of your land records and Aadhaar card.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='kcc'),3,'Submit to your nearest public sector bank, regional rural bank, or cooperative society.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='kcc'),4,'Card approval and RuPay KCC card dispatch takes approximately 14 working days.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kusum'),'Benefit 1','30% Central Subsidy + 30% State Subsidy for Standalone Solar Pumps (Farmer pays only 40%, with bank loan options up to 30%).',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kusum'),'Benefit 2','Zero recurring diesel fuel costs for irrigation.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kusum'),'Benefit 3','Opportunity to sell surplus solar electricity to DISCOMs under Component-A.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kusum'),'Aadhaar Card',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kusum'),'Land Revenue Records / Jamabandi',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kusum'),'Bank Account Details',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kusum'),'Electricity Bill / No Objection Certificate from DISCOM (for grid solar)',1,4);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kusum'),1,'Visit the official state renewable energy agency portal or pmkusum.mnre.gov.in.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kusum'),2,'Register as an individual farmer or group of farmers.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kusum'),3,'Select pump capacity (3 HP, 5 HP, 7.5 HP) and pump vendor.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-kusum'),4,'Deposit farmer contribution (approx 10-20% upfront) upon allocation.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmsy'),'Benefit 1','Capital subsidies for freshwater fish farming, shrimp hatcheries, and Recirculatory Aquaculture Systems (RAS).',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmsy'),'Benefit 2','Assistance for purchasing motorized fishing vessels, deep-sea boats, and safety equipment.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmsy'),'Benefit 3','Free livelihood insurance coverage for active fishers.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmsy'),'Aadhaar Card',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmsy'),'Land / Pond Ownership or Minimum 7-Year Lease Agreement',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmsy'),'Bank Account Passbook',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmsy'),'Detailed Project Report (DPR) / Cost Estimation',1,4);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmsy'),'Caste / Category Certificate (for 60% affirmative subsidy)',1,5);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmsy'),1,'Visit pmmsy.dof.gov.in or submit your DPR to the District Fisheries Officer (DFO).');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmsy'),2,'Select beneficiary category and project type.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmsy'),3,'Scrutiny by District Level Committee and State Fisheries Department.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmsy'),4,'Sanction letter issued with phased DBT subsidy release.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),'Benefit 1','100% compulsory tuition and examination fee waiver for government and approved private universities.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),'Benefit 2','Monthly maintenance allowance ranging from ₹550 to ₹1,200 per month depending on degree level.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),'Benefit 3','Special allowance for hostel residents and disabled students.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),'Aadhaar Card',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),'Caste Certificate issued by Competent Authority (Tehsildar/SDM)',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),'Annual Family Income Certificate (< ₹2.5 Lakh)',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),'Previous Year Marksheet / Passing Certificate',1,4);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),'Current Academic Year Fee Receipt & College Bonafide Certificate',1,5);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),'Bank Account Passbook (Aadhaar linked)',1,6);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),1,'Visit the National Scholarship Portal (scholarships.gov.in) or state scholarship portal.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),2,'Create an NSP OTR (One Time Registration) using Aadhaar and mobile number.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),3,'Select "Post-Matric Scholarship" and enter academic roll number and college fee structure.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),4,'Upload scanned certificates and submit online.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='post-matric-scholarship'),5,'Institute Nodal Officer (INO) and District Nodal Officer (DNO) verify and release funds via PFMS.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='csss-scholarship'),'Benefit 1','₹12,000 per annum for the first 3 years of Undergraduate study.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='csss-scholarship'),'Benefit 2','₹20,000 per annum for Postgraduate study and 4th/5th year of integrated professional courses.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='csss-scholarship'),'Benefit 3','82,000 fresh scholarships awarded every year equally divided among boys and girls.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='csss-scholarship'),'Aadhaar Card',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='csss-scholarship'),'Class 12 Passing Certificate & Marksheet (Top 20th Percentile)',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='csss-scholarship'),'Annual Family Income Certificate (< ₹4.5 Lakhs)',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='csss-scholarship'),'College Admission Confirmation / Fee Receipt',1,4);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='csss-scholarship'),'Bank Account Passbook (Aadhaar seeded)',1,5);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='csss-scholarship'),1,'Apply online via the National Scholarship Portal at scholarships.gov.in.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='csss-scholarship'),2,'Verify candidate board roll number and year of passing Class 12.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='csss-scholarship'),3,'Provide bank account details and college affiliation code.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='csss-scholarship'),4,'Track your application status using NSP Application ID.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),'Benefit 1','₹50,000 per annum for every year of technical study (up to 4 years for Degree, 3 years for Diploma).',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),'Benefit 2','May be utilized towards tuition fee, purchase of laptop, software, books, and competitive exam fees.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),'Benefit 3','10,000 scholarships awarded annually across AICTE-approved institutions.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),'Aadhaar Card',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),'Class 10th and 12th / ITI Marksheet',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),'Annual Family Income Certificate (< ₹8 Lakhs p.a.)',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),'Admission Letter from AICTE-approved Technical College',1,4);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),'Tuition Fee Receipt for current academic year',1,5);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),'Parent Declaration regarding family children count',1,6);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),1,'Register on the National Scholarship Portal (NSP) under AICTE schemes.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),2,'Fill academic and bank credentials.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),3,'College verification followed by AICTE approval.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='aicte-pragati'),4,'Disbursement directly into Aadhaar-linked savings account via PFMS.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),'Benefit 1','₹6,000 per annum for Class 9 and 10 girl students.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),'Benefit 2','₹12,000 per annum for Class 11 and 12 girl students.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),'Benefit 3','100% direct bank transfer with zero deductions.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),'Aadhaar Card of Student',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),'Self-Declaration of Minority Community',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),'Annual Family Income Certificate (< ₹2 Lakhs)',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),'Previous Class Marksheet with at least 50% marks',1,4);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),'School Verification Bonafide Certificate',1,5);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),1,'Access scholarships.gov.in under Ministry of Minority Affairs section.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),2,'Fill student details and select school name from UDISE directory.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='begum-hazrat-mahal'),3,'Submit verification form signed by school headmaster/principal.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-svanidhi'),'Benefit 1','Tranche 1: ₹10,000 loan (1 year tenure); Tranche 2: ₹20,000 loan; Tranche 3: ₹50,000 loan.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-svanidhi'),'Benefit 2','7% interest subsidy credited directly to bank account on a quarterly basis.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-svanidhi'),'Benefit 3','Monthly digital transaction cashback incentives up to ₹100 per month (₹1,200 per year).',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-svanidhi'),'Aadhaar Card',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-svanidhi'),'Vending Certificate / Identity Card issued by Urban Local Body (ULB)',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-svanidhi'),'Letter of Recommendation (LoR) from Town Vending Committee (if ID is not available)',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-svanidhi'),'Bank Passbook Copy',1,4);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-svanidhi'),1,'Apply online at pmsvanidhi.mohua.gov.in or through any CSC / bank branch.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-svanidhi'),2,'Verify Aadhaar number with OTP and select your preferred lending institution.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-svanidhi'),3,'Lender sanctions loan within 7-10 days with direct credit into savings account.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-mudra'),'Benefit 1','Zero collateral or third-party guarantee required.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-mudra'),'Benefit 2','Shishu tier: Loans up to ₹50,000 for initial startup equipment & stock.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-mudra'),'Benefit 3','Kishore tier: Loans ₹50,000 to ₹5 Lakh for business expansion.',3);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-mudra'),'Benefit 4','Tarun tier: Loans ₹5 Lakh to ₹10 Lakh for mature scaling ventures.',4);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-mudra'),'Aadhaar Card / Voter ID',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-mudra'),'PAN Card',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-mudra'),'Proof of Business Address / Trade License / Udyam Registration',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-mudra'),'Bank Statement for past 6 months',1,4);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-mudra'),'Business Plan / Quotation of Machinery or Stock to be purchased',1,5);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-mudra'),1,'Visit the Udyamimitra portal (udyamimitra.in) or any commercial bank branch.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-mudra'),2,'Submit standard MUDRA application form with quotation of items to purchase.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-mudra'),3,'Bank evaluates business viability and disburses credit via MUDRA RuPay Debit Card.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='stand-up-india'),'Benefit 1','Composite loan covering both Term Loan and Working Capital needs.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='stand-up-india'),'Benefit 2','Government credit guarantee cover via NCGTC.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='stand-up-india'),'Benefit 3','Handholding support from SIDBI for pre-loan and post-loan guidance.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='stand-up-india'),'Aadhaar Card & PAN Card',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='stand-up-india'),'Caste Certificate (for SC/ST applicants)',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='stand-up-india'),'Comprehensive Project Feasibility Report (DPR)',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='stand-up-india'),'Udyam Registration Certificate',1,4);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='stand-up-india'),'Pollution Control Clearance / Municipal NOC (if applicable)',1,5);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='stand-up-india'),1,'Apply through the Stand-Up Mitra portal at standupmitra.in.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='stand-up-india'),2,'Connect with Lead District Managers (LDM) or preferred commercial bank branch.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='stand-up-india'),3,'Participate in credit committee evaluation and project sanction.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmegp'),'Benefit 1','Maximum project cost: ₹50 Lakh for manufacturing units, ₹20 Lakh for service enterprises.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmegp'),'Benefit 2','Urban subsidy: 15% (General) and 25% (Special Categories: SC/ST/OBC/Women/Ex-Servicemen).',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmegp'),'Benefit 3','Rural subsidy: 25% (General) and 35% (Special Categories).',3);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmegp'),'Benefit 4','Second loan up to ₹1 Crore with 15% subsidy for existing successful PMEGP units.',4);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmegp'),'Aadhaar Card and PAN Card',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmegp'),'Minimum 8th Pass Certificate (for projects >₹10L in manufacturing / >₹5L in services)',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmegp'),'Detailed Project Report (DPR) with financial cash flow analysis',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmegp'),'Special Category / Caste Certificate (for 25-35% subsidy rate)',1,4);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmegp'),'Rural Area Certificate issued by Gram Panchayat (if claiming rural subsidy)',1,5);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmegp'),1,'Submit online application on the KVIC e-portal at kviconline.gov.in.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmegp'),2,'Application is scrutinized by District Level Task Force Committee (DLTFC).');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmegp'),3,'Sanctioned file is forwarded to financing bank branch for disbursement.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmegp'),4,'Mandatory 5-10 days Entrepreneurship Development Programme (EDP) training.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-vishwakarma'),'Benefit 1','PM Vishwakarma Certificate and Digital Identity Card recognition.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-vishwakarma'),'Benefit 2','Basic training (5-7 days) and Advanced training (15 days) with a stipend of ₹500/day.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-vishwakarma'),'Benefit 3','₹15,000 e-voucher grant for purchasing modern professional toolkits.',3);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-vishwakarma'),'Benefit 4','Enterprise loans: 1st tranche up to ₹1 Lakh (18 months), 2nd tranche up to ₹2 Lakh (30 months) at 5% interest.',4);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-vishwakarma'),'Aadhaar Card and Aadhaar-linked Mobile Number',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-vishwakarma'),'Ration Card / Family Composition Details',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-vishwakarma'),'Bank Account Passbook Details',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-vishwakarma'),'Trade declaration of practicing one of 18 traditional craftsmanship trades',1,4);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-vishwakarma'),1,'Visit any Common Services Centre (CSC) with Aadhaar card and Ration card.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-vishwakarma'),2,'Complete biometric fingerprint verification and trade profile creation.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-vishwakarma'),3,'Stage 1 Gram Panchayat / Urban Local Body verification, followed by District Committee approval.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-vishwakarma'),4,'Receive digital PM Vishwakarma ID and toolkit e-voucher code on mobile.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmkvy'),'Benefit 1','Zero course fees for high-demand technical and service sector courses.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmkvy'),'Benefit 2','Accredited Government Skill India Certificate valid nationally and abroad.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmkvy'),'Benefit 3','Direct placement fairs (Rozgar Melas) and apprenticeship matching.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmkvy'),'Aadhaar Card / Voter ID',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmkvy'),'Educational Marksheet / School Leaving Certificate',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmkvy'),'Bank Account Details',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmkvy'),'Passport Size Photographs',1,4);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmkvy'),1,'Visit skillindiadigital.gov.in or nearest PMKVY Skill Training Centre.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmkvy'),2,'Enroll in your preferred course module (Short Term Training / Recognition of Prior Learning).');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmkvy'),3,'Complete hands-on classroom and lab training.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmkvy'),4,'Appear for assessment and download Skill India digital credential.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='naps'),'Benefit 1','Monthly stipend paid directly into your bank account during apprenticeship.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='naps'),'Benefit 2','Hands-on technical experience with leading manufacturing and IT companies.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='naps'),'Benefit 3','National Apprenticeship Certificate (NAC) upon completion.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='naps'),'Aadhaar Card',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='naps'),'Educational Certificate (10th/12th/ITI/Diploma/Degree)',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='naps'),'Bank Account Details (Aadhaar linked for DBT stipend)',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='naps'),'Updated Resume / Bio-data',1,4);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='naps'),1,'Register candidate profile on apprenticeshipindia.gov.in.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='naps'),2,'Search and apply for active apprenticeship vacancies across companies.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='naps'),3,'Sign digital apprenticeship contract online upon selection.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-jay'),'Benefit 1','₹5 Lakh cover per family per year with no restriction on family size, age, or gender.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-jay'),'Benefit 2','Covers 1,949 medical and surgical procedures including oncology, cardiology, neurosurgery, and intensive care.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-jay'),'Benefit 3','All medical examination, treatment, consultation, medicines, and post-hospitalization expenses (15 days) included.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-jay'),'Aadhaar Card',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-jay'),'Ration Card / NFSA Proof / SECC Database Match',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-jay'),'Active Mobile Number for e-KYC',1,3);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-jay'),1,'Check eligibility online at beneficiary.nha.gov.in using your mobile number or Ration card.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-jay'),2,'Complete instant e-KYC using Aadhaar OTP or facial recognition on the Ayushman App.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-jay'),3,'Download and print your PVC Ayushman Card for cashless hospital admission.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-u'),'Benefit 1','Interest subsidy of 6.5% for EWS/LIG loans up to ₹6 Lakh for a 20-year tenure.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-u'),'Benefit 2','Direct central financial grant of ₹1.5 Lakh for building a home on self-owned land under BLC.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-u'),'Benefit 3','Mandatory female ownership or co-ownership to promote women empowerment.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-u'),'Aadhaar Card of all family members',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-u'),'Income Certificate / Form 16 / Salary Slips',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-u'),'Bank Statement for past 6 months',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-u'),'Affidavit certifying that no family member owns a pucca house in India',1,4);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-u'),'Property Documents / Registered Agreement of Sale',1,5);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-u'),1,'Apply through your home lending bank (SBI, HDFC, PNB, etc.) or visit pmaymis.gov.in.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-u'),2,'Select "Citizen Assessment" and verify Aadhaar.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-u'),3,'Enter monthly household income and property details.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-u'),4,'Subsidy is credited directly into your loan account, reducing monthly EMI.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-g'),'Benefit 1','₹1,20,000 in plain areas and ₹1,30,000 in hilly/Himalayan states and difficult districts.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-g'),'Benefit 2','Additional ₹12,000 financial support for building a household toilet under Swachh Bharat Mission (Gramin).',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-g'),'Benefit 3','90 to 95 days of unskilled labor wages under MGNREGA (approx ₹20,000 extra).',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-g'),'Aadhaar Card',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-g'),'MGNREGA Job Card Number',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-g'),'Bank Account Passbook (Aadhaar linked)',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-g'),'Gram Sabha Selection Resolution / BPL Certificate',1,4);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-g'),1,'Beneficiary names are drawn from the Awaas+ rural priority list verified by Gram Sabha.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-g'),2,'Contact your Gram Panchayat Secretary or Block Development Officer (BDO).');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-g'),3,'Geo-tagged photographs of existing house and each construction stage uploaded on AwaasSoft.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmay-g'),4,'Direct installment release via PFMS upon physical inspection.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-ujjwala'),'Benefit 1','Zero deposit fee for cylinder, regulator, safety hose, and blue booklet.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-ujjwala'),'Benefit 2','First 14.2 kg LPG cylinder refill and double-burner hotplate gas stove completely free of charge.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-ujjwala'),'Benefit 3','Targeted subsidy of ₹300 per cylinder for up to 12 refills per year credited directly to bank account.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-ujjwala'),'Aadhaar Card of adult female applicant',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-ujjwala'),'Ration Card issued by State Government / 14-point declaration',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-ujjwala'),'Aadhaar of all adult family members residing in household',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-ujjwala'),'Bank Account Passbook Copy',1,4);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-ujjwala'),1,'Apply online at pmuy.gov.in or visit your nearest LPG distributor (Indane, BharatGas, HP Gas).');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-ujjwala'),2,'Submit 1-page Ujjwala 2.0 application form with ration card and Aadhaar copies.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-ujjwala'),3,'Distributor performs de-duplication check through NIC/OMC database.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pm-ujjwala'),4,'Collect your new gas connection and gas stove from the agency.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='ssy'),'Benefit 1','Guaranteed 8.2% annual interest compounded yearly (highest among government savings schemes).',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='ssy'),'Benefit 2','Complete tax exemption under Section 80C on deposit amount, accrued interest, and maturity withdrawal.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='ssy'),'Benefit 3','Partial withdrawal of up to 50% allowed for girl child higher education after she turns 18 or passes Class 10.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='ssy'),'Birth Certificate of Girl Child',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='ssy'),'Aadhaar Card and PAN Card of Parent / Legal Guardian',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='ssy'),'Proof of Residence of Parent/Guardian',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='ssy'),'Passport-size photographs of daughter and parent',1,4);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='ssy'),1,'Visit any Post Office branch or authorized public/private commercial bank (SBI, PNB, BoB, etc.).');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='ssy'),2,'Fill account opening Form SSA-1.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='ssy'),3,'Submit daughter birth certificate and guardian Aadhaar.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='ssy'),4,'Deposit initial amount (min ₹250) and collect official SSY Passbook.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmvy'),'Benefit 1','₹5,000 for first child upon early registration of pregnancy and institutional child immunization.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmvy'),'Benefit 2','₹6,000 lump sum for second child if the newborn is a girl child.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmvy'),'Benefit 3','Promotes institutional delivery and infant vaccination.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmvy'),'Aadhaar Card of Mother & Husband',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmvy'),'Mother and Child Protection (MCP) Card issued by Anganwadi / Health Centre',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmvy'),'Bank Account Passbook of Mother (Aadhaar seeded)',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmvy'),'Child Birth Registration Certificate',1,4);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmvy'),1,'Register at your local Anganwadi Centre (AWC) or visit pmmvy.wcd.gov.in.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmvy'),2,'Submit Form 1A with MCP card details within 570 days of Last Menstrual Period (LMP).');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='pmmvy'),3,'Payment is released directly via DBT upon completing health checkups.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='lakhpati-didi'),'Benefit 1','Access to Community Investment Funds and collateral-free bank loans through SHG federation.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='lakhpati-didi'),'Benefit 2','Specialized skill modules in organic farming, dairy, food processing, LED bulb making, and drone operations.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='lakhpati-didi'),'Benefit 3','E-commerce onboarding on GeM and ONDC portals for selling handmade rural products.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='lakhpati-didi'),'Aadhaar Card',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='lakhpati-didi'),'SHG Membership Proof / SHG Passbook Copy',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='lakhpati-didi'),'Bank Account Passbook (Aadhaar linked)',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='lakhpati-didi'),'Residence Certificate from Gram Panchayat',1,4);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='lakhpati-didi'),1,'Contact your village Gram Sangathan / Village Organization (VO) or Block Mission Management Unit (BMMU).');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='lakhpati-didi'),2,'Enroll in your Self Help Group livelihood plan.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='lakhpati-didi'),3,'Participate in block level vocational training and credit sanctioning.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='apy'),'Benefit 1','Sovereign guaranteed monthly pension backed by the Central Government.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='apy'),'Benefit 2','Upon demise of subscriber, pension continues to spouse for life; full pension corpus returned to nominee.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='apy'),'Benefit 3','Low monthly contribution: starting as low as ₹42/month for an 18-year-old for ₹1,000 monthly pension.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='apy'),'Aadhaar Card',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='apy'),'Active Savings Bank Account or Post Office Account',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='apy'),'Aadhaar-linked Mobile Number for auto-debit consent',1,3);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='apy'),1,'Visit the bank or post office branch where you hold your savings account, or enroll via NetBanking.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='apy'),2,'Fill out the APY subscriber registration form and choose pension amount (₹1k to ₹5k).');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='apy'),3,'Enable auto-debit authorization for monthly, quarterly, or half-yearly contributions.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='apy'),4,'Download Permanent Retirement Account Number (PRAN) e-card from npscra.nsdl.co.in.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='nsap-oap'),'Benefit 1','Direct monthly pension paid directly into the senior citizen’s bank or post office account.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='nsap-oap'),'Benefit 2','Central contribution supplemented by state government additions (totaling ₹500 to ₹2,500/month depending on state).',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='nsap-oap'),'Benefit 3','Higher pension rate for super-senior citizens aged 80 and above.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='nsap-oap'),'Aadhaar Card',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='nsap-oap'),'Age Proof (Voter ID / Birth Certificate / Matriculation Certificate)',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='nsap-oap'),'BPL Ration Card or Socio-Economic Caste Census (SECC) proof',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='nsap-oap'),'Bank Account Passbook (Aadhaar seeded)',1,4);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='nsap-oap'),1,'Apply online via nsap.nic.in or at the office of your local Block Development Officer (BDO) / Municipal Corporation.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='nsap-oap'),2,'Submit proof of age and BPL card copy.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='nsap-oap'),3,'Verification by Social Welfare Inspector and sanction by Sub-Divisional Magistrate (SDM).');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='rvy'),'Benefit 1','Free distribution of motorized tricycles, wheelchairs, walking sticks, and elbow crutches.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='rvy'),'Benefit 2','Advanced digital hearing aids, spectacles, tripod walking sticks, and dental dentures.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='rvy'),'Benefit 3','Organized through specialized district-level health assessment camps.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='rvy'),'Aadhaar Card / Senior Citizen Card',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='rvy'),'BPL Ration Card or Monthly Income Certificate (< ₹15,000/month)',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='rvy'),'Medical Disability or Impairment Certificate from Government Hospital Doctor',1,3);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='rvy'),1,'Register at ALIMCO assessment camps or through the District Social Welfare Officer (DSWO).');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='rvy'),2,'Undergo physical screening by a panel of government doctors.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='rvy'),3,'Receive customized assistive equipment at the public distribution ceremony.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='adip-disability'),'Benefit 1','Motorized tricycles (worth up to ₹42,000) provided free to severely locomotor-impaired individuals.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='adip-disability'),'Benefit 2','Cochlear implant surgery aid up to ₹6 Lakh for hearing-impaired children up to 5 years.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='adip-disability'),'Benefit 3','Smart canes, Daisy players, and screen-reading laptops for visually impaired beneficiaries.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='adip-disability'),'UDID Card (Unique Disability ID) or Disability Certificate (min 40% benchmark disability)',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='adip-disability'),'Aadhaar Card',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='adip-disability'),'Income Certificate of Family (< ₹2.5 Lakh per annum for 100% grant)',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='adip-disability'),'Passport-size photo showing physical disability',1,4);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='adip-disability'),1,'Apply online on the ALIMCO portal at alimco.in or through the District Disability Rehabilitation Centre (DDRC).');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='adip-disability'),2,'Submit UDID card and doctor requisition for the assistive appliance.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='adip-disability'),3,'Collection from district distribution camp or registered disability welfare society.');
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='ndfdc-loans'),'Benefit 1','Loan limits: Micro-finance up to ₹60,000; Self-employment ventures up to ₹25 Lakh; Higher education up to ₹20 Lakh.',1);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='ndfdc-loans'),'Benefit 2','Very low interest rate: 4% for loans up to ₹50,000; 5-6% for loans up to ₹5 Lakh.',2);
INSERT INTO scheme_benefits (scheme_id,benefit_name,description,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='ndfdc-loans'),'Benefit 3','1% rebate on prompt repayment, plus an additional 0.5% interest rebate for women with disabilities.',3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='ndfdc-loans'),'UDID Card or Disability Certificate (40% or more disability)',1,1);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='ndfdc-loans'),'Aadhaar Card and PAN Card',1,2);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='ndfdc-loans'),'Viable Business Proposal / DPR / College Admission Letter',1,3);
INSERT INTO scheme_documents (scheme_id,document_name,is_mandatory,sort_order) VALUES ((SELECT id FROM schemes WHERE scheme_code='ndfdc-loans'),'Bank Statement for past 6 months',1,4);
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='ndfdc-loans'),1,'Submit application through State Channelizing Agencies (SCAs), Public Sector Banks, or nhfdc.nic.in.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='ndfdc-loans'),2,'Project evaluation by SCA committee.');
INSERT INTO scheme_application_steps (scheme_id,step_number,step_text) VALUES ((SELECT id FROM schemes WHERE scheme_code='ndfdc-loans'),3,'Disbursement directly into borrower commercial bank account.');

-- Dashboard-friendly views
CREATE OR REPLACE VIEW v_user_application_summary AS
SELECT
    a.user_id,
    a.id AS application_id,
    s.name AS scheme_name,
    c.name AS category,
    a.eligibility_score,
    a.status,
    a.application_reference,
    a.applied_at,
    a.updated_at
FROM applications a
JOIN schemes s ON s.id = a.scheme_id
JOIN categories c ON c.id = s.category_id;

CREATE OR REPLACE VIEW v_scheme_document_progress AS
SELECT
    a.id AS application_id,
    a.user_id,
    s.name AS scheme_name,
    COUNT(sd.id) AS total_documents,
    SUM(CASE WHEN ad.document_status = 'VERIFIED' THEN 1 ELSE 0 END) AS verified_documents
FROM applications a
JOIN schemes s ON s.id = a.scheme_id
JOIN scheme_documents sd ON sd.scheme_id = s.id
LEFT JOIN application_documents ad
    ON ad.application_id = a.id AND ad.scheme_document_id = sd.id
GROUP BY a.id, a.user_id, s.name;
select*from users;
-- ================================================================
-- NOTES
-- 1. Passwords must be bcrypt/argon2 hashes generated by Node.js; never insert plaintext passwords.
-- 2. Eligibility rules store the current frontend matcher criteria; backend should perform the actual comparison.
-- 3. Application status history preserves every status transition for the tracker timeline.
-- 4. Comparison can remain stateless: GET /api/schemes/compare?ids=1,2,3.
-- 5. The existing frontend uses localStorage for saved schemes/tracker; these tables replace that persistence in the Node/MySQL version.
-- ================================================================