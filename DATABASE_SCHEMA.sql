-- =====================================================
-- SCHÉMA BASE DE DONNÉES - GÈRTONARGENT
-- =====================================================

-- Création de la base de données
CREATE DATABASE IF NOT EXISTS gertonargent_db;
USE gertonargent_db;

-- =====================================================
-- TABLE 1: USERS (Utilisateurs)
-- =====================================================
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    budget_mensuel DECIMAL(10,2) DEFAULT 0.00,
    photo_profil VARCHAR(500) DEFAULT NULL,
    langue VARCHAR(10) DEFAULT 'fr',
    conseils_ia BOOLEAN DEFAULT TRUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================================================
-- TABLE 2: TRANSACTIONS
-- =====================================================
CREATE TABLE transactions (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    montant DECIMAL(10,2) NOT NULL,
    type ENUM('revenu', 'depense') NOT NULL,
    categorie VARCHAR(50) NOT NULL,
    description TEXT,
    date_transaction DATE NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =====================================================
-- TABLE 3: BUDGETS (Budgets par catégorie)
-- =====================================================
CREATE TABLE budgets (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    categorie VARCHAR(50) NOT NULL,
    montant_limite DECIMAL(10,2) NOT NULL,
    mois_annee VARCHAR(7) NOT NULL, -- Format: '2024-01'
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_category_month (user_id, categorie, mois_annee)
);

-- =====================================================
-- TABLE 4: SESSIONS (Sessions utilisateur)
-- =====================================================
CREATE TABLE sessions (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    token VARCHAR(500) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =====================================================
-- INDEX POUR OPTIMISATION
-- =====================================================
CREATE INDEX idx_transactions_user_date ON transactions(user_id, date_transaction);
CREATE INDEX idx_transactions_user_type ON transactions(user_id, type);
CREATE INDEX idx_budgets_user_month ON budgets(user_id, mois_annee);
CREATE INDEX idx_sessions_token ON sessions(token);
CREATE INDEX idx_sessions_user ON sessions(user_id);

-- =====================================================
-- DONNÉES DE TEST (OPTIONNEL)
-- =====================================================

-- Utilisateur de test
INSERT INTO users (id, nom, prenom, email, mot_de_passe, budget_mensuel) VALUES 
('test-user-001', 'Test', 'Utilisateur', 'test@example.com', '$2b$10$hashedpassword', 100000.00);

-- Transactions de test
INSERT INTO transactions (id, user_id, montant, type, categorie, description, date_transaction) VALUES 
('tx-001', 'test-user-001', 50000.00, 'revenu', 'Salaire', 'Salaire du mois', '2024-01-15'),
('tx-002', 'test-user-001', 15000.00, 'depense', 'Nourriture', 'Courses alimentaires', '2024-01-16'),
('tx-003', 'test-user-001', 25000.00, 'depense', 'Transport', 'Essence et transport', '2024-01-17');

-- Budgets de test
INSERT INTO budgets (id, user_id, categorie, montant_limite, mois_annee) VALUES 
('budget-001', 'test-user-001', 'Nourriture', 20000.00, '2024-01'),
('budget-002', 'test-user-001', 'Transport', 30000.00, '2024-01'),
('budget-003', 'test-user-001', 'Loisirs', 15000.00, '2024-01');

-- =====================================================
-- VUES UTILES POUR LES ANALYSES
-- =====================================================

-- Vue pour les statistiques mensuelles
CREATE VIEW v_stats_mensuelles AS
SELECT 
    t.user_id,
    DATE_FORMAT(t.date_transaction, '%Y-%m') as mois_annee,
    SUM(CASE WHEN t.type = 'revenu' THEN t.montant ELSE 0 END) as total_revenus,
    SUM(CASE WHEN t.type = 'depense' THEN t.montant ELSE 0 END) as total_depenses,
    SUM(CASE WHEN t.type = 'revenu' THEN t.montant ELSE -t.montant END) as solde_net
FROM transactions t
GROUP BY t.user_id, DATE_FORMAT(t.date_transaction, '%Y-%m');

-- Vue pour les dépenses par catégorie
CREATE VIEW v_depenses_par_categorie AS
SELECT 
    t.user_id,
    t.categorie,
    DATE_FORMAT(t.date_transaction, '%Y-%m') as mois_annee,
    SUM(t.montant) as total_depense
FROM transactions t
WHERE t.type = 'depense'
GROUP BY t.user_id, t.categorie, DATE_FORMAT(t.date_transaction, '%Y-%m');

-- =====================================================
-- PROCÉDURES STOCKÉES UTILES
-- =====================================================

-- Procédure pour calculer le solde actuel d'un utilisateur
DELIMITER //
CREATE PROCEDURE CalculerSoldeUtilisateur(IN user_id_param VARCHAR(36))
BEGIN
    SELECT 
        u.id,
        u.nom,
        u.prenom,
        u.budget_mensuel,
        COALESCE(SUM(CASE WHEN t.type = 'revenu' THEN t.montant ELSE 0 END), 0) as total_revenus,
        COALESCE(SUM(CASE WHEN t.type = 'depense' THEN t.montant ELSE 0 END), 0) as total_depenses,
        COALESCE(SUM(CASE WHEN t.type = 'revenu' THEN t.montant ELSE -t.montant END), 0) as solde_actuel
    FROM users u
    LEFT JOIN transactions t ON u.id = t.user_id
    WHERE u.id = user_id_param
    GROUP BY u.id, u.nom, u.prenom, u.budget_mensuel;
END //
DELIMITER ;

-- =====================================================
-- TRIGGERS POUR MAINTENIR L'INTÉGRITÉ
-- =====================================================

-- Trigger pour mettre à jour la date de modification
DELIMITER //
CREATE TRIGGER update_transaction_timestamp
BEFORE UPDATE ON transactions
FOR EACH ROW
BEGIN
    SET NEW.date_modification = CURRENT_TIMESTAMP;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER update_budget_timestamp
BEFORE UPDATE ON budgets
FOR EACH ROW
BEGIN
    SET NEW.date_modification = CURRENT_TIMESTAMP;
END //
DELIMITER ;
