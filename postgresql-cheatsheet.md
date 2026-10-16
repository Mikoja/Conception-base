# Cheatsheet PostgreSQL

## Connexion

```bash
psql                          # Connexion avec l'utilisateur courant
psql -U nom_user              # Connexion avec un utilisateur
psql -U nom_user -d nom_db    # Connexion à une base précise
psql -h localhost -p 5432 -U nom_user -d nom_db
```

Commandes dans `psql` :

| Commande | Description |
|---|---|
| `\l` | Lister les bases de données |
| `\c nom_db` | Se connecter à une base |
| `\dt` | Lister les tables du schéma |
| `\dt *.*` | Lister les tables de tous les schémas |
| `\d nom_table` | Description d'une table |
| `\dn` | Lister les schémas |
| `\du` | Lister les rôles/utilisateurs |
| `\dx` | Lister les extensions |
| `\x` | Basculer en affichage horizontal |
| `\timing` | Afficher le temps d'exécution |
| `\i fichier.sql` | Exécuter un fichier SQL |
| `\o fichier.csv` | Rediriger la sortie vers un fichier |
| `\p` | Rappeler la dernière requête |
| `\?` | Aide sur les commandes psql |
| `\q` | Quitter |

## Changer d'utilisateur / de rôle

**1. Se reconnecter avec un autre utilisateur (`psql`)**

```bash
# En quittant puis relançant psql
psql -U autre_user -d nom_db

# Ou à chaud, sans quitter psql : \c base utilisateur
```

```sql
\c nom_db autre_user          -- se reconnecter à nom_db en tant que autre_user
\c - autre_user               -- changer d'utilisateur en gardant la base courante
\conninfo                     -- afficher la connexion actuelle (user, base, host)
```

> `\c` (ou `\connect`) ouvre une **nouvelle connexion** : la session et les variables sont réinitialisées.

**2. Emprunter un rôle sans changer de connexion (`SET ROLE`)**

```sql
SET ROLE autre_user;          -- agir avec les droits de autre_user
RESET ROLE;                   -- revenir à l'utilisateur réel de la connexion
SELECT current_user, session_user;   -- current_user = rôle actif, session_user = vrai user
```

> `SET ROLE` ne fonctionne que si l'utilisateur connecté est **membre** du rôle ciblé
> (ou superutilisateur). Les droits deviennent ceux du rôle emprunté.

**3. Basculer complètement de session (`SET SESSION AUTHORIZATION`)**

```sql
SET SESSION AUTHORIZATION autre_user;   -- change session_user ET current_user
RESET SESSION AUTHORIZATION;            -- revenir à l'utilisateur d'origine
```

> Réservé aux superutilisateurs. Contrairement à `SET ROLE`, modifie le `session_user` lui-même.

**4. Gérer les membres d'un rôle (pour pouvoir utiliser `SET ROLE`)**

```sql
CREATE ROLE autre_user LOGIN PASSWORD 'mdp';
GRANT autre_user TO mikoja;      -- mikoja peut désormais faire SET ROLE autre_user;
\du                              -- lister les rôles et leurs appartenances
```

**Récapitulatif**

| Méthode | Effet | Qui peut l'utiliser |
|---|---|---|
| `\c base user` | Nouvelle connexion, tout réinitialisé | Tous |
| `psql -U user` | Lance une nouvelle session | Tous |
| `SET ROLE user` | Droits du rôle, `session_user` inchangé | Membres du rôle / superuser |
| `SET SESSION AUTHORIZATION user` | Change aussi `session_user` | Superuser uniquement |

## Bases de données

```sql
CREATE DATABASE nom_db;
CREATE DATABASE nom_db WITH OWNER nom_user;
DROP DATABASE nom_db;
\c nom_db

-- Sauvegarde / restauration (en shell)
pg_dump -U nom_user nom_db > backup.sql
pg_dump -U nom_user -Fc nom_db > backup.dump   -- format custom (plus rapide)
psql -U nom_user nom_db < backup.sql
pg_restore -U nom_user -d nom_db backup.dump
```

## Schémas

```sql
CREATE SCHEMA nom_schema;
SET search_path TO nom_schema, public;
DROP SCHEMA nom_schema;
DROP SCHEMA nom_schema CASCADE;
```

## Tables

```sql
CREATE TABLE nom_table (
    id          SERIAL PRIMARY KEY,
    nom         VARCHAR(100) NOT NULL,
    email       VARCHAR(255) UNIQUE,
    age         INT DEFAULT 0,
    actif       BOOLEAN DEFAULT TRUE,
    cree_le     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE nom_table ADD COLUMN colonne TYPE;
ALTER TABLE nom_table RENAME COLUMN ancien TO nouveau;
ALTER TABLE nom_table DROP COLUMN colonne;
ALTER TABLE nom_table ALTER COLUMN colonne SET DEFAULT 0;
ALTER TABLE nom_table ALTER COLUMN colonne SET NOT NULL;
ALTER TABLE nom_table RENAME TO nouveau_nom;
DROP TABLE nom_table;
TRUNCATE nom_table RESTART IDENTITY CASCADE;
```

