# Gestión de impresión 3D

Maqueta estática del laboratorio SENA. Contiene 97 páginas HTML con formularios, estados y registros ilustrativos. No requiere instalación ni compilación; abre `Frontend/index.html` en el navegador. El panel se encuentra en `Frontend/features/dashboard/pages/index.html`.

## Flujo de trabajo con Git

`master` es la rama principal y contiene la versión aceptada. `frontend/estructura-hibrida` es la rama de trabajo actual. Las ramas de Git no forman carpetas ni subramas: sus cambios se incorporan a la principal mediante una pull request.

1. Realiza los cambios en la rama de trabajo.
2. Registra un commit y súbelo a esa misma rama.
3. Abre una pull request con destino (`base`) `master` y origen (`compare`) la rama de trabajo.
4. Revisa los archivos y commits de la solicitud; incorpora los cambios con `Merge pull request` cuando los aceptes.

`master` tiene una regla de protección que exige pull requests, también para administradores. Los pushes directos, los pushes forzados y la eliminación de la rama están bloqueados. Trabaja y sube tus commits a `frontend/estructura-hibrida`; después revisa y fusiona la pull request hacia `master`.

No se exige una aprobación de otra persona: GitHub no permite aprobar una pull request propia. Como propietario puedes revisar los cambios y aceptarlos con `Merge pull request`. La revisión y la fusión quedan a cargo del usuario.

## Arquitectura híbrida por funcionalidad

La organización combina pantallas agrupadas por módulo con estilos y recursos centralizados. Todos los módulos de `features/` contienen únicamente `pages/`; el CSS propio del proyecto se guarda en `shared/styles/` y las imágenes y fuentes en `shared/assets/`, aunque solo los utilice un módulo.

```text
Frontend/
  index.html                 # Entrada al prototipo
  features/
    acceso/pages/            # Inicio y recuperación de acceso
    dashboard/pages/
    produccion/pages/
    inventario/pages/
    equipos/pages/
    costeo/pages/
    estadisticas/pages/
    reportes/pages/
    usuarios/pages/
    roles/pages/
    laboratorios/pages/
    parametros/pages/
  shared/
    assets/
      fuentes/               # Fuente local y licencia
      img/                   # Marca, iconos e ilustración del acceso
    styles/
      acceso.css             # Diseño de las pantallas de acceso
      base.css               # Variables, tipografía y estilos globales
      componentes.css        # Importaciones de componentes comunes
      componentes/           # Formularios, tablas, estados y otros
      layouts/gestion.css    # Menú lateral y composición de gestión
  vendor/bootstrap/          # CSS de terceros
documentos/                  # Requisitos, casos de uso y prototipos
Base de datos/               # SQL y modelo relacional
tools/
  verificar-rutas.ps1         # Comprueba enlaces, recursos y anclas
  verificar-bloques-compartidos.ps1 # Detecta diferencias entre menús y accesos
```

## Reglas de ubicación y dependencia

- Una página pertenece a `features/<modulo>/pages/`. Los enlaces entre módulos apuntan a esas páginas.
- Todos los módulos mantienen la misma estructura: `features/<modulo>/pages/`, sin carpetas `styles/` ni `assets/` dentro del módulo.
- Guarda todo el CSS propio en `shared/styles/` y las imágenes y fuentes en `shared/assets/`. Los estilos particulares pueden conservar el nombre del módulo, como `acceso.css`, y se enlazan solo desde las páginas que los necesitan.
- Bootstrap se conserva en `vendor/`; los ajustes propios se escriben en CSS del proyecto.
- `index.html` conserva el acceso directo de la portada. Al modificar ese formulario, revisa también `features/acceso/pages/index.html`.

El menú, encabezado y otros bloques comunes siguen presentes en cada HTML. Esta estructura no incorpora un motor de plantillas para sincronizarlos: los cambios globales deben aplicarse a todas las páginas afectadas.

## Orientación para modificar el código

Los comentarios `Inicio` y `Fin` delimitan el menú, el encabezado y el contenido particular de cada pantalla. El HTML usa dos espacios por nivel. Al añadir un campo, conserva la sangría de sus elementos hermanos; evita modificar espacios dentro de textos o entre elementos en una misma línea.

Para cambiar el menú, toma como referencia `features/dashboard/pages/index.html` y aplica el cambio a las otras pantallas de gestión. Cada página conserva la clase `actual` y `aria-current="location"` únicamente en el enlace principal de su propio módulo, también en formularios y detalles.

