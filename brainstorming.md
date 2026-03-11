 # Concepto

 El jugador da órdenes a humanos npc con el fin de sobrevivir a un ataque de zombies cada noche. Entre las acciones disponibles, se encuentran recolectar recursos, construir edificios (por orden del jugador), fabricar armas/herramientas, equipar/inventario de armas y herramientas, combatircon las distintas armas (ataque melee, a distancia, defender).

 # Elementos necesarios en Godot

- UI con los valores de las ordenes y las teclas que hace falta para pulsarlas y activarlas y desactivarlas. También un menú para seleccionar un humano y darle ordenes individuales (equipar objeto, asignar desasignar trabajos)
- Tilemaplayer con suelo y mapa jugable
- Tilemaplayer con recurso, pared, taller
- Script ciudad con los valores de las órdenes que están activadas
- Nodo Humano con sprite2d. Script de estados básico -> Consulta los active works de la ciudad y elige uno de ellos según su preferencia
- Sistema de movimiento por casillas.
- Sistema de inputs para la UI -> Pulsar tecla -> Activar orden
- Enemigos zombies y sistema día y noche (60s día y 30s noche)
- Sistema de combate
- Armas básicas espada, arco, escudo y forma de equiparsela a los humanos.

 ## División de elementos

 ### UI
 
- Muestra trabajos activados y los botones necesarios para activar y desactivarlos. También recursos disponibles.
- También muestra los humanos de la ciudad, y es posible activar y desactivar trabajos del humano. Si queremos que ataque a melee, habrá que activarlo (por ejemplo. KISS KISS KISS KISS)
- Menu simple de construcción. Si tienes recursos -> puedes construir taller o pared.

 ### Elementos en el mapa

- groundtile, sin efecto. Se puede andar sobre ella si no hay nada encima.
- recursotile. Puede ser recolectado por un NPC. Aparece aleatorio por el mapa encima de groundtile.
- tallertile. Puede ser construido con suficientes recursos. Permite usar la accion crear herrramienta.
- paredtile. Puede ser construido con suficientes recursos.
- humano. Se mueve e interactua con las cosas
- zombie. Aparece por la noche y ataca a los humanos.

 ### Acciones y worksistem humanos

- Los humanos, cada x segundos, comprueban las variables de la ciudad "trabajos activos" que el jugador activa y desactiva. Estos trabajos tienen una prioridad. Según si están activados y su prioridad, elegirá un estado, y repetirá su acción en bucle.
- Recolectar recursos
- Construir edificio (pared o taller)
- Fabricar arma
- Equipar arma
- Ataque melee (hacha)
- Ataque ranged (arco)
- Defensa escudo

 ### Bucles de acciones

- Recoger recursos: activar orden, humano se mueve a recursotile, recolecta recurso tile, ciudad gana recurso, usar recurso para construir
- recursotile: 5 madera; pared: 3 madera; taller: 10 madera; arco: 5 madera;
- Vida humano: 3; vida zombie: 6; vida pared: 10; Si mueren todos los humanos, termina el juego. Cada noche aparecen más zombies
- Noche 1: 3 zombies; n zombies = numero noche + 3;
- Zombies atacan humano si está cerca, si no atacan pared.
- Humano: elegir trabajo, ejecutar trabajo, repetir.

 ## MVP

- Empiezas con 3 humanos
- 1 recurso
- 1 arma melee
- 1 arma ranged
- pared
- zombies
- dia/noche
