--Suppression des tables si elles existes 
DROP TABLE IF EXISTS Reservations;
DROP TABLE IF EXISTS Employes_base;
DROP TABLE IF EXISTS Exemplaires;
DROP TABLE IF EXISTS Materiels_base;
DROP TABLE IF EXISTS Indisponibilites;
DROP TABLE IF EXISTS Categories;

--Suppression des views si elles existes 
DROP VIEW IF EXISTS Employes;
DROP VIEW IF EXISTS Materiels;


--creation des views;

CREATE VIEW Materiels (
    id_materiel,
    libelle_materiel,
	id_categorie,
    nbEmpruntsEnCours
	) AS
SELECT 
    m.id_materiel,
    m.libelle_materiel,
    m.id_categorie, 
	(SELECT COUNT(r.id_reservation)
	FROM Exemplaires ex JOIN Reservations r ON ex.id_exemplaire = r.id_exemplaire
	WHERE ex.id_materiel = m.id_materiel 
		AND r.date_emprunt IS NOT NULL 
		AND r.date_retour_effective IS NULL) AS nbEmpruntsEnCours
FROM Materiels_base m;
	



CREATE VIEW Employes(
    id_employe,
    nom_employe,
    mail_employe,
    telephone_employe,
    nb_emprunts_en_cours) AS
SELECT
		e.id_employe,
		e.nom_employe,
		e.mail_employe,
		e.telephone_employe,
		(SELECT COUNT(r.id_reservation)
		FROM Reservations r 
		WHERE r.id_employe = e.id_employe AND r.date_emprunt IS NOT NULL AND R.date_retour_effective IS NULL)
		AS nbEmpruntsEnCours 
FROM Employes_Base e;



--creation des tables

CREATE TABLE Materiels_base(
	id_materiel INTEGER NOT NULL,
	libelle_materiel TEXT NOT NULL, 
	id_categorie INTEGER NOT NULL,
	CONSTRAINT Pk_Materiels_id PRIMARY key(id_materiel),
	CONSTRAINT Fk_Materiels_Categories_id FOREIGN key (id_categorie) REFERENCES Categories(id_categorie)
	
						);
			
CREATE TABLE Categories (
	id_categorie INTEGER NOT NULL, 
	libelle_categorie TEXT UNIQUE, 
	nbEmpruntsMax INTEGER NOT NULL,
	id_sous_categorie INTEGER,
	CONSTRAINT Pk_Categories_id_libelle PRIMARY KEY (id_categorie),
	CONSTRAINT Fk_Categories_id_sous_categorie FOREIGN KEY (id_sous_categorie) REFERENCES Categories (id_categorie)
	);
	
CREATE TABLE Employes_Base (
	id_employe INTEGER NOT NULL, 
	nom_employe TEXT NOT NULL, 
	mail_employe Text NOT NULL, 
	telephone_employe INTEGER NOT NULL,
	CONSTRAINT Pk_Employes_Base_id PRIMARY KEY (id_employe)
	
	);
	
CREATE TABLE Exemplaires (
	id_exemplaire INTEGER NOT NULL, 
	etat_exemplaire TEXT NOT NULL, 
	id_materiel INTEGER NOT NULL,
	id_indisponibilite INTEGER,
	CONSTRAINT Pk_Exemplaires_id PRIMARY KEY (id_exemplaire),
	CONSTRAINT Fk_Exemplaires_Materiels_id FOREIGN KEY (id_materiel) REFERENCES Materiels_base (id_materiel),
	CONSTRAINT Fk_Exemplaires_Idisponibilites_id FOREIGN KEY (id_indisponibilite) REFERENCES Indisponibilites (id_indisponibilite),
	CONSTRAINT Ck_Exemplaires_etat_exemplaire CHECK (etat_exemplaire IN ('neuf', 'bon', 'moyen', 'defectueux'))
						);
						
CREATE TABLE Reservations (
	id_reservation INTEGER NOT NULL, 
	date_debut date NOT NULL, 
	date_fin date NOT NULL, 
	date_emprunt date, 
	date_retour_effective date,
	id_employe INTEGER NOT NULL, 
	id_exemplaire INTEGER NOT NULL,
	CONSTRAINT Pk_Reservations_id PRIMARY KEY (id_reservation),
	CONSTRAINT Fk_Reservations_Employes_Base_id FOREIGN KEY (id_employe) REFERENCES Employes_Base (id_employe),
	CONSTRAINT Fk_Reservations_Exemplaires_id FOREIGN KEY (id_exemplaire) REFERENCES Exemplaires (id_exemplaire),
	--CONSTRAINT Ck_Reservations_dateEmprunt_dateDebut_dateFin CHECK ( date_emprunt >= date_debut AND date_emprunt <= date_fin),
	CONSTRAINT Ck_Reservations_dateRetour_dateEmprunts CHECK (date_retour_effective >= date_emprunt)
	);
	
CREATE TABLE Indisponibilites (
	id_indisponibilite INTEGER NOT NULL, 
	description_indisponibilite TEXT NOT NULL,
	CONSTRAINT Pk_Indisponibilites_id PRIMARY KEY (id_indisponibilite),
	CONSTRAINT Ck_Indisponibilites_description CHECK (description_indisponibilite IN ('panne', 'maintenance', 'perdu'))
	);

--les inserstions

INSERT INTO Categories(id_categorie, libelle_categorie, nbEmpruntsMax, id_sous_categorie)
SELECT DISTINCT id_categorie, libelle_categorie, nb_emprunt_max, Null
FROM Resa
WHERE nb_emprunt_max IS NOT NULL;
	   