Para cambiar el acceso, toma como referencia `features/acceso/pages/index.html` y actualiza también `Frontend/index.html`. Conserva el mismo contenido del formulario y del enlace de recuperación, ajustando sus rutas relativas según la ubicación del archivo.

### Menú móvil sin JavaScript

Estos tres elementos deben permanecer dentro del mismo padre. El `label` debe estar inmediatamente después del `input`, y el `nav` después de ambos:

```html
<input class="control-menu" type="checkbox" id="control-menu" aria-controls="navegacion">
<label class="etiqueta-menu" for="control-menu">Menú de módulos</label>
<nav class="navegacion" id="navegacion" aria-label="Módulos">
  <!-- Enlaces del menú. -->
</nav>
```

El selector CSS `+` relaciona el input con la etiqueta inmediatamente siguiente para mostrar el foco. El selector `~` permite abrir la navegación cuando el input está marcado. No añadas un contenedor entre estos elementos: dejarían de ser hermanos y el menú podría fallar. Después de editar este bloque, revisa el menú con teclado y en una ventana estrecha.

### Dónde cambiar los estilos

- `shared/styles/acceso.css`: diseño de las pantallas de acceso, incluida la portada.
- `shared/styles/base.css`: variables de color y estilos generales. Las barras usan `--color-pista-progreso` y `--color-valor-progreso`.
- `shared/styles/componentes/formularios.css`: campos, etiquetas, títulos de grupos y textos de ayuda.
- `shared/styles/componentes/tablas.css`: tablas y sus títulos (`caption`).
- `shared/styles/componentes/paneles.css`: paneles, indicadores, fichas y gráficos.
- `shared/styles/layouts/gestion.css`: menú y distribución general, incluida la presentación móvil y de impresión.

Mantén el orden de las importaciones en `componentes.css` y de las hojas CSS en el HTML: puede afectar qué regla se aplica. Los cambios de responsabilidad ya realizados conservan los valores y selectores existentes.

### Datos ilustrativos relacionados

Las cifras están escritas directamente en el HTML. No se actualizan solas al cambiar otra página. Esta tabla indica las pantallas que debes revisar juntas; todas las rutas son relativas a `Frontend/features/`.

| Ejemplo | Pantallas relacionadas |
|---|---|
| Trabajo finalizado `TR-024` y su costo real | `produccion/pages/finalizado.html`, `costeo/pages/detalle.html`, `costeo/pages/precision.html`, `costeo/pages/comprobante-real.html` |
| Cotización `COT-017` convertida en `TR-024` | `costeo/pages/convertida.html`, `costeo/pages/comprobante-convertida.html`, `produccion/pages/finalizado.html`, `costeo/pages/precision.html` |
| Resumen de 24 piezas y 48 horas | `dashboard/pages/index.html`, `estadisticas/pages/index.html`, `reportes/pages/produccion.html`, `reportes/pages/vista-produccion.html` |

Antes de cambiar una muestra, busca también su identificador o cifra en el proyecto: puede aparecer en listas o resúmenes adicionales. Esta tabla es una guía de los escenarios principales, no una fuente de datos automática.

## Comprobaciones antes de entregar

Ejecuta desde la raíz del proyecto:

```powershell
pwsh -File tools/verificar-rutas.ps1
pwsh -File tools/verificar-bloques-compartidos.ps1
```

El primer comando comprueba destinos locales y anclas. El segundo compara los menús con la referencia del dashboard y los dos accesos con la referencia del módulo. Resuelve las rutas relativas al mismo destino y valida el módulo activo y el orden del menú móvil. Ignora comentarios y diferencias de sangría; conserva diferencias de texto, atributos, consultas y anclas. Ambos comandos informan errores sin corregir ni sobrescribir archivos; ante un error, consulta la ruta indicada y actualiza las copias afectadas.

Revisa además el acceso, el dashboard, un formulario de producción y un gráfico en escritorio; el menú abierto y cerrado en móvil, incluida la navegación por teclado; y la vista previa de impresión de un reporte. Las comprobaciones automáticas no sustituyen esta revisión visual.

## Agregar una pantalla

