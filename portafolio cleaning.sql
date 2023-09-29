SELECT * FROM cleaning;


SELECT *FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME ='cleaning';

--Renombro las columnas
EXEC SP_RENAME 'cleaning.Id?empleado','Id', 'column';
EXEC SP_RENAME 'cleaning.Apellido','Last_name','column';
EXEC SP_RENAME 'cleaning.género','genre','column';
EXEC SP_RENAME 'cleaning.star_date','start_date','column';

-- conocer valores repetido por ID
SELECT Id, COUNT(*) AS rep FROM cleaning 
GROUP BY Id
HAVING COUNT(*)>1;

--crear tabla temporal con valores unicos
SELECT DISTINCT * INTO #temp_clean
FROM cleaning;

--se deja constancia de que la nueva tabla temporal no tiene vaores repetidos
SELECT Id, COUNT(*) AS rep FROM #temp_clean
GROUP BY Id
HAVING COUNT(*) >1;

--se cambia el nombre de la tabla celaning por 'DUP' con el fin de que podamos mas adelante crear una nueva tabla llamada 'cleaning'
EXEC sp_rename 'cleaning','dup';
SELECT *FROM DUP;

--se crea una nueva tabla llamada 'cleaning', con los valores de la tabla temporal
SELECT * INTO cleaning
FROM #temp_clean;

-- se corrobora que la tabla no tenga valores repetidos
SELECT Id, COUNT(*) AS rep 
FROM cleaning
GROUP BY Id
HAVING COUNT(*) >1 ;

SELECT *FROM cleaning;

--Se corrobora que la columna 'Name' tiene valores con esapcios innecesarios

SELECT 
	Name
FROM cleaning
		WHERE
		DATALENGTH(Name)-DATALENGTH(TRIM(Name)) >0;

--Se actualizan los valores de la columna 'Name' con el fin de eliminar los espacios 
UPDATE cleaning
	SET Name = TRIM(Name)
		WHERE
			DATALENGTH(Name)-DATALENGTH(TRIM(Name)) > 0;

--Se corrobora de que los esapcios fueron eliminados
SELECT 
	Name
FROM cleaning
		WHERE
		DATALENGTH(Name)-DATALENGTH(TRIM(Name)) >0;

SELECT *FROM cleaning


SELECT 
	Last_name
FROM cleaning
		WHERE
		DATALENGTH(Name)-DATALENGTH(TRIM(Name)) >0;

--La columna 'Last_name no tiene espacios basura

-- Quito los esapacios repetidos de la oclumna 'area'
UPDATE cleaning
SET area = REPLACE(REPLACE(REPLACE(area,'  ',' '),'  ',' '),'  ',' ');

SELECT *FROM cleaning;

--Como la mayoria de los datos de la tabla se expresan en ingles, se decide remplazar los valores de la columna 'genre', por su propia traduccion al ingles

SELECT genre,
	CASE
		WHEN genre ='hombre' THEN 'male'
		WHEN genre ='mujer' THEN 'female'
		ELSE 'NON'
	END
	FROM cleaning;

UPDATE cleaning
SET genre =
	CASE
		WHEN genre = 'hombre' THEN 'male'
		WHEN genre = 'mujer' THEN 'female'
		ELSE 'NON'
	END
	FROM cleaning;

/*
Utilizando la mimsa logica se actualiza la columna 'type' en dondese define el tipo de contrato y:
0 = contrato hibrido
1 = contrato presencial
*/

--Primero se cambia el tipo de dato de flot a varchar, ya que ahora ingresaremos una cadena de texto

ALTER TABLE cleaning
ALTER COLUMN type varchar(20);

--se confrima que el tipo de dato fue replazado a varchar(20)

SELECT *FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'cleaning'

--se actualiza la columna

UPDATE cleaning
SET type = 
	CASE
		WHEN type = '0' THEN 'hibrido'
		WHEN type = '1' THEN 'presencial'
		ELSE 'NON'
	END
	FROM cleaning;

SELECT *FROM cleaning;

--Ahora se tratara la columna 'salary'

SELECT salary FROM cleaning

--se eliminara el signo "$" y se eliminara el singo ",", y finalmente se cambiara el tipo de dato a decimal (15,2)

SELECT salary,
CAST(
TRIM(
REPLACE(REPLACE (salary,',',''),'$',''))
AS DECIMAL (15,2))
FROM cleaning;

UPDATE cleaning
SET salary = 
	CAST(
	TRIM(
	REPLACE(REPLACE (salary,'$',''),',',''))
	AS DECIMAL(15,2));

SELECT *FROM cleaning

--cambiamos el tipo de dato de la columna 'salary' de varchar a money

SELECT *FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='cleaning';

ALTER TABLE cleaning
ALTER COLUMN salary money


--Ahora limpiaremos y le daremos el mismo formato a todas las fechas de la tabla 'cleaning'

