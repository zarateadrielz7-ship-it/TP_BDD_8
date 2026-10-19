-- =====================================================
-- JARVIS - Sistema de Asistente Personal Multi-IA
-- TP N° 8 - Base de Datos 1 2026 - IPET 247
-- Motor: MySQL / MariaDB (XAMPP - phpMyAdmin)
-- =====================================================


-- =====================================================
-- PARTE 1: CREACIÓN DE LA BASE DE DATOS Y LAS TABLAS
-- =====================================================

-- Creo la base de datos (si no existe) y la uso
CREATE DATABASE IF NOT EXISTS jarvis_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;
USE jarvis_db;

-- Borro las tablas si ya existían, así puedo correr el script varias veces.
-- Se borran primero las que tienen FOREIGN KEY (las "hijas").
DROP TABLE IF EXISTS conversaciones;
DROP TABLE IF EXISTS tareas;
DROP TABLE IF EXISTS etiquetas;
DROP TABLE IF EXISTS cerebros;

-- Tabla cerebros: los motores de IA (Mati, Gepeto, Gemita, Claudio)
CREATE TABLE cerebros (
    id_cerebro   INT AUTO_INCREMENT,
    nombre       VARCHAR(50)  NOT NULL UNIQUE,
    motor        VARCHAR(50)  NOT NULL,
    especialidad VARCHAR(100),
    activo       TINYINT(1)   NOT NULL DEFAULT 1,   -- 1 = activo, 0 = inactivo
    fecha_alta   DATE         NOT NULL,
    PRIMARY KEY (id_cerebro)
) ENGINE=InnoDB;

-- Tabla etiquetas: categorías para organizar las tareas
CREATE TABLE etiquetas (
    id_etiqueta INT AUTO_INCREMENT,
    nombre      VARCHAR(40)  NOT NULL UNIQUE,
    descripcion VARCHAR(100),
    PRIMARY KEY (id_etiqueta)
) ENGINE=InnoDB;

-- Tabla tareas: cada tarea tiene un cerebro y una etiqueta
CREATE TABLE tareas (
    id_tarea       INT AUTO_INCREMENT,
    titulo         VARCHAR(100) NOT NULL,
    descripcion    TEXT,
    estado         ENUM('pendiente','en_progreso','completada') NOT NULL DEFAULT 'pendiente',
    prioridad      ENUM('baja','media','alta') NOT NULL DEFAULT 'media',
    fecha_creacion DATE NOT NULL,
    fecha_limite   DATE NULL,
    id_cerebro     INT  NOT NULL,
    id_etiqueta    INT  NOT NULL,
    PRIMARY KEY (id_tarea),
    FOREIGN KEY (id_cerebro)  REFERENCES cerebros(id_cerebro),
    FOREIGN KEY (id_etiqueta) REFERENCES etiquetas(id_etiqueta)
) ENGINE=InnoDB;

-- Tabla conversaciones: historial de mensajes con cada cerebro
-- id_tarea puede ser NULL (conversación que no es sobre una tarea)
CREATE TABLE conversaciones (
    id_conversacion INT AUTO_INCREMENT,
    id_cerebro      INT      NOT NULL,
    id_tarea        INT      NULL,
    mensaje_usuario TEXT     NOT NULL,
    respuesta_ia    TEXT,
    fecha_hora      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tokens_usados   INT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id_conversacion),
    FOREIGN KEY (id_cerebro) REFERENCES cerebros(id_cerebro),
    FOREIGN KEY (id_tarea)   REFERENCES tareas(id_tarea)
) ENGINE=InnoDB;

-- Índices para que las búsquedas por estado y por fecha sean más rápidas (RNF-02)
CREATE INDEX idx_tareas_estado        ON tareas(estado);
CREATE INDEX idx_conversaciones_fecha ON conversaciones(fecha_hora);


-- =====================================================
-- PARTE 2: DATOS DE EJEMPLO (todos inventados)
-- Primero se cargan las tablas "padre" y después las "hijas"
-- =====================================================

