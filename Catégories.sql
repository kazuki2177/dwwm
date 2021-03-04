DROP TABLE `categories`;

DROP TABLE IF EXISTS `categories`;
CREATE TABLE IF NOT EXISTS `categories` (
  `cat_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `cat_name` varchar(50) NOT NULL,
  `cat_parent_id` int(10) UNSIGNED DEFAULT NULL,
  PRIMARY KEY (`cat_id`),
  KEY `cat_parent_id` (`cat_parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `categories` (`cat_id`,`cat_name`,`cat_parent_id`) VALUES (1,"Nyssa",9),(2,"Merrill",6),(3,"Wing",9),(4,"Gary",1),(5,"Rogan",1),(6,"Otto",5),(7,"Gisela",3),(8,"Avram",9),(9,"Aidan",6),(10,"Brady",9);
INSERT INTO `categories` (`cat_id`,`cat_name`,`cat_parent_id`) VALUES (11,"Latifah",2),(12,"Russell",1),(13,"Luke",7),(14,"Winter",4),(15,"Chancellor",6),(16,"Tate",3),(17,"Drake",2),(18,"Ora",8),(19,"Sophia",9),(20,"Regan",2);
INSERT INTO `categories` (`cat_id`,`cat_name`,`cat_parent_id`) VALUES (21,"Stone",6),(22,"Zephr",5),(23,"Berk",7),(24,"Cleo",1),(25,"Holly",5),(26,"Yoshi",2),(27,"Armando",5),(28,"Marsden",5),(29,"Jada",6),(30,"Rafael",2);
INSERT INTO `categories` (`cat_id`,`cat_name`,`cat_parent_id`) VALUES (31,"Kai",9),(32,"Barrett",5),(33,"Jada",5),(34,"Anastasia",9),(35,"Duncan",10),(36,"Karyn",4),(37,"Jeanette",9),(38,"Hector",6),(39,"Dolan",9),(40,"Amal",4);
INSERT INTO `categories` (`cat_id`,`cat_name`,`cat_parent_id`) VALUES (41,"Marcia",9),(42,"Karen",8),(43,"Rose",4),(44,"Ima",2),(45,"Dora",7),(46,"Xyla",3),(47,"Moana",3),(48,"Cailin",4),(49,"Deacon",5),(50,"Robin",1);
INSERT INTO `categories` (`cat_id`,`cat_name`,`cat_parent_id`) VALUES (51,"Iliana",10),(52,"Willa",5),(53,"Madaline",3),(54,"Octavius",6),(55,"Sawyer",2),(56,"Ciara",8),(57,"Hanae",5),(58,"Zelda",8),(59,"Madison",3),(60,"Glenna",5);
INSERT INTO `categories` (`cat_id`,`cat_name`,`cat_parent_id`) VALUES (61,"Adara",4),(62,"Ulla",3),(63,"Kiayada",6),(64,"Tanner",10),(65,"Brennan",1),(66,"Ivana",3),(67,"Driscoll",5),(68,"Mannix",1),(69,"Jescie",8),(70,"Dorothy",7);
INSERT INTO `categories` (`cat_id`,`cat_name`,`cat_parent_id`) VALUES (71,"Fatima",10),(72,"Caesar",2),(73,"Camille",8),(74,"Stephen",2),(75,"Hyacinth",4),(76,"Mia",1),(77,"Guinevere",2),(78,"Alisa",7),(79,"Ali",7),(80,"Illiana",4);
INSERT INTO `categories` (`cat_id`,`cat_name`,`cat_parent_id`) VALUES (81,"Yolanda",7),(82,"Lunea",9),(83,"Alexis",5),(84,"Ainsley",2),(85,"Wallace",2),(86,"Cairo",9),(87,"Upton",4),(88,"Deirdre",3),(89,"Hiroko",8),(90,"Ivory",8);
INSERT INTO `categories` (`cat_id`,`cat_name`,`cat_parent_id`) VALUES (91,"Quinn",3),(92,"Germaine",10),(93,"Xanthus",5),(94,"Wynter",2),(95,"Kylee",8),(96,"Felicia",1),(97,"Quinn",7),(98,"Gannon",6),(99,"Hedwig",5),(100,"Gareth",2);
