-- phpMyAdmin SQL Dump
-- version 4.5.4.1deb2ubuntu2
-- http://www.phpmyadmin.net
--
-- Client :  localhost
-- Généré le :  Lun 09 Janvier 2017 à 12:22
-- Version du serveur :  5.7.16-0ubuntu0.16.04.1
-- Version de PHP :  7.0.14-2+deb.sury.org~xenial+1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données :  `papyrus`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `commander` ()  BEGIN
	DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE _date DateTime DEFAULT now();
    DECLARE _id int;
    DECLARE _numcom mediumint(9);
	DECLARE _codart CHAR(4);
    DECLARE _qtecmd decimal(6,0);
    DECLARE _qte1 decimal(6,0);
    DECLARE _qte2 decimal(6,0);
    DECLARE _qte3 decimal(6,0);
    DECLARE _numfou decimal(10,0);
    DECLARE _prixuni decimal(5,2) DEFAULT 0;
    DECLARE _prix1 decimal(5,2);
    DECLARE _prix2 decimal(5,2);
    DECLARE _prix3 decimal(5,2);
    DECLARE _numlig decimal(3,0);
    DECLARE curs cursor for select id, CODART, QTECMD, NUMFOU from ACOMMANDER;
    DECLARE EXIT HANDLER FOR NOT FOUND SET done = TRUE;
    
    # Gestion des rollback
    DECLARE exit handler for sqlexception BEGIN ROLLBACK; END;
	DECLARE exit handler for sqlwarning	BEGIN ROLLBACK; END;
    
    # Ouverture du curseur
    open curs;
    
    WHILE !done DO
		fetch curs into _id, _codart, _qtecmd, _numfou;
        set _numlig = 0;
    
		# Récupération du prix en fonction de la quantité
        select PRIX1, QTE1, PRIX2, QTE2, PRIX3, QTE3 into _prix1, _qte1, _prix2, _qte2, _prix3, _qte3 from ACHAT where CODART = _codart COLLATE latin1_swedish_ci and NUMFOU = _numfou limit 1;
        
        if _qtecmd > _qte2 then
			set _prixuni = _prix1;
        elseif _qtecmd > _qte3 then
			set _prixuni = _prix2;
        else
			set _prixuni = _prix3;        
        end if;
        
		# Démarrage de la transaction
        START TRANSACTION;
			set _numcom = (select NUMCOM from entcom where NUMFOU = _numfou and DATCOM  = _date);
            if _numcom IS NULL then
				insert into entcom values(0, _numfou, _date, null);
                set _numcom = LAST_INSERT_ID();
                set _numlig = 1;
			else 
                set _numlig = (select count(NUMLIG) from ligcom where NUMCOM = _numcom group by NUMCOM);
                set _numlig = _numlig +1;
            end if;           
            
            insert into ligcom values(_numcom, _codart, _numlig, _qtecmd, _prixuni, 0, null);
            delete from ACOMMANDER where id = _id;
        COMMIT;
	END WHILE;
    close curs;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Int_Commande` (IN `fou` INT, OUT `montant` DOUBLE)  BEGIN
	DECLARE noFour BOOLEAN DEFAULT FALSE;
	DECLARE EXIT HANDLER FOR NOT FOUND SET noFour = fn_noFour();
	select sum(qtecde*priuni) 
		into montant 
		from entcom 
		inner join ligcom 
		on entcom.numcom = ligcom.numcom 
		where entcom.numfou = fou 
		group by entcom.numcom 
		ORDER BY entcom.datcom DESC 
		LIMIT 1;
	
    # La dernière date ... et si 2 commandes la même date ?
    #DECLARE idat TIMESTAMP;
    #select max(datcom) into idat from entcom where numfou = fou;
    #select sum(priuni*qtecde) into montant from entcom inner join ligcom on entcom.numcom = ligcom.numcom where entcom.numfou = fou and entcom.datcom = idat;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Lst_Commandes` (IN `libelle` VARCHAR(50))  BEGIN
	#select entcom.numcom, nomfou, libart, sum(qtecde*priuni) as total from fournis inner join entcom on fournis.numfou = entcom.numfou inner join ligcom on entcom.numcom = ligcom.numcom inner join produit on produit.codart = ligcom.codart where obscom like CONCAT('%',libelle,'%') COLLATE latin1_swedish_ci group by entcom.numcom, nomfou, libart;
	DECLARE done BOOLEAN DEFAULT FALSE;
	DECLARE _numcom INT;
    DECLARE _nomfou VARCHAR(50);
    DECLARE _libart VARCHAR(50);
    DECLARE _total INT;
    DECLARE curs cursor for select entcom.numcom, nomfou, libart, sum(qtecde*priuni) as total from fournis inner join entcom on fournis.numfou = entcom.numfou inner join ligcom on entcom.numcom = ligcom.numcom inner join produit on produit.codart = ligcom.codart where obscom like CONCAT('%',libelle,'%') COLLATE latin1_swedish_ci group by entcom.numcom, nomfou, libart;
    DECLARE EXIT HANDLER FOR NOT FOUND SET done = TRUE;
    open curs;
    WHILE !done DO
		fetch curs into _numcom, _nomfou, _libart, _total;
		SELECT _numcom, _nomfou;
	END WHILE;
    close curs;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Lst_fournis` ()  BEGIN
	#select distinct numfou from entcom;
    DECLARE done BOOLEAN DEFAULT FALSE;
	DECLARE rslt INT;
    DECLARE curs cursor for select distinct numfou from entcom;
    DECLARE EXIT HANDLER FOR NOT FOUND SET done = TRUE;
    open curs;
    WHILE !done DO
		fetch curs into rslt;
		SELECT rslt;
	END WHILE;
    close curs;
END$$

--
-- Fonctions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_CA_Fournisseur` (`id` INT, `yr` INT) RETURNS DOUBLE BEGIN
	RETURN (SELECT sum(qtecde*priuni*1.2060) CA 
				FROM fournis
                INNER JOIN entcom
                ON fournis.numfou = entcom.numfou
                INNER JOIN ligcom
                ON entcom.numcom = ligcom.numcom
                WHERE extract(year from datcom) = yr
                AND fournis.numfou = id
                GROUP BY fournis.numfou,nomfou
                LIMIT 1);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_libExists` () RETURNS INT(11) BEGIN
	SIGNAL SQLSTATE '09002' SET MESSAGE_TEXT = 'Désignation existantes', MYSQL_ERRNO = 9002;
	RETURN TRUE;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_noFour` () RETURNS TINYINT(1) BEGIN
	SIGNAL SQLSTATE '09000' SET MESSAGE_TEXT = 'Fournisseur absent', MYSQL_ERRNO = 9000;
	RETURN TRUE;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_noStock` () RETURNS TINYINT(1) BEGIN
	SIGNAL SQLSTATE '09000' SET MESSAGE_TEXT = 'Rupture de stock', MYSQL_ERRNO = 9000;
	RETURN TRUE;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `ACHAT`
--

CREATE TABLE `ACHAT` (
  `CODART` char(4) COLLATE latin1_general_ci NOT NULL,
  `NUMFOU` decimal(10,0) NOT NULL,
  `DELLIV` decimal(6,0) NOT NULL,
  `QTE1` decimal(6,0) NOT NULL,
  `PRIX1` decimal(5,2) NOT NULL,
  `QTE2` decimal(6,0) NOT NULL,
  `PRIX2` decimal(5,2) NOT NULL,
  `QTE3` decimal(6,0) NOT NULL,
  `PRIX3` decimal(5,0) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Contenu de la table `ACHAT`
--

INSERT INTO `ACHAT` (`CODART`, `NUMFOU`, `DELLIV`, `QTE1`, `PRIX1`, `QTE2`, `PRIX2`, `QTE3`, `PRIX3`) VALUES
('B001', '8700', '15', '20', '150.00', '50', '145.00', '100', '140'),
('B002', '8700', '15', '0', '210.00', '50', '200.00', '100', '185'),
('D035', '120', '0', '0', '40.00', '0', '0.00', '0', '0'),
('D035', '9120', '5', '0', '40.00', '100', '30.00', '0', '0'),
('I100', '120', '90', '0', '700.00', '50', '600.00', '120', '500'),
('I100', '540', '70', '0', '710.00', '60', '630.00', '100', '600'),
('I100', '9120', '60', '0', '800.00', '70', '600.00', '90', '500'),
('I100', '9150', '90', '0', '650.00', '90', '600.00', '200', '590'),
('I100', '9180', '30', '0', '720.00', '50', '670.00', '100', '490'),
('I105', '120', '90', '10', '705.00', '50', '630.00', '120', '500'),
('I105', '540', '70', '0', '810.00', '60', '645.00', '100', '600'),
('I105', '8700', '30', '0', '720.00', '50', '670.00', '100', '510'),
('I105', '9120', '60', '0', '920.00', '70', '800.00', '90', '700'),
('I105', '9150', '90', '0', '685.00', '90', '600.00', '200', '590'),
('I108', '120', '90', '5', '795.00', '30', '720.00', '100', '680'),
('I108', '9120', '60', '0', '920.00', '70', '820.00', '100', '780'),
('I110', '9120', '60', '0', '950.00', '70', '850.00', '90', '790'),
('I110', '9180', '90', '0', '900.00', '70', '870.00', '90', '835'),
('R080', '9120', '10', '0', '120.00', '100', '100.00', '0', '0'),
('R132', '9120', '5', '0', '275.00', '0', '0.00', '0', '0');

-- --------------------------------------------------------

--
-- Structure de la table `ACOMMANDER`
--

CREATE TABLE `ACOMMANDER` (
  `id` int(11) NOT NULL,
  `CODART` char(4) NOT NULL,
  `QTECMD` varchar(45) NOT NULL,
  `NUMFOU` decimal(10,0) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `entcom`
--

CREATE TABLE `entcom` (
  `NUMCOM` mediumint(9) NOT NULL,
  `NUMFOU` decimal(10,0) DEFAULT NULL,
  `DATCOM` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `OBSCOM` varchar(25) COLLATE latin1_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Contenu de la table `entcom`
--

INSERT INTO `entcom` (`NUMCOM`, `NUMFOU`, `DATCOM`, `OBSCOM`) VALUES
(70010, '120', '2014-01-15 14:42:07', NULL),
(70011, '540', '2014-01-15 14:42:07', 'Commande urgente'),
(70020, '9180', '2014-01-15 14:42:07', NULL),
(70025, '9150', '2014-01-15 14:42:07', 'Commande urgente'),
(70210, '120', '2014-01-15 14:42:07', 'Commande cadencée'),
(70250, '8700', '2014-01-15 14:42:07', 'Commande cadencée'),
(70300, '9120', '2014-01-15 14:42:07', NULL),
(70620, '540', '2014-01-15 14:42:07', NULL),
(70625, '120', '2014-01-15 14:42:07', NULL),
(70629, '9180', '2014-01-15 14:42:07', NULL),
(70658, '8700', '2017-01-09 11:19:27', NULL),
(70659, '120', '2017-01-09 11:19:27', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `fournis`
--

CREATE TABLE `fournis` (
  `NUMFOU` decimal(10,0) NOT NULL,
  `NOMFOU` varchar(30) COLLATE latin1_general_ci NOT NULL,
  `RUEFOU` varchar(30) COLLATE latin1_general_ci NOT NULL,
  `POSFOU` varchar(5) COLLATE latin1_general_ci NOT NULL,
  `VILFOU` varchar(25) COLLATE latin1_general_ci NOT NULL,
  `CONFOU` varchar(15) COLLATE latin1_general_ci NOT NULL,
  `SATISF` decimal(3,0) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Contenu de la table `fournis`
--

INSERT INTO `fournis` (`NUMFOU`, `NOMFOU`, `RUEFOU`, `POSFOU`, `VILFOU`, `CONFOU`, `SATISF`) VALUES
('120', 'GROBRIGAN', '20 rue du papier', '92200', 'papercity', 'georges', '8'),
('540', 'ECLIPSE', '53 rue laisse flotter', '78250', 'bugbugville', 'nestor', '7'),
('8700', 'MEDICIS', '120 rue des plantes', '75014', 'paris', 'lison', NULL),
('9120', 'DICOBOL', '11 rue des sports', '85100', 'roche/yon', 'hercule', '8'),
('9150', 'DEPANPAP', '26 av des loco', '59987', 'coroncountry', 'pollux', '5'),
('9180', 'HURRYTAPE', '68 bvd des octets', '4044', 'Dumpville', 'Track', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `ligcom`
--

CREATE TABLE `ligcom` (
  `NUMCOM` mediumint(9) NOT NULL,
  `CODART` char(4) COLLATE latin1_general_ci NOT NULL,
  `NUMLIG` decimal(3,0) NOT NULL,
  `QTECDE` decimal(6,0) NOT NULL,
  `PRIUNI` decimal(5,2) NOT NULL,
  `QTELIV` decimal(6,0) DEFAULT NULL,
  `DERLIV` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Contenu de la table `ligcom`
--

INSERT INTO `ligcom` (`NUMCOM`, `CODART`, `NUMLIG`, `QTECDE`, `PRIUNI`, `QTELIV`, `DERLIV`) VALUES
(70010, 'D035', '4', '200', '40.00', '250', '2014-01-15'),
(70010, 'I105', '2', '2000', '485.00', '2000', '2014-01-15'),
(70010, 'I108', '3', '1000', '680.00', '1000', '2014-01-15'),
(70010, 'P220', '5', '6000', '999.99', '6000', '2014-01-15'),
(70010, 'P240', '6', '6000', '999.99', '2000', '2014-01-15'),
(70010, 'R080', '7', '10000', '999.99', '10000', '2014-01-15'),
(70011, 'I105', '1', '1000', '600.00', '1000', '2014-01-15'),
(70020, 'B001', '1', '200', '140.00', NULL, NULL),
(70020, 'B002', '2', '200', '140.00', NULL, NULL),
(70025, 'I100', '1', '5', '590.00', '1000', '2014-01-15'),
(70025, 'I105', '2', '500', '590.00', '500', '2014-01-15'),
(70210, 'I100', '1', '1000', '470.00', '1000', '2014-01-15'),
(70250, 'B001', '1', '10', '140.00', '0', '2017-01-05'),
(70250, 'P220', '2', '10000', '999.99', '10000', '2014-01-15'),
(70250, 'P230', '1', '15000', '999.99', '12000', '2014-01-15'),
(70300, 'I110', '1', '50', '790.00', '50', '2014-01-15'),
(70620, 'I105', '1', '200', '600.00', '200', '2014-01-15'),
(70625, 'I100', '1', '1000', '470.00', '1000', '2014-01-15'),
(70625, 'P220', '2', '10000', '999.99', '10000', '2014-01-15'),
(70658, 'B001', '1', '10', '140.00', '0', NULL),
(70658, 'B002', '2', '20', '185.00', '0', NULL),
(70659, 'D035', '2', '40', '40.00', '0', NULL),
(70659, 'I100', '1', '30', '500.00', '0', NULL),
(70659, 'I105', '3', '50', '500.00', '0', NULL);

--
-- Déclencheurs `ligcom`
--
DELIMITER $$
CREATE TRIGGER `ligcom_AFTER_DELETE` AFTER DELETE ON `ligcom` FOR EACH ROW BEGIN
	UPDATE produit set STKPHY = STKPHY + OLD.QTECDE where CODART = OLD.CODART;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `ligcom_AFTER_INSERT` AFTER INSERT ON `ligcom` FOR EACH ROW BEGIN
	UPDATE produit set STKPHY = STKPHY - NEW.QTECDE where CODART = NEW.CODART;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `ligcom_AFTER_UPDATE` AFTER UPDATE ON `ligcom` FOR EACH ROW BEGIN
	UPDATE produit set STKPHY = STKPHY - NEW.QTECDE + OLD.QTECDE where CODART = NEW.CODART;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `ligcom_BEFORE_INSERT` BEFORE INSERT ON `ligcom` FOR EACH ROW BEGIN
	DECLARE STOCK INT;
    DECLARE hasError boolean;
    SELECT STKPHY into STOCK from produit where CODART = NEW.CODART;
	if NEW.QTECDE > STOCK then
		set hasError = fn_noStock();
	end if;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `ligcom_BEFORE_UPDATE` BEFORE UPDATE ON `ligcom` FOR EACH ROW BEGIN
	DECLARE STOCK INT;
    DECLARE hasError boolean;
    SELECT STKPHY into STOCK from produit where CODART = NEW.CODART;
	if NEW.QTECDE > STOCK then
		set hasError = fn_noStock();
	end if;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `produit`
--

CREATE TABLE `produit` (
  `CODART` char(4) COLLATE latin1_general_ci NOT NULL,
  `LIBART` varchar(25) COLLATE latin1_general_ci NOT NULL,
  `STKALE` decimal(7,0) NOT NULL,
  `STKPHY` decimal(7,0) NOT NULL,
  `QTEANN` decimal(7,0) NOT NULL,
  `UNIMES` char(5) COLLATE latin1_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Contenu de la table `produit`
--

INSERT INTO `produit` (`CODART`, `LIBART`, `STKALE`, `STKPHY`, `QTEANN`, `UNIMES`) VALUES
('B001', 'Bande magnetique 1200', '20', '600', '240', 'unite'),
('B002', 'Bande magnétique 6250', '20', '460', '410', 'unite'),
('D035', 'CD R slim 80 mm', '40', '9720', '150', 'B010'),
('D050', 'CD R-W 80mm', '50', '4', '0', 'B010'),
('I100', 'Papier 1 ex continu', '100', '4312', '3500', 'B1000'),
('I105', 'Papier 2 ex continu', '75', '4650', '2300', 'B1000'),
('I108', 'Papier 3 ex continu', '200', '557', '3500', 'B500'),
('I110', 'Papier 4 ex continu', '10', '12', '63', 'B400'),
('P220', 'Pre-imprime commande', '500', '2500', '24500', 'B500'),
('P230', 'Pre-imprime facture', '500', '250', '12500', 'B500'),
('P240', 'Pre-imprime bulletin paie', '500', '3000', '6250', 'B500'),
('P250', 'Pre-imprime bon livraison', '500', '2500', '24500', 'B500'),
('P270', 'Pre-imprime bon fabricati', '500', '2500', '24500', 'B500'),
('R080', 'ruban Epson 850', '10', '2', '120', 'unite'),
('R132', 'ruban impl 1200 lignes', '25', '200', '182', 'unite');

--
-- Déclencheurs `produit`
--
DELIMITER $$
CREATE TRIGGER `produit_BEFORE_INSERT` BEFORE INSERT ON `produit` FOR EACH ROW BEGIN
	DECLARE libExists BOOLEAN DEFAULT FALSE;
	DECLARE libelle int;
	select count(LIBART) into libelle from produit where LIBART like NEW.LIBART;
    if libelle > 0 then
		SET libExists = fn_libExists();
    end if;
END
$$
DELIMITER ;

--
-- Index pour les tables exportées
--

--
-- Index pour la table `ACHAT`
--
ALTER TABLE `ACHAT`
  ADD PRIMARY KEY (`CODART`,`NUMFOU`),
  ADD KEY `NUMFOU` (`NUMFOU`);

--
-- Index pour la table `ACOMMANDER`
--
ALTER TABLE `ACOMMANDER`
  ADD PRIMARY KEY (`id`),
  ADD KEY `CODART` (`CODART`,`NUMFOU`);

--
-- Index pour la table `entcom`
--
ALTER TABLE `entcom`
  ADD PRIMARY KEY (`NUMCOM`),
  ADD KEY `FK_ENTCOM_FOURNIS` (`NUMFOU`);

--
-- Index pour la table `fournis`
--
ALTER TABLE `fournis`
  ADD PRIMARY KEY (`NUMFOU`);

--
-- Index pour la table `ligcom`
--
ALTER TABLE `ligcom`
  ADD PRIMARY KEY (`NUMCOM`,`CODART`),
  ADD KEY `FK_LIGCOM_PRODUIT` (`CODART`);

--
-- Index pour la table `produit`
--
ALTER TABLE `produit`
  ADD PRIMARY KEY (`CODART`);

--
-- AUTO_INCREMENT pour les tables exportées
--

--
-- AUTO_INCREMENT pour la table `ACOMMANDER`
--
ALTER TABLE `ACOMMANDER`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT pour la table `entcom`
--
ALTER TABLE `entcom`
  MODIFY `NUMCOM` mediumint(9) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=70660;
--
-- Contraintes pour les tables exportées
--

--
-- Contraintes pour la table `ACHAT`
--
ALTER TABLE `ACHAT`
  ADD CONSTRAINT `ACHAT_ibfk_1` FOREIGN KEY (`NUMFOU`) REFERENCES `fournis` (`NUMFOU`),
  ADD CONSTRAINT `ACHAT_ibfk_2` FOREIGN KEY (`CODART`) REFERENCES `produit` (`CODART`);

--
-- Contraintes pour la table `entcom`
--
ALTER TABLE `entcom`
  ADD CONSTRAINT `FK_ENTCOM_FOURNIS` FOREIGN KEY (`NUMFOU`) REFERENCES `fournis` (`NUMFOU`) ON DELETE SET NULL;

--
-- Contraintes pour la table `ligcom`
--
ALTER TABLE `ligcom`
  ADD CONSTRAINT `FK_LIGCOM_ENTCOM` FOREIGN KEY (`NUMCOM`) REFERENCES `entcom` (`NUMCOM`) ON DELETE CASCADE,
  ADD CONSTRAINT `FK_LIGCOM_PRODUIT` FOREIGN KEY (`CODART`) REFERENCES `produit` (`CODART`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
