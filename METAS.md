# Metas de Desarrollo para Uni Explore (Versión 0.1)

Este documento describe las metas principales para alcanzar el Producto Mínimo Viable (MVP) del juego, basándose en el GDD.

### Meta 1: Menú Principal y Flujo Inicial
- **Objetivo:** Crear una puerta de entrada al juego.
- **Tareas:**
    - [ ] Crear una escena de Menú Principal (`MenuPrincipal.tscn`).
    - [ ] Añadir botones para "Iniciar Aventura" y "Salir del Juego".
    - [ ] Crear una escena de Selección de Personaje (`SeleccionPersonaje.tscn`).
    - [ ] El botón "Iniciar Aventura" debe llevar a la pantalla de selección de personaje.
    - [ ] La pantalla de selección debe mostrar los 4 personajes jugables (usando placeholders).
    - [ ] Tras seleccionar un personaje, el juego debe iniciar en el mapa principal (`Town.tscn`).
    - [ ] Actualizar el proyecto para que inicie en el `MenuPrincipal.tscn`.

### Meta 2: Mundo del Juego y Jugador
- **Objetivo:** Implementar las mecánicas básicas de exploración.
- **Tareas:**
    - [ ] Adaptar el script del jugador (`Player.gd`) para soportar la selección de personaje.
    - [ ] Implementar la mecánica de "Correr" como se describe en el GDD.
    - [ ] Crear la zona "Campus Central" con sus elementos básicos (árboles, caminos).
    - [ ] Implementar la transición para entrar y salir de un edificio (ej. `PlayerHomeFloor1.tscn`).

### Meta 3: Interacción y Narrativa
- **Objetivo:** Dar vida al mundo con personajes y diálogos.
- **Tareas:**
    - [ ] Diseñar e implementar un sistema de diálogo simple (caja de texto, retrato de NPC).
    - [ ] Crear al menos 2 NPCs en el mapa.
    - [ ] Implementar diálogos simples para estos NPCs.
    - [ ] Añadir el indicador `!` sobre los NPCs interactuables.

### Notas Adicionales
- **Gráficos:** Todos los elementos visuales nuevos (personajes, UI) se crearán usando nodos `ColorRect` o `Polygon2D` como marcadores temporales (placeholders).
- **Audio:** Se omitirá la implementación de música y efectos de sonido por ahora. El código relacionado se dejará comentado si es necesario.
