CREATE TABLE categories (
    id_categorie SERIAL PRIMARY KEY,
    nom VARCHAR(100)
);

INSERT INTO categories (nom) VALUES
('Plat malagasy'),
('Plat chinois'),
('Soupe'),
('Dessert et gouter'),
('Boisson');

ALTER TABLE plats ADD COLUMN id_categorie INT;
ALTER TABLE plats ADD CONSTRAINT fk_categorie FOREIGN KEY (id_categorie) REFERENCES categories(id_categorie);

UPDATE plats SET id_categorie = 1 WHERE id_plat = 1;
UPDATE plats SET id_categorie = 1 WHERE id_plat = 2;
UPDATE plats SET id_categorie = 1 WHERE id_plat = 3;
UPDATE plats SET id_categorie = 2 WHERE id_plat = 4;
UPDATE plats SET id_categorie = 3 WHERE id_plat = 5;
UPDATE plats SET id_categorie = 4 WHERE id_plat = 6;
UPDATE plats SET id_categorie = 5 WHERE id_plat = 7;