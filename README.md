
# Prueba buffer de memoria y configuración test VGA

- Nicolás Velásquez Ospina
- Jhair Steven Gallego Mendez
- Juan David Sarmiento Lastra

## Desarrollo

### Pregunta 1: 
Definir, ¿Cuál es el tamaño máximo de buffer de memoria que puede crear, acorde a la FPGA?, contraste este resultado con la memoria necesaria para la visualización en un pantalla VGA 640 x 480 de RGB444, y compruebe si es posible dejando el 50 % libre de la memoria.

Revisando el datasheet de la tarjeta usada, en este caso el modelo Cyclone IV FPGA EP4CE10E22C8N, nos encontramos que este proporciona una tabla donde se mencionan las distintas capacidades de memoria RAM de la tarjeta (en Kbits), para varios tipos de modelos similar al de la tarjeta usada. 

![Screenshot](Imagenes/tabladata.png)



Según el datasheet, unos 414kilobits en el modelo usado. Ahora, para usar una pantalla VGA serán necesarios 4 bits para cada color en cada píxel, por lo que serían 12 por cada uno, con una resolución de 640 x 480, por lo que se requieren unos 3686kilobits, donde la tarjeta se queda evidentemente corta. Entonces, será necesario hacer cambios en la visualización, limitando la cantidad de colores y el tamaño de los píxeles.

### Revise el datasheet de la Tarjeta de desarrollo que usted esta usando y compruebe el pinout neceario para la implementación ¿Debe realizar algún cambio en el apartado anterior y que criterios debe tener en cuanta para ello?.

### ¿Usted qué estrategia para modificar la RAM considera para la implementación de la FSM del juego?