## Types de données courants

| Type | Description |
|---|---|
| `SERIAL` / `BIGSERIAL` | Auto-incrément (int4 / int8) |
| `INTEGER`, `SMALLINT`, `BIGINT` | Entiers |
| `NUMERIC(p,s)`, `DECIMAL(p,s)` | Décimal exact |
| `REAL`, `DOUBLE PRECISION` | Flottants |
| `BOOLEAN` | `TRUE` / `FALSE` |
| `TEXT` | Chaîne de longueur illimitée |
| `VARCHAR(n)` | Chaîne de longueur limitée |
| `CHAR(n)` | Chaîne fixe, complétée par des espaces |
| `DATE` | Date seule |
| `TIME` | Heure seule |
| `TIMESTAMP` | Date + heure |
| `TIMESTAMPTZ` | Date + heure avec fuseau horaire |
| `UUID` | Identifiant unique |
| `JSON` / `JSONB` | Données JSON (JSONB : binaire, indexable) |
| `ARRAY` | Tableau (`text[]`, `int[]`…) |
| `INET`, `CIDR` | Adresses IP / réseau |

## Contraintes

```sql
PRIMARY KEY (id)
FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
UNIQUE (email)
NOT NULL
CHECK (age >= 0)
DEFAULT valeur
```

```sql
-- Ajouter une contrainte après coup
ALTER TABLE t ADD CONSTRAINT nom_contrainte UNIQUE (col);
ALTER TABLE t ADD CONSTRAINT fk_client FOREIGN KEY (client_id) REFERENCES clients(id);
ALTER TABLE t DROP CONSTRAINT nom_contrainte;
```

## Index

```sql
CREATE INDEX idx_nom ON nom_table (colonne);
CREATE UNIQUE INDEX idx_nom ON nom_table (colonne);
CREATE INDEX idx_nom ON nom_table (col1, col2);                -- index composite
CREATE INDEX idx_nom ON nom_table ((lower(colonne)));          -- index sur expression
CREATE INDEX idx_nom ON nom_table USING GIN (colonne_jsonb);   -- GIN pour JSONB / arrays
DROP INDEX idx_nom;

-- Diagnostic
EXPLAIN ANALYZE SELECT * FROM nom_table WHERE id = 1;
```

## Requêtes (SELECT)

```sql
SELECT DISTINCT colonne FROM t;
SELECT * FROM t LIMIT 10 OFFSET 20;
SELECT colonne AS alias FROM t;
SELECT COUNT(*), AVG(age), MIN(age), MAX(age), SUM(sal) FROM t;
SELECT COUNT(DISTINCT ville) FROM t;
SELECT * FROM t WHERE age BETWEEN 18 AND 30;
SELECT * FROM t WHERE ville IN ('Paris', 'Lyon');
SELECT * FROM t WHERE nom LIKE 'A%';          -- % = n'importe quoi, _ = un caractère
SELECT * FROM t WHERE colonne IS NULL;
SELECT * FROM t WHERE NOT (a = 1 AND b = 2);
SELECT * FROM t ORDER BY colonne DESC, id ASC;
SELECT * FROM t WHERE ville = 'Paris' ORDER BY nom LIMIT 5;

-- Agrégation
SELECT ville, COUNT(*) FROM t GROUP BY ville HAVING COUNT(*) > 10;

-- Jointures
SELECT c.nom, o.id
FROM clients c
INNER JOIN orders o ON o.client_id = c.id;

SELECT c.nom, o.id
FROM clients c
LEFT JOIN orders o ON o.client_id = c.id;   -- tous les clients, même sans commande

SELECT * FROM a FULL OUTER JOIN b ON a.id = b.id;
SELECT * FROM a CROSS JOIN b;                 -- produit cartésien
SELECT * FROM a NATURAL JOIN b;               -- jointure sur colonnes homonymes

-- Sous-requêtes
SELECT * FROM clients WHERE id IN (SELECT client_id FROM orders WHERE total > 100);
SELECT * FROM clients c WHERE EXISTS (SELECT 1 FROM orders o WHERE o.client_id = c.id);
```

## Manipulation des données

```sql
INSERT INTO t (nom, age) VALUES ('Alice', 30), ('Bob', 25);
INSERT INTO t (nom) VALUES ('Carol') RETURNING id;

UPDATE t SET age = 31 WHERE nom = 'Alice' RETURNING *;

DELETE FROM t WHERE id = 1;
DELETE FROM t;  -- sans WHERE : supprime tout
```

## CTE et sous-requêtes avancées

