/* Pregunta 01: Usando la tabla o pestaña de clientes, por favor escribe una consulta SQL que muestre Título, 
Nombre y Apellido y Fecha de Nacimiento para cada uno de los clientes. No necesitarás hacer nada en Excel para esta.*/

SELECT Title, FirstName, LastName, DateOfBirth
FROM gambling.Customer;

/* Pregunta 02: Usando la tabla o pestaña de clientes, por favor escribe una consulta SQL que muestre 
el número de clientes en cada grupo de clientes (Bronce, Plata y Oro). Puedo ver visualmente que hay 
4 Bronce, 3 Plata y 3 Oro pero si hubiera un millón de clientes ¿cómo lo haría en Excel?*/

SELECT CustomerGroup, COUNT(*) AS NumeroClientes
FROM gambling.Customer
GROUP BY CustomerGroup;
-- En Excel, podemos contar los valores en cada grupo con una table dinámica.

/* Pregunta 03: El gerente de CRM me ha pedido que proporcione una lista completa de todos los datos para 
esos clientes en la tabla de clientes pero necesito añadir el código de moneda de cada jugador para que pueda enviar 
la oferta correcta en la moneda correcta. Nota que el código de moneda no existe en la tabla de clientes sino
 en la tabla de cuentas. Por favor, escribe el SQL que facilitaría esto. 
 ¿Cómo lo haría en Excel si tuviera un conjunto de datos mucho más grande?*/
 
 SELECT c.*, a.CurrencyCode
FROM gambling.Customer c
JOIN gambling.Account a ON c.CustId = a.CustId;

/* En Excel, podemos usar la función BUSCARV o XLOOKUP para buscar el código de moneda de la tabla de Account y 
combinarlo con los datos de Customer*/
 
/* Pregunta 04: Ahora necesito proporcionar a un gerente de producto un informe resumen que muestre, 
por producto y por día, cuánto dinero se ha apostado en un producto particular. TEN EN CUENTA que las transacciones 
están almacenadas en la tabla de apuestas y hay un código de producto en esa tabla que se requiere buscar 
(classid & categoryid) para determinar a qué familia de productos pertenece esto. 
Por favor, escribe el SQL que proporcionaría el informe. Si imaginas que esto fue un conjunto de datos 
mucho más grande en Excel, ¿cómo proporcionarías este informe en Excel?*/

SELECT 
    p.product, 
    STR_TO_DATE(b.BetDate, '%d/%m/%Y') AS BetDate_format,
    SUM(b.Bet_Amt) AS Total_Apostado
FROM gambling.Betting b
JOIN gambling.product p
ON   b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
GROUP BY 
    p.product, 
    BetDate_format
ORDER BY 
    p.product, 
    BetDate_format;


-- En  Excel utilizaría de tablas dinámicas y funciones de búsqueda.

/* Pregunta 05: Acabas de proporcionar el informe de la pregunta 4 al gerente de producto, ahora él me ha enviado 
un correo electrónico y quiere que se cambie. ¿Puedes por favor modificar el informe resumen para que solo resuma 
las transacciones que ocurrieron el 1 de noviembre o después y solo quiere ver transacciones de Sportsbook. 
Nuevamente, por favor escribe el SQL abajo que hará esto. Si yo estuviera entregando esto vía Excel, ¿cómo lo haría?*/

SELECT 
    p.product, 
    STR_TO_DATE(b.BetDate, '%d/%m/%Y') AS BetDate_format,
    SUM(b.Bet_Amt) AS Total_Apostado
FROM gambling.betting b
JOIN gambling.product p
ON   b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
WHERE STR_TO_DATE(b.BetDate, '%d/%m/%Y') >= '2012-11-01'
    AND p.product = 'Sportsbook'
GROUP BY 
    p.product, 
    BetDate_format
ORDER BY 
    p.product, 
    BetDate_format;
    
/*En Excel aplicaría filtros para seleccionar las transacciones después del 1 de noviembre y el producto "Sportsbook",
 y luego usarías una tabla dinámica para resumir el total de apuestas por producto y fecha.*/
 
/*Pregunta 06: Como suele suceder, el gerente de producto ha mostrado su nuevo informe a su director y ahora 
él también quiere una versión diferente de este informe. Esta vez, quiere todos los productos pero divididos 
por el código de moneda y el grupo de clientes del cliente, en lugar de por día y producto. También le gustaría solo 
transacciones que ocurrieron después del 1 de diciembre. Por favor, escribe el código SQL que hará esto.*/
 
 SELECT 
    p.product, 
    a.CurrencyCode,
    c.CustomerGroup, 
    SUM(b.Bet_Amt) AS Total_Apostado
FROM gambling.betting b
JOIN gambling.product p
ON   b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
JOIN gambling.Account a
ON a.AccountNo = b.AccountNo
JOIN gambling.Customer c
ON c.CustId = a.CustId
WHERE STR_TO_DATE(b.BetDate, '%d/%m/%Y') >= '2012-12-01' 
GROUP BY 
    p.product, 
    a.CurrencyCode, 
    c.CustomerGroup
ORDER BY 
    p.product, 
    Total_Apostado DESC, 
    c.CustomerGroup;
    
/*Pregunta 07: Nuestro equipo VIP ha pedido ver un informe de todos los jugadores independientemente de si han hecho 
algo en el marco de tiempo completo o no. En nuestro ejemplo, es posible que no todos los jugadores hayan estado 
activos. Por favor, escribe una consulta SQL que muestre a todos los jugadores Título, Nombre y Apellido y un resumen 
de su cantidad de apuesta para el período completo de noviembre.*/

