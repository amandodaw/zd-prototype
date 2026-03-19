# Brainstorming inicial

## Concepto

 El jugador da órdenes a humanos npc con el fin de sobrevivir a un ataque de zombies cada noche. Entre las acciones disponibles, se encuentran recolectar recursos, construir edificios (por orden del jugador), fabricar armas/herramientas, equipar/inventario de armas y herramientas, combatircon las distintas armas (ataque melee, a distancia, defender).

## Elementos necesarios en Godot

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
  
  # Progreso día 1

- Creado Node2d map con 2 TileMapLayer: groundlayer y entitieslayer. Entitieslayer se referencia en los scripts de los humanos

- Creada UI basica con botones que activan acciones y labels que muestran cuantas cosas hay en la ciudad

- Creado Sprite2d Player con node progressbar. Script más complicado con todo el comportamiento de player. Dividir en sistemas post-prototypo. Mantener ordenado KISS KISS KISS

- Creado city_component.gd que guarda las variables de la ciudad. Build_orders, edificios, cantidad madera y hachas

- Copiado script camara de ZombieDefenseManager

- Creado comportamiento de estados básico del humano. Sistemas resumidos todos dentro de su script. En jobsystem, checkea que trabajo hacer, y en process, ejecuta acciones según su estado (classic state machine)

- Creado metodo para buscar en la array de entidades y encontrar el objetivo más cercano.

- Creados trabajos gather y build.

- En proceso de creación de trabajo make_axe
  
  # Próximas tareas desmenuzadas 12-03-26

**Make_axe**: Crear método make_axe similar a build(), pero esta vez no crea un edificio, si no que aumenta la cantidad de axe_amount de la ciudad.
**Make_bow**: ¿Realmente hace falta para prototipar? Vamos a dejarlo por ahora.
**Build_wall**: Que gaste unos 3 de madera, tenga unos 10 de hp. Problema, donde guardar el hp? Quizás llego la hora de crear un build_component simple.
**Melee_attack**: Si hay espadas en la ciudad, coger una y usarla para atacar al zombie más cercano. ¿Hacer zombies primero?
**Zombies**: Con rango de visión. O sin el. Si hay humano a 3 casillas, ir a por el, si no, ir a por pared o edificio. Añadir vida a edificio.
**Ciclo_día_noche**: Un script que según delta va cambiando el día y la noche (variable de citycomponent de momento). El día dura unos 60 segundos y la noche 30, para mantener el ritmo rápido de juego. Por la noche spawnean zombies cerca de las construcciones y hay que defenderlos. Cada día +1 humano, cada noche +1 o 2 zombies.
**Sistema de combate**: Ahora si, con los elementos necesarios, que se peguen.
**Disfrutar del gameplay**: Prototypo en teoría jugable! Llegado este punto, disfrutar. Maravillarse con el gameplay. Si es divertido, refactorizar código para añadir contenido (aún sin optimización masiva de código)

## Make_axe

- [x] Crear botón make_axe
  
  - [x] Crear variable axe_amount en city_comp
  - [x] Crear variable en diccionario tasks "make_axe"
  - [x] Botón activa y desactiva la órden

- [x] Crear acción make_axe en human.gd
  
  - [ ] ~~Añadir estado make_axe al enum Jobs~~
  
  - [ ] ~~Si city_comp.tasks["make_axe"] == true -> current_job make_axe~~
  
  - [ ] ~~Comprobar que get_target de get_wood_tiles se puede usar para los workplaces para elegir objetivo workplace~~
  
  - [ ] ~~make_axe(): si target distinto de INVALID, get_target. Si posicion != posicion target. Si esta en el target, que aumente el progreso. Si termina, aumenta axe_amount de city_comp.~~
  
  - [x] Reesctructurar todo para que funciona con make_order
  
  - [x] crear make_orders array de Strings
  
  - [x] al pulsar botón, se crea una make_order array
  
  - [x] crear try_to_take_make_order, asigna un workplace como target_pos
  
  - [x] crear make() que va al target_pos, y cuando esta hace como build con un progress bar y añade +1 a city_comp.axe_amount
  
  ## Build_wall