```sql
WITH comptes AS (
    SELECT client_id, SUM(total) AS total_cmd
    FROM orders
    GROUP BY client_id
)
SELECT c.nom, comptes.total_cmd
FROM clients c
JOIN comptes ON comptes.client_id = c.id;

-- CTE récursive
WITH RECURSIVE arbre AS (
    SELECT id, nom, parent_id FROM categories WHERE parent_id IS NULL
    UNION ALL
    SELECT c.id, c.nom, c.parent_id FROM categories c JOIN arbre a ON c.parent_id = a.id
)
SELECT * FROM arbre;

-- Fenêtres
SELECT nom, sal,
       ROW_NUMBER() OVER (ORDER BY sal DESC) AS rang,
       RANK()       OVER (PARTITION BY dept ORDER BY sal DESC),
       SUM(sal)     OVER (PARTITION BY dept)
FROM employes;
```

## Fonctions

```sql
-- Chaînes
CONCAT(a, b)          -- a || b
LENGTH('text')
UPPER('text') / LOWER('text')
TRIM(' text ')
SUBSTRING('text' FROM 2 FOR 3)
REPLACE('text', 'a', 'b')
SPLIT_PART('a,b,c', ',', 2)

-- Dates
NOW(), CURRENT_DATE, CURRENT_TIMESTAMP
EXTRACT(YEAR FROM date_col)
AGE(timestamp)                    -- intervalle depuis now()
date_col + INTERVAL '1 month'
TO_CHAR(date_col, 'DD/MM/YYYY')
TO_DATE('2024-01-15', 'YYYY-MM-DD')

-- Math
ROUND(x, 2), CEIL(x), FLOOR(x), ABS(x), POWER(x, 2)

-- Conversion
CAST(col AS INTEGER)   -- ou col::INTEGER

-- JSONB
json_col->>'clé'                   -- texte
json_col->'clé'                    -- json
json_col #>> '{a,b}'               -- chemin
jsonb_set(col, '{a,b}', '"valeur"')
```

## Agrégats et Window

```sql
STRING_AGG(nom, ', ' ORDER BY nom)
ARRAY_AGG(col)
BOOL_AND(bool_col) / BOOL_OR(bool_col)
STDDEV(x) / VARIANCE(x)
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY x)

FIRST_VALUE(x) OVER w
LAST_VALUE(x) OVER w
LAG(x, 1) OVER w / LEAD(x, 1) OVER w
NTILE(4) OVER w
```

## Transactions

```sql
BEGIN;
  UPDATE comptes SET solde = solde - 100 WHERE id = 1;
  UPDATE comptes SET solde = solde + 100 WHERE id = 2;
COMMIT;

BEGIN;
  -- ...
ROLLBACK;

-- Points de sauvegarde
SAVEPOINT sp1;
ROLLBACK TO sp1;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;   -- (défaut)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

## Utilisateurs et permissions

```sql
CREATE ROLE nom_user LOGIN PASSWORD 'motdepasse';
CREATE ROLE nom_user LOGIN PASSWORD 'mdp' CREATEDB;
ALTER ROLE nom_user PASSWORD 'nouveau_mdp';
ALTER ROLE nom_user SUPERUSER;
DROP ROLE nom_user;

GRANT ALL PRIVILEGES ON DATABASE nom_db TO nom_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO nom_user;
GRANT SELECT, INSERT ON TABLE t TO nom_user;
GRANT USAGE ON SCHEMA public TO nom_user;

REVOKE ALL PRIVILEGES ON TABLE t FROM nom_user;
```

## Vue et Matérialized View

```sql
CREATE OR REPLACE VIEW vue_active AS
SELECT id, nom FROM t WHERE actif = TRUE;

SELECT * FROM vue_active;
DROP VIEW vue_active;

CREATE MATERIALIZED VIEW mv_stats AS
SELECT ville, COUNT(*) FROM t GROUP BY ville;

REFRESH MATERIALIZED VIEW mv_stats;
DROP MATERIALIZED VIEW mv_stats;
```

## Trigger et Fonction

```sql
CREATE OR REPLACE FUNCTION fn_maj_timestamp() RETURNS TRIGGER AS $$
BEGIN
    NEW.cree_le = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_maj
BEFORE UPDATE ON nom_table
FOR EACH ROW
EXECUTE FUNCTION fn_maj_timestamp();

DROP TRIGGER trg_maj ON nom_table;
```

## Utilitaires

```sql
-- Verrous
LOCK TABLE t IN EXCLUSIVE MODE;

-- Requêtes en cours
SELECT pid, state, query, query_start
FROM pg_stat_activity
WHERE state = 'idle in transaction';

-- Tuer une session
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid = 12345;

-- Taille
SELECT pg_size_pretty(pg_total_relation_size('nom_table'));
SELECT pg_size_pretty(pg_database_size('nom_db'));
```