SELECT birth_date,
	CASE
	WHEN
		/*CHARINDEX('/', birth_date)>0 THEN FORMAT(CONVERT(DATE, birth_date, 101), 'yyyy/MM/DD')
		cuando CHARINDEX encuentre el signo "/ o -" en la posicion x, cuando x>0, se ejecuta la query
		*/
		CHARINDEX('/', birth_date)>0 THEN FORMAT(CONVERT(DATE, birth_date, 101), 'yyyy/MM/DD')
	WHEN
		CHARINDEX('-', birth_date)>0 THEN FORMAT(CONVERT(DATE, birth_date, 101), 'yyyy/MM/DD')
	END
	FROM cleaning;


UPDATE cleaning
SET birth_date =
	CASE
		WHEN
		CHARINDEX('/', birth_date)>0 THEN FORMAT(CONVERT(DATE, birth_date, 101), 'yyyy/MM/DD')
		WHEN
		CHARINDEX('-', birth_date)>0 THEN FORMAT(CONVERT(DATE, birth_date, 101), 'yyyy/MM/DD')
		END
		FROM cleaning;

SELECT *FROM cleaning

SELECT *FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME =	'cleaning'

UPDATE cleaning
SET birth_date = CONVERT(DATE, birth_date, 101);

ALTER TABLE cleaning
ALTER COLUMN birth_date DATE


--a la columna 'start_date', se eliminaran todos los valores "00:00:00.000"

SELECT start_date, CAST(start_date AS DATE) AS start
FROM cleaning

UPDATE cleaning
SET start_date =
	CAST(start_date AS DATE);

ALTER TABLE cleaning
ALTER COLUMN start_date date;


--columna 'finish_date'

SELECT
	SUBSTRING(finish_date, 1, CHARINDEX(' ',finish_date)-1) AS finish_date,
	SUBSTRING(finish_date, CHARINDEX(' ', finish_date) +1, LEN(finish_date)) AS Hour
	FROM cleaning;

--se agrega una nueva colummna 'Hour' a la tabla para agregar la hora que esta en la columna 'finish_date'

ALTER TABLE cleaning
ADD  Hour varchar(30)

-- se actualiza la tabla dividiendo la columna 'finish_date' en 'finish_date y 'Hour'

UPDATE cleaning
SET finish_date =
	/*se divide la columna cuando el CHARINDEX encuentre un valor ' '
	SUBSTRING(finish_date, 1, CHARINDEX(' ',finish_date)-1),
	*/
	SUBSTRING(finish_date, 1, CHARINDEX(' ',finish_date)-1),
	/*
	A la nueva columna 'Hour' se se le agregan los valores que son reultado de dividir la columna 'finish_date'
	en donde CHARINDEX(' ', finish_date) +1, LEN(finish_date))
	me da la ubicacion y el numero de caracteres a insertar
	*/
	Hour =
	SUBSTRING(finish_date, CHARINDEX(' ', finish_date) +1, LEN(finish_date))
	FROM cleaning;
	

SELECT *FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME ='cleaning';

--'hour' y 'finish date' aun tienen el tipo de dato como varhcar(x), por lo que cambiaremos este tipo de dato al correspondiente
--como la columna 'Hour' contiene el datos como '00:00:00 UTC', crearemos otra columna en donde alojaremos la zona horaria 

SELECT *FROM cleaning;

SELECT
	SUBSTRING(Hour, 1 , CHARINDEX(' ', Hour)-1) AS Hour,
	SUBSTRING(Hour, CHARINDEX(' ', Hour)+1, LEN(Hour)) AS Time_zone
	FROM cleaning;

ALTER TABLE cleaning
ADD Time_zone VARCHAR(5);

UPDATE cleaning
SET	 Hour = 
	SUBSTRING(Hour, 1 , CHARINDEX(' ', Hour)-1),
	Time_zone =
	SUBSTRING(Hour, CHARINDEX(' ', Hour)+1, LEN(Hour))
	FROM cleaning;

--Se hacen los utlimos cambios de los tipos de datos

ALTER TABLE cleaning
ALTER COLUMN Hour TIME;

ALTER TABLE cleaning
ALTER COLUMN finish_date DATE;


SELECT *FROM cleaning;

--Se corrobora que todas las columnas tengan el tipo de dato adecuado

SELECT *FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='cleaning';

--Se cuenta la cantidad de datos de cada columna 

SELECT 
	COUNT(ID) AS ID,
	COUNT(Name) AS Name,
	COUNT(Last_name) AS Last_name,
	COUNT(birth_date) AS birth_date,
	COUNT(genre) AS genre,
	COUNT(area) AS area,
	COUNT(salary) AS salary,
	COUNT(start_date) AS start_date,
	COUNT(finish_date) AS finish_date,
	COUNT(type) AS type,
	COUNT(Hour) AS Hour,
	COUNT(Time_zone) AS Time_zone
FROM cleaning;

--La cantidad de valores 'NULL' de la columna 'Promotion_date' es demasiado alta, entonces se opta por eliminar dicha columna

ALTER TABLE cleaning
Drop column promotion_date;


--Tabla 'cleaning' limpia, con los valores parametrizados y lista para analizar

SELECT *FROM cleaning;