- [x] Crear botón build_wall
  
  - [x] Crear build_order en array build_orders de city_comp
  
  - [x] Añadir datos de wall en human.gd (al final los sistemas están aquí dentro resumidos)
  
  - No debería hacer falta mucho más, ya que debería estar hecho lo demás de build_workplace

- [x] Crear método build_workplace o modificar build() para que cree una cosa o otra según el valor del diccionario build_orders -> workplace_order o wall_order
  
  ## Move_update
  
  - [x] Modificar move_to para que si el tile está ocupado, no se mueva
  
  - [x] Crear método para elegir un tile adyacente
  
  - [x] Cambiar acciones para que se hagan desde el tile adyacente
  
  - [x] Eligen direccion aleatoria si esta ocupada el destino
  
  - [x] Humanos pertenecen a city_comp entities y visible_tiles eliminado por city_comp entities
  
  ## Refactor movimiento para que use AStarGrid
  
  - Objetivo:  Reworkear **TODO** human que ya se han liado los metodos unos con otros.
  
  - Separar responsabilidades de las funciones
  
  - Reestructurar human.gd
    
    - Cambiar la forma en la que se elige trabajo
    
    - Cambiar primero las acciones. Reesctructurar gather de cero.
  
  ## Zombies
  
  - [ ] ~~Mejorar movimiento de human para que evite tiles en visible_tiles. Después copiar la lógica en zombies.~~
  
  - [x] Para ello, añadir comprobación de visible tiles antes de moverse a un tile
  
  - [ ] ~~Crear sprite2d zombie sin progress bar, con un par de metodos de human find_nearest y go_to target~~
  
  - [x] Creado script entity.gd con metodos de movimiento y search de human para que herede zombie tambien
  
  - [ ] Añadir humanos a un array para que los zombies lo vean
  
  - [ ] Crear metodo para moverse a una pared
  
  - [ ] Si no ve humano en 3 tiles cercanas, moverse a pared. Si lo ve, cambiar a por humano

## Refactor de Human.gd

- [x] Reescribir método para elegir que trabajo hacer

- [x] Reescribir movimiendo usando AStar de godot

- [x] Reescribir gather con la nueva lógica

# Tareas  hechas 16/03/26

- Sistema de trabajos simple

- Make action va al workplace.

- Build action puede buguearse si se empieza a construir desde un sitio que formará parte del edificio.  También el progreso ocurre dentro de human.gd. En el futuro hay que crear un componente workplace que mantenga el progreso de construcción/creación

- Gather action coge madera en el mapa

- Movimiento ahora funciona con Astar pathfinding de godot

- Creado array de tiles reservados por trabajos en city_comp y eliminadas variables redundantes de human.gd

## Next steps

- Seguir las siguientes implementaciones
  
  - Zombies que se mueven hacia una pared o hacia un humano si está en 3 tiles cercanas (HECHO)
  
  - Sistema de combate. Estado/trabajo combatir. Se elige un target, se va a su tile adyacente y se le pega con un timer. 3 hp, cada 1 delta un ataque.
  
  - Ciclo de día y noche. Por la noche spawnean zombies. 60 segundos dedía, 30 de noche.

## Crear entidad pared

- [x] Añadirla a city_comp.living_entities

- [x] Darle script que hereda de entidad (En el futuro, con componentes, no tendrá todos los métodos de entidad que no usa)

- Script wall creado. Ha habido que hacer ajustes y asignarle elements map y city comp al crearlo. También asignr el tipo de entidad (cuando se hacía en ready se hacia después de comprobarse y daba problemas/ o quizás otro bug)

## Melee_attack/Combat_system(en human.gd)

