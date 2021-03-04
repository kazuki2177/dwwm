-- Création du roles 

CREATE USER `marketing`@`localhost`

-- Privilege marketing catégories

GRANT SELECT, UPDATE, DELETE, INSERT
on gescom_eval.categories
TO `marketing`@`localhost`

-- Privilege marketing products

GRANT SELECT, UPDATE, DELETE, INSERT
on gescom_eval.products
TO `marketing`@`localhost`