-- Cerebros (Gemita queda inactiva para probar el filtro de la consulta 1)
-- OJO: completar el motor de Mati con el que corresponda
INSERT INTO cerebros (nombre, motor, especialidad, activo, fecha_alta) VALUES
('Mati',    'Por definir', 'Orquestador general del asistente', 1, '2026-09-01'),
('Gepeto',  'ChatGPT',     'Redacción y organización',          1, '2026-09-01'),
('Gemita',  'Gemini',      'Búsqueda de información',           0, '2026-09-05'),
('Claudio', 'Claude',      'Programación y estudio',            1, '2026-09-10');

-- Etiquetas
INSERT INTO etiquetas (nombre, descripcion) VALUES
('Estudio',  'Tareas de la escuela y aprendizaje'),
('Trabajo',  'Tareas relacionadas con el trabajo'),
('Personal', 'Organización de la vida diaria');

-- Tareas (id_cerebro e id_etiqueta apuntan a los ids de arriba)
INSERT INTO tareas (titulo, descripcion, estado, prioridad, fecha_creacion, fecha_limite, id_cerebro, id_etiqueta) VALUES
('Estudiar para el parcial de BD',   'Repasar JOIN y GROUP BY',          'en_progreso', 'alta',  '2026-10-12', '2026-10-25', 4, 1),
('Resumir reuniones de la semana',   'Hacer un resumen de los puntos',   'pendiente',   'alta',  '2026-10-15', '2026-10-23', 1, 2),
('Organizar rutina semanal',         'Armar horarios de la semana',      'completada',  'media', '2026-09-28', '2026-10-05', 2, 3),
('Practicar consultas JOIN',         'Hacer 10 ejercicios de JOIN',      'pendiente',   'media', '2026-10-16', '2026-10-30', 4, 1),
('Redactar mail para el trabajo',    'Mail formal para pedir un cambio', 'completada',  'baja',  '2026-10-18', NULL,         2, 2);

-- Conversaciones (la última no tiene tarea: id_tarea = NULL)
INSERT INTO conversaciones (id_cerebro, id_tarea, mensaje_usuario, respuesta_ia, fecha_hora, tokens_usados) VALUES
(4, 1,    'Explicame la diferencia entre INNER JOIN y LEFT JOIN', 'INNER JOIN trae solo las filas que coinciden en ambas tablas...', '2026-10-12 14:30:00', 420),
(4, 1,    'Dame ejercicios de GROUP BY',                          'Acá van 3 ejercicios para practicar...',                      '2026-10-13 16:10:00', 380),
(1, 2,    'Resumí los puntos de la reunión del lunes',            'Los puntos principales fueron...',                            '2026-10-15 09:05:00', 250),
(2, 3,    'Armame una rutina semanal',                            'Lunes: escuela de 13 a 22...',                                '2026-09-28 20:15:00', 510),
(2, 5,    'Ayudame a redactar un mail formal',                    'Asunto: Solicitud de cambio de horario...',                   '2026-10-18 11:40:00', 300),
(1, NULL, 'Qué tengo pendiente para hoy?',                        'Tenés 2 tareas pendientes...',                                '2026-10-19 08:00:00', 150);


-- =====================================================
-- PARTE 3: LAS 10 CONSULTAS
-- =====================================================

-- Consulta 1:
-- Listar todos los cerebros activos, ordenados alfabéticamente por nombre.
-- (WHERE + ORDER BY)
SELECT id_cerebro, nombre, motor, especialidad
FROM cerebros
WHERE activo = 1
ORDER BY nombre ASC;


-- Consulta 2:
-- Listar las tareas pendientes con prioridad alta,
-- ordenadas por fecha límite (la más próxima primero).
-- (WHERE con AND + ORDER BY)
SELECT id_tarea, titulo, prioridad, fecha_limite
FROM tareas
WHERE estado = 'pendiente'
  AND prioridad = 'alta'
