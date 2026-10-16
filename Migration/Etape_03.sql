CREATE TABLE commandes (
    id_commande SERIAL PRIMARY KEY,
    date DATE
);

CREATE TABLE commande_plats (
    id_commande INT NOT NULL REFERENCES commandes(id_commande),
    id_plat INT NOT NULL REFERENCES plats(id_plat),
    quantite INT NOT NULL CHECK (quantite > 0),
    PRIMARY KEY (id_commande, id_plat)
);

INSERT INTO commandes (date) VALUES (NOW());

INSERT INTO commande_plats (id_commande, id_plat, quantite) VALUES
(1,2,1),
(1,3,2);