SELECT c.Title,
	c.FirstName,
    c.LastName,
    SUM(b.Bet_Amt) AS Total_Apostado
FROM gambling.Customer c
LEFT JOIN gambling.Account a
ON a.CustId = c.CustId
LEFT JOIN gambling.betting b
ON b.AccountNo = a.AccountNo
WHERE STR_TO_DATE(b.BetDate, '%d/%m/%Y') >= '2012-11-01' AND STR_TO_DATE(b.BetDate, '%d/%m/%Y') < '2012-12-01'
GROUP BY 
    c.Title, 
    c.FirstName, 
    c.LastName
ORDER BY 
    Total_Apostado DESC;



/*Pregunta 08: Nuestros equipos de marketing y CRM quieren medir el número de jugadores que juegan más de un producto. 
¿Puedes por favor escribir 2 consultas, una que muestre el número de productos por jugador y otra que muestre 
jugadores que juegan tanto en Sportsbook como en Vegas?*/

SELECT AccountNo,
	COUNT(DISTINCT Product) AS Num_products
FROM gambling.betting
GROUP BY AccountNo
ORDER BY Num_products;

SELECT 
    AccountNo,
    COUNT(DISTINCT Product) AS Num_products
FROM gambling.betting
WHERE Product IN ('Sportsbook', 'Vegas') 
GROUP BY AccountNo
HAVING COUNT(DISTINCT Product) = 2 
ORDER BY Num_products;

/*Pregunta 09: Ahora nuestro equipo de CRM quiere ver a los jugadores que solo juegan un producto, por favor escribe 
código SQL que muestre a los jugadores que solo juegan en sportsbook, usa bet_amt > 0 como la clave. Muestra cada 
jugador y la suma de sus apuestas para ambos productos.*/

SELECT 
    AccountNo,
    SUM(Bet_Amt) AS Total_Apostado,
    Product
FROM gambling.betting
WHERE Product = 'Sportsbook' AND Bet_Amt > 0
GROUP BY AccountNo,
	Product
ORDER BY Total_Apostado;

/*Pregunta 10: La última pregunta requiere que calculemos y determinemos el producto favorito de un jugador. Esto se 
puede determinar por la mayor cantidad de dinero apostado. Por favor, escribe una consulta que muestre el producto 
favorito de cada jugador*/

SELECT
	AccountNo,
    Product AS Prodcut_Fav,
	Total_Apostado AS Max_Apuesta
FROM (
    SELECT 
        AccountNo,
        Product,
        SUM(Bet_Amt) AS Total_Apostado,
        RANK() OVER (PARTITION BY AccountNo ORDER BY SUM(Bet_Amt) DESC) AS ranking
    FROM gambling.betting
    GROUP BY AccountNo, Product
) AS Products_rank
WHERE ranking = 1
ORDER BY Prodcut_Fav,
	Max_Apuesta DESC;
    
/*Pregunta 11: Escribe una consulta que devuelva a los 5 mejores estudiantes basándose en el GPA*/

CREATE TABLE Student (

    student_id INT,
    student_name VARCHAR(50),
    city VARCHAR(50),
    school_id INT,
    GPA FLOAT
    );
INSERT INTO Student 
VALUES 
(1001,	'Peter Brebec',	'New York',	1, 4),
(1002,	'John Goorgy',	'San Francisco', 2,	3.1),
(2003,	'Brad Smith',	'New York',	3, 2.9),
(1004,	'Fabian Johns',	'Boston', 5, 2.1),
(1005,	'Brad Cameron',	'Stanford',	1, 2.3),
(1006,	'Geoff Firby',	'Boston',	5,	1.2),
(1007,	'Johnny Blue',	'New Haven', 2, 3.8),
(1008,	'Johse Brook',	'Miami', 2, 3.4);

SELECT * FROM gambling.Student;

CREATE TABLE School (
    school_id INT,
    school_name VARCHAR(50),
    city VARCHAR(50)
    );

INSERT INTO School 
VALUES   
(1,	'Stanford',	'Stanford'),
(2,	'University of California',	'San Francisco'),
(3,	'Harvard University',	'New York'),
(4,	'MIT',	'Boston'),
(5,	'Yale',	'New Haven'),
(6,	'University of Westminster',	'London'),
(7,	'Corvinus University',	'Budapest');

SELECT * FROM gambling.School;

SELECT * 
FROM (
    SELECT 
        student_id,
        student_name,
        city,
        school_id,
        GPA,
        RANK() OVER (ORDER BY GPA DESC) AS Ranks
    FROM gambling.Student
) AS ranked_students
WHERE Ranks <= 5;
    
/*Pregunta 12: Escribe una consulta que devuelva el número de estudiantes en cada escuela. 
(¡una escuela debería estar en la salida incluso si no tiene estudiantes!)*/

SELECT 
    sc.school_name, 
    COUNT(st.student_id) AS Num_est
FROM 
    gambling.School sc
    LEFT JOIN gambling.Student st 
    ON sc.school_id = st.school_id
GROUP BY 
    sc.school_name
ORDER BY 
    Num_est DESC;
    
/*Pregunta 13: Escribe una consulta que devuelva los nombres de los 3 estudiantes con el GPA más alto de cada 
universidad.*/

SELECT sc.school_name,
	rs.GPA,
    rs.student_name
FROM (
    SELECT 
        student_id,
        student_name,
        city,
        school_id,
        GPA,
        RANK() OVER (PARTITION BY school_id ORDER BY GPA DESC) AS Ranks
    FROM gambling.Student st
) AS rs
RIGHT JOIN gambling.School sc
ON rs.school_id = sc.school_id
WHERE Ranks <= 3
ORDER BY rs.GPA DESC;