1. Consulta la matriz, los casos de uso y los nombres del SQL. Revisa `documentos/Caso de uso - Impresion3d.eap` antes de implementar un flujo.
2. Copia una pantalla del módulo correspondiente y guárdala en su carpeta `pages/`.
3. Actualiza título, encabezado, migas, navegación activa y etiquetas del formulario. Mantén los datos de ejemplo identificados como ilustrativos.
4. Usa rutas relativas al archivo. Desde `features/<modulo>/pages/`, los recursos compartidos comienzan por `../../../shared/`, los de Bootstrap por `../../../vendor/` y otro módulo por `../../<otro-modulo>/pages/`.
5. Comprueba rutas con `pwsh -File tools/verificar-rutas.ps1` desde la raíz. Revisa también navegación, formularios y presentación en escritorio y móvil.

Usa HTML semántico, indentación de dos espacios, texto en español y clases CSS en kebab-case. Conserva el alcance estático; cualquier dependencia, JavaScript, backend/API o cambio de base de datos requiere consulta previa.

## Migración de rutas

Las páginas antes situadas en `Frontend/pages/<modulo>/` están ahora en `Frontend/features/<modulo>/pages/`. Los enlaces internos ya usan la nueva ubicación; los marcadores externos a las rutas anteriores deben actualizarse. La entrada `Frontend/index.html` mantiene su ubicación.

Los recursos de acceso se centralizaron en `Frontend/shared/styles/acceso.css` y `Frontend/shared/assets/img/engranaje-helicoidal.png`. La portada y las cuatro pantallas de acceso usan estas ubicaciones.

## Bloques reutilizables y mejoras visuales

El lateral de acceso tiene una única fuente en `Frontend/shared/templates/acceso-lateral.html.tpl`. Conserva los textos de la portada en las cinco pantallas de acceso. Edita esa plantilla y ejecuta `pwsh -File tools/actualizar-lateral-acceso.ps1`; el marcador `{{raiz}}` ajusta las rutas de cada página. El comando comprueba todos los delimitadores antes de escribir. Su opción `-Comprobar` valida sin modificar archivos y forma parte del verificador de bloques compartidos.

Usuarios y roles muestran interruptores accesibles de activo/inactivo y un lápiz para editar cada registro de ejemplo. Los cambios de estado son visuales y no se guardan. Cada lápiz abre una muestra con los datos correspondientes a su fila. Los formularios de roles permiten actualizar nombre, descripción y permisos por módulo, reflejando RF-2.2; también se accede a ellos desde cada matriz de permisos. No se incluye eliminación.

Los reportes presentan un catálogo de informes, ficha y resultados con apariencia de documento. Las páginas de reportes de usuarios y roles siguen la misma presentación. Los botones Descargar PDF y Exportar CSV están deshabilitados: son una propuesta visual, sin generación de archivos. Los datos y períodos siguen siendo ilustrativos; los filtros no modifican los resultados. La impresión del navegador sigue disponible.

Para revisar: alterna un interruptor con clic y con la barra espaciadora; abre cada lápiz y comprueba que nombre y permisos corresponden a su fila; revisa acceso y recuperación con la misma ventana; comprueba el catálogo de reportes y las vistas previas en escritorio y móvil.

### Controles compactos de gestión

Las tablas de usuarios, roles, catálogos, materiales, equipos y laboratorios usan `tabla-gestion`. Las columnas `columna-estado` y `columna-acciones` centran sus controles y reservan solo el ancho necesario. Los interruptores de activo/inactivo no muestran texto adicional; su nombre y estado se anuncian mediante controles nativos accesibles. El lápiz usa el recurso compartido `shared/assets/img/editar.svg`, sin recuadro permanente, con fondo al pasar el cursor y foco visible. Ambos conservan un área pulsable de 44 × 44 px.

Todas las filas de esos listados disponen de su muestra de edición. Los materiales PETG y ABS conservan sus saldos, límites y avisos de existencias. Los colores Natural y Negro, los tipos ABS y PETG y las impresoras Ender 3 y Form 3 tienen formularios propios. Las impresoras tienen además una acción separada para su estado operativo, sin convertirlo en un interruptor. Parámetros conserva su edición conjunta con lápiz y texto. Los informes mantienen sus etiquetas informativas.

Los botones de edición de cada registro deben apuntar a su muestra correspondiente. El stock actual, los códigos inmutables y el estado operativo mostrado en edición conservan sus restricciones. Los interruptores solo representan cambios locales de la maqueta; no guardan ni modifican los formularios o reportes.
