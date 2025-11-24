#  Proyecto RPG en Godot – README

Bienvenido/a al proyecto RPG desarrollado en Godot. Este documento explica la estructura de carpetas, funcionamiento general.

---

##  Estructura de Carpetas

```
project/
│
├── assets/                # Recursos visuales, sonoros y objetos de juego
│   ├── sprites/           # Personajes, enemigos, objetos
│   ├── tilesets/          # Mapas y escenarios
│   ├── audio/             # Efectos y música
│   └── ui/                # Elementos de interfaz
│
├── scenes/                # Escenas principales del juego
│   ├── player/            # Jugador y sus estados
│   ├── enemies/           # Enemigos y IA
│   ├── maps/              # Mapas y niveles
│   └── ui/                # Menús y HUD
│
├── scripts/               # Código fuente en GDScript
│   ├── player/            # Movimiento, combate, inventario
│   ├── enemies/           # Lógica de enemigos
│   ├── systems/           # Combate, misiones, diálogos
│   ├── objetos/           # Sprites o recursos visuales para objetos interactivos
│   └── ui/                # Scripts de interfaz
│
├── data/                  # Archivos JSON/CSV para misiones, diálogos, items
│
├── docs/                  # Documentación adicional
│
├── objetos/               # Objetos interactivos, ítems y recursos del juego
│
└── main.tscn              # Escena principal del juego
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


