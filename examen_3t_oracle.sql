-- Ejercicio 2

CREATE TYPE tFamilia AS OBJECT (
  idFamilia INT,
  familia VARCHAR2(100)
);

-- Ejercicio 3

CREATE TABLE FAMILIA OF tFamilia;
ALTER TABLE FAMILIA ADD PRIMARY KEY (idFamilia);

-- Ejercicio 4
insert into familia values (1, 'Aves');
insert into familia values (2, 'Mamíferos');
insert into familia values (3, 'Peces');

SELECT * FROM FAMILIA;

-- Ejercicio 5
CREATE TYPE tNombres AS VARRAY(20) OF VARCHAR2(50);

-- Ejercicio 6
CREATE TYPE tAnimal AS OBJECT (
  idAnimal int,
  idFamilia int,
  Animal VARCHAR2(50),
  nombres tNombres,
  MEMBER FUNCTION ejemplares RETURN VARCHAR2
) NOT FINAL;

-- Implementación de la función ejemplares en el tipo objeto tAnimal
CREATE OR REPLACE TYPE BODY tAnimal AS
  MEMBER FUNCTION ejemplares RETURN VARCHAR2 IS
    numEjemplares NUMBER := self.nombres.COUNT;
    especie VARCHAR2(50) := self.Animal;
    mensaje VARCHAR2(100) := 'Hay ' || numEjemplares || ' ejemplares de la especie ' || especie;
  BEGIN
    RETURN mensaje;
  END;
END;

-- Ejercico 7
CREATE TABLE ANIMAL OF tAnimal;

-- Ejercico 8
ALTER TABLE ANIMAL ADD PRIMARY KEY (idAnimal);
ALTER TABLE ANIMAL ADD CONSTRAINT fk_idFamilia FOREIGN KEY (idFamilia) REFERENCES FAMILIA(idFamilia);

SELECT * FROM ANIMAL;

-- Ejercico 9
-- Inserción de las aves
INSERT INTO Animal VALUES (1, 1, 'Garza Real', tNombres('Calíope', 'Izaro'));
INSERT INTO Animal VALUES (2, 1, 'Cigüeña Blanca', tNombres('Perica', 'Clara ','Miranda'));
INSERT INTO Animal VALUES (3, 1, 'Gorrión', tNombres('Coco', 'Roco', 'Loco', 'Peco', 'Rico'));

-- Inserción de los mamíferos
INSERT INTO Animal VALUES (4, 2, 'Zorro', tNombres('Lucas', 'Mario'));
INSERT INTO Animal VALUES (5, 2, 'Lobo', tNombres('Pedro', 'Pablo'));
INSERT INTO Animal VALUES (6, 2, 'Ciervo', tNombres('Bravo', 'Listo', 'Rojo', 'Astuto'));

-- Inserción de los peces
INSERT INTO Animal VALUES (7, 3, 'Pez globo', tNombres('Globix', 'Blandito'));
INSERT INTO Animal VALUES (8, 3, 'Pez payaso', tNombres('Nemo', 'Naymer'));
INSERT INTO Animal VALUES (9, 3, 'Ángel llama', tNombres('Luciérnaga', 'Fueguix'));

-- Ejercico 10

SELECT a.Animal, f.familia, a.ejemplares() AS num_ejemplares
FROM Animal a
JOIN Familia f ON a.idFamilia = f.idFamilia;





