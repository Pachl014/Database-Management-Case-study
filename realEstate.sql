DROP DATABASE IF EXISTS realEstate;
CREATE DATABASE IF NOT EXISTS realEstate;
SHOW databases;
USE realEstate;

CREATE TABLE Sales_office
(
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT
    ,office_name VARCHAR(50) NOT NULL
    ,state VARCHAR(50) NOT NULL
);
# CREATE TABLE Sales_office

CREATE TABLE employee
(    
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT
    ,full_name VARCHAR(50) NOT NULL
    ,Sales_office_id INT NOT NULL
    ,FOREIGN KEY (Sales_office_id) REFERENCES Sales_office (id)
);
# CREATE TABLE employee

CREATE TABLE property
(
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT
    ,property_name VARCHAR(50) NOT NULL
    ,state VARCHAR(150) NOT NULL
	,cost DECIMAL (10,2) NOT NULL
    ,Sales_office_id INT NOT NULL
    ,Sales_office_name VARCHAR(50) NOT NULL
    ,FOREIGN KEY (Sales_office_id) REFERENCES Sales_office(id)
    );
# CREATE TABLE property

CREATE TABLE owner
(    
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT
    ,full_name VARCHAR(50) NOT NULL
);
# CREATE TABLE owner

CREATE TABLE property_ownership
(
    percent_owned DECIMAL(5,2) NOT NULL
    ,property_id INT NOT NULL
    ,owner_id INT NOT NULL
    ,PRIMARY KEY (property_id, owner_id)
    ,FOREIGN KEY (property_id) REFERENCES property(id)
    ,FOREIGN KEY (owner_id) REFERENCES owner(id)
);
# CREATE TABLE part_used_line

CREATE TABLE property_message
(
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT
    ,message_date DATE NOT NULL
    ,message_time TIME NOT NULL
    ,message_text VARCHAR(200)  NOT NULL
);
# CREATE TABLE property_message

DELIMITER $$
CREATE PROCEDURE populateSales_officeTable()
BEGIN
INSERT INTO sales_office (office_name, state)
     VALUES  
			 ('Office 1', 'NSW')
            ,('Office 2', 'NSW')
            ,('Office 3', 'QLD')
            ,('Office 4', 'SA')
            ,('Office 5', 'TAS');
END;
$$

DELIMITER $$
CREATE PROCEDURE populateEmployeeTable()
BEGIN
INSERT INTO employee (full_name, Sales_office_id)
     VALUES   ('Sarah Smith',1)
             ,('Jeff Walton',2)
             ,('Elena Madsen',3)
             ,('Rudolf Smith',4)
             ,('Gilbert Anderson',1);
END
$$

DELIMITER $$
CREATE PROCEDURE populatePropertyTable()
BEGIN
INSERT INTO property (property_name, state, cost,Sales_office_id, Sales_office_name)
     VALUES   ('property 1','NSW',1000000,1,'Office 1')
			 ,('property 2','QLD',2000000,2,'Office 2')
			 ,('property 3','SA',3000000,3,'Office 3')
			 ,('property 4','TAS',4000000,4,'Office 4')
			 ,('property 5','VIC',5000000,1,'Office 1')
			 ,('property 6','WA',6000000,2,'Office 2')
             ,('property 7','NSW',7000000,3,'Office 3')
			 ,('property 8','QLD',8000000,4,'Office 4')
			 ,('property 9','SA',9000000,1,'Office 1')
             ,('property 10','TAS',10000000,2,'Office 2')
             ,('property 11','NSW',11000000,1,'Office 1')
			 ,('property 12','NSW',12000000,1,'Office 1')
			 ,('property 13','NSW',13000000,1,'Office 1')
			 ,('property 14','QLD',14000000,2,'Office 2')
			 ,('property 15','QLD',15000000,2,'Office 2');
END
$$

DELIMITER $$
CREATE PROCEDURE populateOwnerTable()
BEGIN
INSERT INTO owner (full_name)
     VALUES   ('John Doe')
             ,('Kara Sanchez')
             ,('Dillon James')
             ,('Maria Lee')
             ,('Emilia McKinley');
END
$$

DELIMITER $$
CREATE PROCEDURE populatePropertyOwnershipTable()
BEGIN
INSERT INTO property_ownership(Property_id, Owner_id, percent_owned)
VALUES
		(1, 1, 55)
        ,(1, 2, 45)
        ,(2, 3, 100)
        ,(3, 3, 100)
        ,(4, 4, 100)
        ,(6, 4, 25)
        ,(7, 4, 40)
        ,(6, 5, 75)
        ,(7, 5, 60);
END
$$


DELIMITER $$
CREATE PROCEDURE populatePropertyMessageTable()
BEGIN
INSERT INTO property_message (message_date, message_time, message_text)
     VALUES  ('2023-03-28', '04:05:03', 'message 1')
            ,('2023-03-29', '05:05:03', 'message 2')
            ,('2023-03-30', '06:05:03', 'message 3')
            ,('2023-03-31', '07:05:03', 'message 4');
END
$$

CALL populateSales_officeTable();
CALL populateEmployeeTable();
CALL populatePropertyTable();
CALL populateOwnerTable();
CALL populatePropertyOwnershipTable();
CALL populatePropertyMessageTable();


SELECT* FROM property
ORDER BY cost ASC; 

SELECT state, Sales_office_id, COUNT(*) AS num_properties
FROM realestate.property
GROUP BY state, Sales_office_id;

SELECT state, Sales_office_id, COUNT(*) AS num_properties
FROM property
WHERE state NOT IN ('VIC', 'WA')
GROUP BY state, Sales_office_id
ORDER BY state DESC;