- [x] Crear variables health, attack speed y attack damage en entity.gd y asignarlas en ready de cada script

- [x] Como deberia acceder a la variable de la otra entidad? Crear referencia target de tipo ~~Sprite2d~~ Entidad entity.gd y asignarlo al atacar o otra forma

- [x] Crear estado atacar.

- [x] Asignar target a la entidad y haer referencia a su posicion en los metodos.

- [x] Crear metodos take_damage en entity.gd

- [x] Crear metodos atacar, cuando el estado es atacar. Atacar-> Si esta adyacente ataca, si no se mueve. Si ya no existe objetivo, resetear target.

- [x] Crear trabajo y lógica similar en human.gd. Usar find_nearest_alive para huir y atacar al zombie. En checkjob, si hay un zombie cerca-> huir. Si está activo el trabajo atacar, buscar zombie y atacarle.

## Ciclo día/Noche (en city_comp)

## DISFRUTAR DEL GAMEPLAY

 # El código se ha vuelto demasiado confuso en su simplicidad. Hora de implementar pequeños sistemas.

 ## Idea principal

Separar toda la funcionalidad enocntrada en zombie y human y más nodos y moverla a sistemas conforme aplique. Por ejemplo: HealthComponent con health y mover ahí los métodos die, take damage etc (demasiado pequeño para un sistema entero). Al añadir componentes, en vez de hacerlo como en el anterior proyecto, hacerlo por nodos. Los componentes son código, pero se asignan usando las ids que proporciona godot por nodo, sin tener que crear un array de entidades adicional. En su lugar, cada entidad puede heredar de entidad.gd, pero tan solo para tener los metodos add_component y remove_component y has_component. Otra alternativa es hacer usando grupos de godot. O que cada componente, en su método ready, se registre en su sistema (para esto haría falta acceso global, pero es bastante eficiente). 

Método a seguir: componentes creados por script. Script Entity.gd del que heredan todos los objetos con metodos para gestionar componentes. Cada entidad tiene un componente, y los componentes tambien están registrados en los sistemas. Los componentes no son nodos.

 ### Primera prueba realizada

Resultado exitoso de la primera prueba. MEtodos para gestionar componentes y diccionario de componentes creado en script entity.gd. En el futuro, solo debería tener eso, y todo lo demás debería haberse movido a un componente o sistema.

Se ha realizado la primera prueba con HealthComponent, quitando funcionalides que deben integrar en otros sistemas como morir. Pero el acceso a los componentes funciona correctamente.

 ### Planteamiento siguientes tareas 

 - Path component, que debería albergar:
    - Vector por defecto INVALID
    - Variables target_pos... espera
    - Demasiado complejo, mejor que tenga las variables que dependen de pathfinding (path, current_path_index)
 - Target component, que guarda el target y su posición. Crear componente ya que será usado por distintos sistemas (movimiento + planner + ejecutres de accion)
 - Position component, con grid_pos.
 - MovementComponent, con
    - speed y speed_cont
 - elements_map debería convertirse en un sistema entero que controla la posición del as entidades (map_system o grid_syste)
 - CityComp está bien, y cuando la ciudad haga cosas deberá tener un sistema también. Sin embargo, la función que cumple ahora CityComp no es ideal, funciona más como un diccionario de datos del mundo, cosa que ya no necesitará cada entidad, si no cada sistema respectivo a sus componentes.
 - EntityType podria convertirse en un tipo de componente para según que tipo de entidad (HumanComponent, ZombieComponent) o podría vivir en Entity.gd, otra variable más que tendrán todas las entidades con un ENUM con todas por ejemplo.
 - AttackComponent, que contiene todas las variables de ataque (y los métodos hasta que se migre a un sistema AttackSystem)
 - Cada vez que se cree un componente y se ajusten sus métodos, agregarlo a las entidades y testear que el juego sigue funcionando (en world, funciones spawn_)