ORDER BY fecha_limite ASC;


-- Consulta 3:
-- Mostrar todas las tareas con el nombre del cerebro asignado
-- y el nombre de su etiqueta.
-- (INNER JOIN con 3 tablas)
SELECT t.id_tarea,
       t.titulo,
       t.estado,
       c.nombre AS cerebro,
       e.nombre AS etiqueta
FROM tareas t
INNER JOIN cerebros  c ON t.id_cerebro  = c.id_cerebro
INNER JOIN etiquetas e ON t.id_etiqueta = e.id_etiqueta
ORDER BY t.id_tarea;


-- Consulta 4:
-- Listar las tareas creadas durante octubre de 2026,
-- de la más reciente a la más antigua.
-- (WHERE con fechas usando BETWEEN + ORDER BY)
SELECT id_tarea, titulo, fecha_creacion
FROM tareas
WHERE fecha_creacion BETWEEN '2026-10-01' AND '2026-10-31'
ORDER BY fecha_creacion DESC;


-- Consulta 5:
-- Contar cuántas tareas hay en cada estado.
-- (COUNT + GROUP BY)
SELECT estado, COUNT(*) AS cantidad_tareas
FROM tareas
GROUP BY estado;


-- Consulta 6:
-- Mostrar cuántas tareas tiene asignadas cada cerebro,
-- ordenado de mayor a menor cantidad.
-- (JOIN + COUNT + GROUP BY + ORDER BY)
SELECT c.nombre AS cerebro, COUNT(t.id_tarea) AS cantidad_tareas
FROM cerebros c
INNER JOIN tareas t ON c.id_cerebro = t.id_cerebro
GROUP BY c.nombre
ORDER BY cantidad_tareas DESC;


-- Consulta 7:
-- Mostrar, por cada cerebro, la cantidad de conversaciones
-- y el promedio de tokens usados.
-- (JOIN + COUNT + AVG + GROUP BY)
SELECT c.nombre AS cerebro,
       COUNT(v.id_conversacion) AS cantidad_conversaciones,
       AVG(v.tokens_usados)     AS promedio_tokens
FROM cerebros c
INNER JOIN conversaciones v ON c.id_cerebro = v.id_cerebro
GROUP BY c.nombre;


-- Consulta 8:
-- Calcular el total de tokens usados por cada cerebro durante
-- octubre de 2026, ordenado de mayor a menor.
-- (JOIN + WHERE por fecha + SUM + GROUP BY + ORDER BY)
SELECT c.nombre AS cerebro, SUM(v.tokens_usados) AS total_tokens
FROM cerebros c
INNER JOIN conversaciones v ON c.id_cerebro = v.id_cerebro
WHERE v.fecha_hora BETWEEN '2026-10-01 00:00:00' AND '2026-10-31 23:59:59'
GROUP BY c.nombre
ORDER BY total_tokens DESC;


-- Consulta 9:
-- Mostrar el historial completo de conversaciones de la tarea N° 1,
-- con el nombre del cerebro que respondió, ordenado por fecha.
-- (JOIN + WHERE + ORDER BY)
SELECT v.fecha_hora,
       c.nombre AS cerebro,
       v.mensaje_usuario,
       v.respuesta_ia
FROM conversaciones v
INNER JOIN cerebros c ON v.id_cerebro = c.id_cerebro
WHERE v.id_tarea = 1
ORDER BY v.fecha_hora ASC;


-- Consulta 10:
-- Obtener las 3 etiquetas que tienen más tareas,
-- incluyendo la cantidad de cada una.
-- (JOIN + COUNT + GROUP BY + ORDER BY + LIMIT)
SELECT e.nombre AS etiqueta, COUNT(t.id_tarea) AS cantidad_tareas
FROM etiquetas e
INNER JOIN tareas t ON e.id_etiqueta = t.id_etiqueta
GROUP BY e.nombre
ORDER BY cantidad_tareas DESC
LIMIT 3;