SELECT 
    p.property_name,
    p.state,
    p.cost,
    so.office_name,
    o.full_name AS owner_name,
    po.percent_owned
FROM 
    property p
JOIN 
    Sales_office so ON p.Sales_office_id = so.id
LEFT JOIN 
    property_ownership po ON p.id = po.property_id
LEFT JOIN 
    owner o ON po.owner_id = o.id
ORDER BY 
    p.id ASC;
    
-- METHOD 1
SELECT 
    p.id,
    p.property_name,
    p.state,
    p.cost,
    so.office_name,
    IFNULL(o.full_name, 'No owner') AS owner_name,
    po.percent_owned
FROM 
    property AS p
INNER JOIN 
    Sales_office AS so ON p.Sales_office_id = so.id
LEFT JOIN 
    property_ownership AS po ON p.id = po.property_id
LEFT JOIN 
    owner AS o ON po.owner_id = o.id
WHERE 
    p.state <> 'VIC' AND p.state <> 'WA'
ORDER BY 
    p.id ASC;
    
-- METHOD 2
SELECT 
    p.id,
    p.property_name,
    p.state,
    p.cost,
    so.office_name,
    IFNULL(o.full_name, 'No owner') AS owner_name,
    po.percent_owned
FROM 
    property AS p
INNER JOIN 
    Sales_office AS so ON p.Sales_office_id = so.id
LEFT JOIN 
    property_ownership AS po ON p.id = po.property_id
LEFT JOIN 
    owner AS o ON po.owner_id = o.id
WHERE 
    p.state NOT IN ('VIC', 'WA')
ORDER BY 
    p.id ASC;
    
SELECT id, full_name FROM employee
UNION
SELECT id, full_name FROM owner;


SELECT p.property_name, p.state, p.cost, so.office_name
FROM property p
JOIN (
    SELECT id, office_name
    FROM Sales_office
    WHERE office_name = 'Office 1'
) so ON p.Sales_office_id = so.id
ORDER BY p.id ASC;


SELECT 
    p.property_name,
    o.full_name AS owner_name,
    po.percent_owned,
    ROUND(po.percent_owned * p.cost / 100, 0) AS amount_paid
FROM 
    property p
JOIN 
    property_ownership po ON p.id = po.property_id
JOIN 
    owner o ON po.owner_id = o.id
WHERE 
    o.full_name IN ('Maria Lee', 'Emilia McKinley');
    

SELECT * FROM employee WHERE full_name LIKE '%Smith%';

-- CREATE A REPORT
CREATE OR REPLACE VIEW `Property Report` AS
SELECT 
    p.property_name,
    p.state,
    p.cost,
    so.office_name,
    IFNULL(o.full_name, 'No owner') AS owner_name,
    po.percent_owned
FROM 
    property p
INNER JOIN 
    Sales_office so ON p.Sales_office_id = so.id
LEFT JOIN 
    property_ownership po ON p.id = po.property_id
LEFT JOIN 
    owner o ON po.owner_id = o.id
ORDER BY 
    p.id ASC;  
    

-- CREATE VIEW
CREATE OR REPLACE VIEW `Maria's Property` AS
SELECT 
    p.property_name,
    p.state,
    p.cost,
    so.office_name,
    o.full_name AS owner_name,
    po.percent_owned
FROM 
    property p
JOIN 
    property_ownership po ON p.id = po.property_id
JOIN 
    owner o ON po.owner_id = o.id
JOIN 
    Sales_office so ON p.Sales_office_id = so.id
WHERE 
    o.full_name LIKE 'Maria Lee%';
    
DROP VIEW `maria's property`;

DELIMITER $$
CREATE PROCEDURE `retrieveProperty`()
BEGIN
    SELECT 
        p.property_name,
        p.state,
        p.cost,
        so.office_name,
        o.full_name AS owner_name,
        po.percent_owned
    FROM 
        property p
    INNER JOIN 
        property_ownership po ON p.id = po.property_id
    INNER JOIN 
        owner o ON po.owner_id = o.id
    INNER JOIN 
        Sales_office so ON p.Sales_office_id = so.id;
END
$$

DELIMITER $$
CREATE PROCEDURE  updatePropertyCost (
    IN property_id INT,
    IN new_cost INT)
BEGIN 
UPDATE property
SET  cost = new_cost
WHERE id = property_id;
END
$$

CALL updatePropertyCost(3, 1500000);
 
DROP PROCEDURE IF EXISTS updatePropertyCost;

-- Inserting a record with negative cost
INSERT INTO property (property_name, state, cost, Sales_office_id, Sales_office_name) 
VALUES ('Negative Property', 'VIC', -2000000, 1, 'Office 1');
-- CREATE TRIGGER
DELIMITER $$
CREATE TRIGGER before_property_insert
BEFORE INSERT ON property
FOR EACH ROW
BEGIN
    IF NEW.cost < 0 THEN
        SET NEW.cost = 0;
    END IF;
END;
$$

INSERT INTO property (property_name, state, cost, Sales_office_id, Sales_office_name) 
VALUES ('Negative Property', 'VIC', -2000000, 1, 'Office 1');

DELIMITER $$
CREATE TRIGGER updatePropertyCost
BEFORE UPDATE ON property
FOR EACH ROW
BEGIN
    IF NEW.cost <= 0 THEN
        SET NEW.cost = 0;
        
        INSERT INTO property_message (message_date, message_time, message_text)
        VALUES (CURDATE(), CURTIME(), CONCAT('Invalid cost entered for property id ', NEW.id));
    END IF;
END;
$$

UPDATE property
SET cost = -5000
WHERE id = 3;