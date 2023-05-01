# Création de la base de données et des tables associées :

CREATE DATABASE laplaceimmo;
USE laplaceimmo;
 
CREATE TABLE commune (
	id INT NOT NULL PRIMARY KEY,
	commune VARCHAR(100),
	code_postal INTEGER NOT NULL,
	code_departement VARCHAR(100)
);

CREATE TABLE adresse (
	id INT NOT NULL PRIMARY KEY,
	num_voie INTEGER,
	compl_num VARCHAR(100),
	type_voie VARCHAR(100),
	nom_voie VARCHAR(100) NOT NULL,
	id_commune INT NOT NULL
);

CREATE TABLE bien (
	id INT NOT NULL PRIMARY KEY,
	type_local VARCHAR(100),
	nbr_piece INTEGER,
	surf_carrez FLOAT NOT NULL,
	surf_reel INTEGER NOT NULL,
	surf_terrain INTEGER,
	num_plan INTEGER,
	nbr_lot INTEGER,
	id_adresse INT NOT NULL
);

CREATE TABLE mutation (
	id INT NOT NULL PRIMARY KEY,
	date_mut DATE NOT NULL,
	nat_mut VARCHAR(100),
	val_fonciere INTEGER,
	id_bien INTEGER NOT NULL
);

SELECT * FROM adresse;
SELECT * FROM commune;
SELECT * FROM bien;
SELECT * FROM mutation;

# Nombre total d'appartements vendus au 1er semestre 2020 :	

SELECT
  b.type_local,
  count(DISTINCT(b.id)) as 'Nombre de Vente'
FROM 
  mutation m JOIN bien b ON m.id_bien = b.id
WHERE 
  b.type_local = 'Appartement' AND
  m.nat_mut = 'Vente' AND
  m.date_mut BETWEEN '2020-01-01' AND '2020-06-30'; 



# Proportion des ventes d'appartements par nombre de pièces :

SELECT 
  b.nbr_piece,
  100*count(b.id)/(SELECT count(m1.id) 
                   FROM 
		     mutation m1 JOIN bien b1 ON m1.id_bien = b1.id
		   WHERE 
		     b1.type_local = 'Appartement' AND 
                     m1.nat_mut = 'Vente') as proportion_vente
FROM 
  mutation m JOIN bien b ON m.id_bien = b.id
WHERE
  b.type_local = 'Appartement' AND 
  m.nat_mut = 'Vente'
GROUP BY b.nbr_piece;



# [Autre Méthodes] Proportion des ventes d'appartements par nombre de pièces :

SELECT
  b.nbr_piece,
  100*count(b.id)/(SELECT count(m1.id) 
                   FROM 
		     mutation AS m1,
		     bien AS b1
		   WHERE
		     m1.id_bien = b1.id
		     AND b1.type_local = 'Appartement'
		     AND m1.nat_mut = 'Vente') as proportion_vente
FROM
  mutation m,
  bien b
WHERE
  m.id_bien = b.id AND
  b.type_local = 'Appartement' AND
  m.nat_mut = 'Vente'
GROUP BY b.nbr_piece;
    

# Liste des 10 départements où le prix du mètre carré est le plus élevé :

SELECT
  c.code_departement AS dpt,
  round(AVG(m.val_fonciere/b.surf_carrez)) AS prix_metre_carre
FROM
  mutation m,
  bien b,
  commune c,
  adresse a
WHERE
  m.id_bien = b.id AND
  b.id_adresse = a.id AND
  a.id_commune = c.id
GROUP BY dpt
ORDER BY prix_metre_carre DESC
LIMIT 10;



# [AUTRE METHODE] Liste des 10 départements où le prix du mètre carré est le plus élevé :

SELECT 
  c.code_departement as dpt,
  round(AVG(m.val_fonciere/b.surf_carrez)) as prix_metre_carre
FROM mutation m
  JOIN bien b ON m.id_bien = b.id
  JOIN adresse a ON b.id_adresse = a.id
  JOIN commune c ON a.id_commune = c.id
GROUP BY dpt
ORDER BY prix_metre_carre DESC
LIMIT 10;



# Prix moyen du mètre carré d'une maison en île-de-France :

Select
  round(AVG(m.val_fonciere/b.surf_carrez)) AS prix_moyen_surface_carre
FROM mutation m
  JOIN bien b ON m.id_bien = b.id
  JOIN adresse a ON b.id_adresse = a.id
  JOIN commune c ON a.id_commune = c.id
WHERE
  b.type_local = 'Maison' AND
  c.code_departement IN (75, 77, 78, 91, 92, 93, 94, 95);
    
    
    
# [AUTRE METHODE] Prix moyen du mètre carré d'une maison en île-de-France :

Select
  round(AVG(m.val_fonciere/b.surf_carrez)) AS prix_moyen_surface_carre
FROM 
  mutation m,
  bien b,
  commune c,
  adresse a
WHERE
  m.id_bien = b.id AND
  b.id_adresse = a.id AND
  a.id_commune = c.id AND
  b.type_local = 'Maison' AND
  c.code_departement IN (75, 77, 78, 91, 92, 93, 94, 95);