INSERT INTO Employes_Base (id_employe, nom_employe, mail_employe, telephone_employe)
SELECT DISTINCT id_employe, nom_employe, mail, tel
FROM Resa
WHERE nom_employe IS NOT NULL;


INSERT INTO Materiels_Base (id_materiel, libelle_materiel, id_categorie)
SELECT DISTINCT id_materiel, libelle_materiel, id_categorie
FROM Resa
WHERE libelle_materiel IS NOT NULL;

INSERT INTO Indisponibilites (id_indisponibilite, description_indisponibilite)
SELECT DISTINCT id_indisponibilite, description_indisponibilite
FROM Resa
WHERE description_indisponibilite IS NOT NULL;

INSERT INTO Exemplaires (id_exemplaire, etat_exemplaire, id_materiel, id_indisponibilite)
SELECT DISTINCT id_exemplaire, etat, id_materiel, id_indisponibilite
FROM Resa
WHERE etat IS NOT NULL;

INSERT INTO Reservations (date_debut, date_emprunt, date_fin, date_retour_effective, id_employe, id_exemplaire)
SELECT DISTINCT date_debut, date_emprunt, date_fin, date_retour, id_employe, id_exemplaire
FROM Resa
WHERE date_debut NOT NULL AND date_fin NOT NULL;


  
 ---les requetes 
 
--Requete 1
SELECT M.libelle_materiel
FROM Materiels_Base M JOIN Exemplaires Ex USING (id_materiel)
                      JOIN Reservations R ON ( Ex.id_exemplaire = R.id_exemplaire)
                      JOIN Employes_base E ON ( R.id_employe = E.id_employe)
WHERE E.nom_employe = 'Martin';

--Requete 2
SELECT DISTINCT E.nom_employe
FROM Materiels_Base M JOIN Exemplaires Ex USING (id_materiel)
                      JOIN Reservations R ON ( Ex.id_exemplaire = R.id_exemplaire)
                      JOIN Employes_base E ON ( R.id_employe = E.id_employe)
WHERE M.id_materiel = 37
UNION
SELECT DISTINCT E.nom_employe
FROM Materiels_Base M JOIN Exemplaires Ex USING (id_materiel)
                      JOIN Reservations R ON ( Ex.id_exemplaire = R.id_exemplaire)
                      JOIN Employes_base E ON ( R.id_employe = E.id_employe)
WHERE M.id_materiel = 38;

--Requete 3
SELECT COUNT (DISTINCT E.nom_employe)
FROM Materiels_Base M JOIN Exemplaires Ex USING (id_materiel)
                      JOIN Reservations R ON ( Ex.id_exemplaire = R.id_exemplaire)
                      JOIN Employes_base E ON ( R.id_employe = E.id_employe)
WHERE M.id_materiel = 37 OR M.id_materiel = 38;

--Requete 4

SELECT e.nom_employe
FROM Employes_Base e 
WHERE e.id_employe NOT IN (
	SELECT r.id_employe
	FROM Reservations r JOIN Exemplaires ex ON r.id_exemplaire = ex.id_exemplaire 
	);
	
--5---

SELECT e.id_employe, e.nom_employe
FROM Employes_Base e JOIN Reservations r USING (id_employe)
				JOIN Exemplaires ex USING (id_exemplaire)
				JOIN Materiels_base	m Using (id_materiel) 
				JOIN Categories c USING (id_categorie)
GROUP BY e.id_employe, e.nom_employe
HAVING count(DISTINCT c.id_categorie) = (SELECT count(*) FROM Categories);

--6---

SELECT m.id_materiel, m.libelle_materiel, COUNT(e.id_exemplaire) AS nombre_exemplaires
FROM Materiels_base m JOIN Exemplaires e ON m.id_materiel = e.id_materiel
GROUP BY m.id_materiel, m.libelle_materiel;

--7---

SELECT e.id_employe, e.nom_employe, COUNT(r.id_reservation) AS nombre_reservations
FROM Employes_base e JOIN Reservations r ON e.id_employe = r.id_employe
GROUP BY e.id_employe, e.nom_employe
HAVING COUNT(r.id_reservation) >= 60;

--8---
SELECT e.id_employe, e.nom_employe, COUNT(r.id_reservation) AS nombre_emprunts_reels_perceuse
FROM Employes_base e JOIN Reservations r ON e.id_employe = r.id_employe 
					 JOIN Exemplaires ex ON r.id_exemplaire = ex.id_exemplaire        
WHERE r.date_retour_effective IS NOT NULL  AND ex.id_materiel = 20 AND r.date_emprunt IS NOT NULL
GROUP BY e.id_employe, e.nom_employe
HAVING COUNT(r.id_reservation) >= 2;

--9---
WITH Durees AS (
    SELECT 
        ex.id_materiel,
        m.libelle_materiel,
        r.id_reservation,
        (julianday(r.date_fin) - julianday(r.date_debut)) AS duree
    FROM Reservations r
    JOIN Exemplaires ex ON (r.id_exemplaire = ex.id_exemplaire)
    JOIN Materiels_base m ON (ex.id_materiel = m.id_materiel)
)
SELECT id_materiel, libelle_materiel, id_reservation, duree
FROM Durees
WHERE duree = (SELECT MAX(duree) FROM Durees);

--10---
WITH NbResa AS (
    SELECT 
        e.id_exemplaire,
        m.libelle_materiel,
        COUNT(r.id_reservation) AS nb_reservations
    FROM Reservations r
    JOIN Exemplaires e ON r.id_exemplaire = e.id_exemplaire
    JOIN Materiels_base m ON e.id_materiel = m.id_materiel
    GROUP BY e.id_exemplaire, m.libelle_materiel
)
SELECT *
FROM NbResa
WHERE nb_reservations = (SELECT MAX(nb_reservations) FROM NbResa);
