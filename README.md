# TP N° 8: Base de Datos 1 - Proyecto JARVIS

**Institución:** IPET 247 Cassaffousth  
**Especialidad:** Programación  
**Curso:** 6to E  
**Alumno:** Zárate Adriel Jalil  
**Fecha:** Octubre 2026  

---

## 1. Especificación de Requisitos de Software (ERS)

El proyecto **JARVIS** es un sistema de Asistente Personal Multi-IA diseñado para coordinar, gestionar y registrar la interacción con múltiples inteligencias artificiales (como OpenAI GPT, Anthropic Claude, Google Gemini y xAI Grok). El sistema permite administrar hilos de conversación, asignación de tareas operativas y categorización por etiquetas.

---

## 2. Requisitos Funcionales

1. **RF-01 (Gestión de Cerebros/Modelos):** El sistema debe registrar y administrar los diferentes motores de IA (cerebros), almacenando su proveedor, modelo, costo por millón de tokens y estado.
2. **RF-02 (Registro de Conversaciones):** El sistema debe permitir registrar las interacciones/chats con cada IA, asociando el tokenaje consumido, la duración y la fecha.
3. **RF-03 (Administración de Tareas):** El sistema debe gestionar las tareas generadas o asignadas a partir de las conversaciones, controlando su estado de ejecución (pendiente, en progreso, completada) y prioridad.
4. **RF-04 (Categorización mediante Etiquetas):** El sistema debe categorizar conversaciones y tareas mediante etiquetas personalizadas para organizar el contexto de trabajo.
5. **RF-05 (Consulta y Métricas de Uso):** El sistema debe permitir consultar estadísticas de consumo de tokens, costo acumulado por modelo y rendimiento de respuesta.

---

## 3. Consultas SQL Realizadas (`consultas.sql`)

El archivo `consultas.sql` contiene la creación del esquema de la base de datos `jarvis_db`, la inserción de datos de prueba y 10 consultas representativas:

1. **Consulta 1:** Listar todos los cerebros de IA activos.
2. **Consulta 2:** Obtener conversaciones con más de 1500 tokens consumidos.
3. **Consulta 3:** Listar tareas pendientes ordenadas por prioridad.
4. **Consulta 4:** Obtener el total de tokens consumidos por cada cerebro de IA.
5. **Consulta 5:** Obtener el promedio de tiempo de respuesta de cada modelo.
6. **Consulta 6:** Listar las conversaciones junto con el nombre del cerebro que las procesó (JOIN).
7. **Consulta 7:** Obtener las tareas junto con el título de la conversación de origen.
8. **Consulta 8:** Contar la cantidad de conversaciones por cada etiqueta.
9. **Consulta 9:** Obtener los cerebros cuyo costo acumulado supere el promedio.
10. **Consulta 10:** Mapeo completo de conversaciones, cerebros asociados y tareas generadas.

---

## 4. Declaración sobre el uso de Inteligencia Artificial

Para el desarrollo de este trabajo práctico se utilizó asistencia de **Inteligencia Artificial (Gemini / ChatGPT)** en las siguientes etapas:

- **Diseño del modelo entidad-relación:** Modelado y estructuración de tablas, claves primarias y claves foráneas (`FOREIGN KEY`).
- **Generación de datos de prueba:** Elaboración de scripts de inserción (`INSERT INTO`) para validar las consultas.
- **Optimización de consultas SQL:** Revisión sintáctica y estructuración de consultas avanzadas (`JOIN`, `GROUP BY`, funciones de agregación).
- **Validación:** El código generado fue revisado, probado y ejecutado localmente en entorno XAMPP (MySQL/MariaDB) y phpMyAdmin.