# Liste des 10 appartements les plus chers avec le département et le nombre de mètres carrés.

SELECT 
  c.code_departement as dpt,
  b.surf_carrez, 
  m.val_fonciere as prix    
FROM
  mutation m
  JOIN bien b ON m.id_bien = b.id
  JOIN adresse a ON b.id_adresse = a.id
  JOIN commune c ON a.id_commune = c.id
WHERE
  type_local = 'Appartement'
ORDER BY val_fonciere DESC
LIMIT 10;



# Taux d'évolution du nombre de ventes entre le premier et le second trimestre de 2020 :

WITH
  tab1 as (Select count(*) as t1 from mutation as mut1 where mut1.date_mut between '2020-01-01' AND '2020-03-31'),
  tab2 as (Select count(*) as t2 from mutation as mut2 where mut2.date_mut between '2020-04-01' AND '2020-06-30')	
SELECT
  t1 as 'Nombre de vente trimestre 1',
  t2 as 'Nombre de Vente trimestre 2',
  100*(t2-t1)/t1 as taux_evolution
FROM
  tab1,
  tab2;
  
  
  
# Liste des communse où le nombre de ventes a augmenté d'au moins 20% entre le 1er et le 2nd trimestre :

WITH 
  tab1 as (
	SELECT
          nom_com,
	  count(*) as t1
	FROM
	  mutation m1
	  JOIN bien b1 ON m1.id_bien = b1.id
	  JOIN adresse a1 ON b1.id_adresse = a1.id
	  JOIN commune c1 ON a1.id_commune = c1.id
	WHERE m1.date_mut BETWEEN '2020-01-01' AND '2020-03-31'
        GROUP BY nom_com
        ORDER BY nom_com),
  tab2 as (
	SELECT
          nom_com,
          count(*) as t2
	FROM
	  mutation m2
	  JOIN bien b2 ON m2.id_bien = b2.id
	  JOIN adresse a2 ON b2.id_adresse = a2.id
	  JOIN commune c2 ON a2.id_commune = c2.id
	WHERE m2.date_mut between '2020-04-01' AND '2020-06-30'
        group by nom_com
        ORDER BY nom_com)
SELECT
  tab2.nom_com,
  t1,
  t2,
  cast((100*(t2-t1)/t1) as decimal(6,2)) as taux
FROM
  tab1 JOIN tab2 ON tab2.nom_com = tab1.nom_com
HAVING taux > 20
ORDER BY taux DESC; 



# Différence en pourcentage du prix au mètre carré entre un appartement de 2 pièces et un appartement de 3 pièces.

WITH
  t2 as (
      SELECT
        b.nbr_piece,
	AVG(val_fonciere/surf_carrez) as pm2,
        AVG(surf_carrez) as surface2
      FROM
	bien b JOIN mutation m ON m.id_bien = b.id
      WHERE 
	b.nbr_piece = 2 and 
	b.type_local = 'Appartement'),
  t3 as (
      SELECT
	b.nbr_piece,
	AVG(val_fonciere/surf_carrez) as pm3,
        AVG(surf_carrez) as surface3
      FROM
	bien b JOIN mutation m ON m.id_bien = b.id
      WHERE 
	b.nbr_piece = 3 and 
	b.type_local = 'Appartement')
	
SELECT 
  cast(pm3 as decimal(10,2)) as "Prix moyen d'un 3 Pieces",
  cast(surface3 as decimal(10,2)) as "Surface moyenne d'un 3P",
  cast(pm2 as decimal(10,2)) as "Prix moyen d'un 2 Pieces",
  cast(surface2 as decimal(10,2)) as "Surface moyenne d'un 2P",
  cast((100*(pm2-pm3)/pm3) as decimal(6,2)) as 'Différence entre un 2P et un 3P en %'
FROM
  t3, t2;
    


# Les moyennes de valeurs foncières pour le top 3 des communes des départements 6, 13, 33, 59 et 69

WITH
  tab1 as (
	SELECT
          c.nom_com,
	  c.code_departement as dpt,
	  AVG(m.val_fonciere) as moyenne1
	FROM
	  commune c
	  JOIN adresse a ON a.id_commune = c.id
	  JOIN bien b on b.id_adresse = a.id
	  JOIN mutation m ON m.id_bien = b.id
	WHERE 
	  c.code_departement IN (6, 13, 33, 59, 69)
	GROUP BY c.code_departement, c.nom_com
	ORDER BY moyenne1 DESC),
  tab2 as (
	SELECT
          tab1.nom_com,
	  tab1.dpt,
	  tab1.moyenne1,
	  RANK() OVER(PARTITION BY tab1.dpt ORDER BY tab1.moyenne1 DESC) as classement
	FROM
	  tab1)
SELECT 
  tab2.dpt,
  tab2.nom_com,
  cast(tab2.moyenne1 as DECIMAL (10,2)) as 'Moyenne'
FROM
  tab2
WHERE
  tab2.classement <= 3;
