#  Proyecto RPG en Godot – README

Bienvenido/a al proyecto RPG desarrollado en Godot. Este documento explica la estructura de carpetas, funcionamiento general.

---

##  Estructura de Carpetas

```
│   main.tscn
│   README.md
│
├───assets
│   ├───audio
│   │       audio.md
│   │
│   ├───sprites
│   │   │   Sprites.md
│   │   │
│   │   ├───enemies
│   │   │       enemies.md
│   │   │
│   │   ├───objetos
│   │   │       objetos.md
│   │   │
│   │   └───players
│   │           players.md
│   │
│   ├───tilesets
│   │       tilesets.md
│   │
│   └───ui
│           ui.md
│
├───data
│       data.md
│
├───docs
│       docs.md
│
├───scenes
│   ├───enemies
│   │       enemies.md
│   │
│   ├───maps
│   │       maps.md
│   │
│   ├───objetos
│   │       objetos.md
│   │
│   ├───player
│   │       player.md
│   │
│   └───ui
│           ui.md
│
└───scripts
    ├───enemies
    │       enemies.md
    │
    ├───objetos
    │       objetos.md
    │
    ├───player
    │       player.md
    │
    ├───systems
    │       systems.md
    │
    └───ui
            ui.md

```

---

##  Descripción del Juego
Proyecto RPG estilo **acción-aventura** donde el jugador explora un mundo abierto, combate enemigos, completa misiones y mejora sus habilidades.

Características principales:
- Sistema de combate en tiempo real.
- Misiones y diálogos basados en archivos de datos.
- Inventario y equipamiento.
- IA básica de enemigos.
- Interfaz con HUD dinámico.

---

##  Sistemas Implementados
- **Jugador:** movimiento, ataque, detección de colisiones.
- **Enemigos:** IA de persecución y ataque.
- **Inventario:** manejo de objetos y equipamiento.
- **Diálogos:** lectura de archivos JSON.
- **Misiones:** disparadores, objetivos y recompensas.

---


