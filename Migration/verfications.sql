-- Etape 3 : montant total de chaque commande
SELECT c.id_commande,
       c.date,
       SUM(cp.quantite * p.prix) AS montant_total
FROM commandes c
JOIN commande_plats cp ON cp.id_commande = c.id_commande
JOIN plats p ON p.id_plat = cp.id_plat
GROUP BY c.id_commande, c.date
ORDER BY c.id_commande;

-- Etape 4 : liste des commandes avec le nom du client
SELECT c.id_commande,
       c.date,
       COALESCE(h.nom, 'client de passage') AS client
FROM commandes c
LEFT JOIN habitues h ON h.id_habitue = c.id_habitue
ORDER BY c.id_commande;
