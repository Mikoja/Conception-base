    CREATE TABLE plats (
        id_plat SERIAL PRIMARY KEY,
        nom VARCHAR(100),
        prix INT NOT NULL
    );

    INSERT INTO plats(nom, prix) VALUES 
        ('Romazava', 7000),
        ('Ravitoto sy henakisoa', 8000),
        ('Akoho sy voanio', 8500),
        ('Mi soa', 6000),
        ('Soupe chinoise', 5000),
        ('Mofo gasy (les 4)', 1000),
        ('Ranon''ampango', 500);