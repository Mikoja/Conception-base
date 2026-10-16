CREATE TABLE habitues (
    id_habitue SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    telephone VARCHAR(20)
);

INSERT INTO habitues (nom, telephone) VALUES
('Rakoto', '0341122334'),
('Rasoa', '0325566778');

ALTER TABLE commandes ADD COLUMN id_habitue INT;
ALTER TABLE commandes ADD CONSTRAINT fk_habitue
    FOREIGN KEY (id_habitue) REFERENCES habitues(id_habitue) ON DELETE SET NULL;

UPDATE commandes SET id_habitue = 1 WHERE id_commande = 1;

INSERT INTO commandes (date, id_habitue) VALUES
(NOW(), 2),
(NOW(), NULL);

INSERT INTO commande_plats (id_commande, id_plat, quantite) VALUES
(2, 1, 1),
(2, 6, 2),
(3, 4, 1);
