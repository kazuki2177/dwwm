-- Gescom requetes 

-- Question 1

select CONCAT(`emp_lastname`,' ', `emp_firstname`) as 'Nom Prénom', `emp_children` as 'Enfants'
from `employees`
where `emp_children` != 0
order by `emp_children` desc

-- Question 2

select `cus_lastname` as 'Nom', `cus_firstname` as 'prenom', `cus_countries_id` as 'Pays de résidence'
from `customers`
where `cus_countries_id` != 'FR'

-- Question 3

select `cus_city` as 'Ville', `cus_countries_id` as 'Pays', `cou_name` as 'Nom'
from `customers`
join `countries` on `cus_countries_id` = `cou_id`
order by `cus_city`

-- Question 4

select `cus_lastname` as 'Client', `cus_update_date` as 'Date de modification'
from `customers`
where `cus_update_date` != "NULL"

-- Question 5

select * from `customers`
where `cus_city` like '%divos%'

-- Question 6

select `pro_id` as 'Identifiant', `pro_name` as 'Nom', `pro_price` as 'Prix'
from `products`
where `pro_price`= (select min(`pro_price`) from `products`)

-- Question 7

select `pro_id` as 'Identifiant', `pro_ref` as 'Référence', `pro_name` as 'Nom'
from `products`
where `pro_id` not in (select `ode_pro_id` from `orders_details`)  
ORDER BY `Identifiant` ASC

-- Le 42 ne donne pas le résultat exact à la demande de l'exercice et après plusieur essais je ne sais pas comment faire pour avoir le bon

-- Question 8 

select `pro_id` as 'Id', `pro_ref` as 'Référence', `pro_name` as 'Nom', `cus_id` as 'Id client', `ord_id` as 'Id commande', `ode_id` as 'Id détail commande'
from `customers`
join `orders` on `cus_id`=`ord_cus_id`
join `orders_details` on `ode_ord_id`=`ord_id`
join `products` on `pro_id`=`ode_pro_id`
where `cus_lastname` = "Pikatchien"

-- Question 9

select `cat_id` as 'Id catégorie', `cat_name` as 'Nom', `pro_name` as 'Nom produit'
from `categories`
join `products` on `pro_cat_id`= `cat_id`
order by `cat_name` ASC, `pro_name` ASC

-- Question 10

select CONCAT(`emp1`.`emp_lastname`,'   ', `emp1`.`emp_firstname`) as 'Employé', `pos_libelle` as 'Poste', CONCAT(`emp2`.`emp_lastname`,'   ',`emp2`. `emp_firstname`) as 'Supérieur' 
from `employees` as `emp1` 
join `posts`on `pos_id` = `emp1`.`emp_pos_id`
join `employees` as `emp2` on `emp2`.`emp_id` =`emp1`.`emp_superior_id`
order by `emp1`.`emp_lastname`;

-- Emp1 et Emp2 pour permettre de différencier les employée et les supérieur 

-- Question 11

select `ode_discount` as 'Remise', `pro_id` as 'Numéro produit', `pro_name` as 'Nom', `ord_id` as 'Numéro', `ode_id` as 'Numéro ligne'
from `orders`
join `orders_details` on `ode_ord_id`=`ord_id`
join `products` on `pro_id`=`ode_pro_id`
where `ode_discount` = (select max(`ode_discount`) from `orders_details`)

-- Question 13

select count(*) as 'Nb clients Canada'
from `customers`
join `countries` on `cou_id` = `cus_countries_id`
where `cou_name` = "Canada"

-- Question 16

select `ode_id` as 'Numéro', `ode_unit_price` as 'Prix',`ode_discount` as 'Remise',`ode_quantity` as 'Quantité',`ode_ord_id` as 'Numéro commande',`ode_pro_id` as 'Produit',`ord_order_date` as 'Date'
from `orders`
join `orders_details` on `ode_ord_id`=`ord_id`
where year(`ord_order_date`) = 2020

-- Question 17

select distinct(`sup_id`) as 'Numéro', `sup_name` as 'Nom', `sup_city` as 'Ville', `cou_name` as 'Pays',`sup_address` as 'Adresse', `sup_zipcode` as 'Code postal', `sup_contact` as 'Contact',`sup_phone` as 'Téléphone', `sup_mail` as 'Email'
from `suppliers`
join `countries` on `sup_countries_id` = `cou_id` 
join `products` on `pro_sup_id`= `sup_id`
join `orders_details` on `ode_pro_id`= `pro_id`

-- Question 18

select round(sum( `ode_quantity` * (`ode_unit_price` - ( (`ode_unit_price` * `ode_discount`) / 100) ) ),2)   
from `orders`
join `orders_details` on `ode_ord_id`=`ord_id`
where year(`ord_order_date`) = 2020;

-- Question 19

select avg(pannier) as 'Moyenne pannier moyen' from (select sum(`ode_quantity` * (`ode_unit_price` - ( (`ode_unit_price` * `ode_discount`) / 100) )) as `pannier`
            from `orders_details`
            group by `ode_ord_id`) as `sous`

-- Trouver sur internet, j'avais que des erreurs donc j'ai trouver un code que j'ai adapter à cette exercice 

-- Question 20

select `ord_id` as 'Numéro',`ord_order_date` as 'Date',  sum(`ode_quantity` * `ode_unit_price`) as 'Total', `cus_lastname` as 'Nom'
from `customers`
join `orders` on `cus_id`=`ord_cus_id`
join `orders_details` on `ode_ord_id`=`ord_id`
group by `ode_ord_id`
order by sum(`ode_quantity` * `ode_unit_price`) desc

-- Question 22

UPDATE `products` 
set `pro_ref` = "Camper", `pro_price` = `pro_price` * 0.9, `pro_update_date` = now()
where  `pro_ref` = "barb004";

-- Question 23

UPDATE `products` 
set `pro_price` = `pro_price` * 1.011,  `pro_update_date` = now()
where `pro_id`= 25 or `pro_id`= 27

-- Question 24

DELETE FROM `products`
where `pro_cat_id` = (select `cat_id` from `categories` where `cat_name`="Tondeuses électriques") and `pro_id` not in (select `ode_pro_id` from `orders_details`)