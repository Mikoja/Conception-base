Table plats(**id_plat**, nom, prix, #**id_categorie**) (modifie)

Table categories(**id_categorie**, nom) (nouveau)

Table commandes(**id_commande**, date, #id_habitue?) (modifie)

Table commande_plats(#**id_commande**, #**id_plat**, quantite) (nouveau)

Table habitues(**id_habitue**, nom, telephone?) (nouveau)

## Etape 1:
- Le type que j'ai choisi pour le prix est INT
- L'identifiant est **id_plat**

## Etape 2:
- Pour eviter les anomalies de mise a jour
- Par exemple : si le nom d'une categorie change, avec un **VARCHAR** il faut faire un **UPDATE** sur des milliers de lignes et risquer d'en rater 

## Etape 3:
- J'ai mis la **quantite** dans une table associative **commande_plats**

## Etape 4:
- La cle etrangere **id_habitue** n'est pas NOT NULL : NULL signifie « client de passage »
- Il faut un **LEFT JOIN** (jointure gauche) pour ne perdre aucune commande
