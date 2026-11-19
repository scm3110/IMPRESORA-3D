# Gestión de impresión 3D

Maqueta estática del laboratorio SENA. Contiene 94 páginas HTML con formularios, estados y registros ilustrativos. No requiere instalación ni compilación; abre `Frontend/features/acceso/pages/index.html` en el navegador. El panel se encuentra en `Frontend/features/dashboard/pages/index.html`.

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
- La entrada única es `features/acceso/pages/index.html`; no hay una portada adicional.

El sidebar se mantiene desde una plantilla única y se genera en cada HTML para que las páginas funcionen sin JavaScript ni servidor. El encabezado y el pie también se generan desde sus plantillas; el contenido particular de cada pantalla se edita en su HTML.

## Orientación para modificar el código

Los comentarios `Inicio` y `Fin` delimitan el menú, el encabezado y el contenido particular de cada pantalla. El HTML usa dos espacios por nivel. Al añadir un campo, conserva la sangría de sus elementos hermanos; evita modificar espacios dentro de textos o entre elementos en una misma línea.

Para cambiar el sidebar, edita `Frontend/shared/templates/sidebar.html` y ejecuta `pwsh -File tools/actualizar-sidebar.ps1`. No edites las copias generadas en cada HTML. El marcador `{{raiz}}` ajusta las rutas y `{{activo:modulo}}` marca automáticamente el módulo activo con `actual` y `aria-current="location"`. La opción `-Comprobar` valida sin escribir y forma parte del verificador de bloques compartidos.

Para cambiar el formulario de acceso, edita únicamente `features/acceso/pages/index.html`.

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

- `shared/styles/acceso.css`: diseño de las pantallas de acceso, que constituyen la entrada al sistema.
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

El primer comando comprueba destinos locales y anclas. El segundo compara los menús con la referencia del dashboard y comprueba el formulario único de acceso. Resuelve las rutas relativas al mismo destino y valida el módulo activo y el orden del menú móvil. Ignora comentarios y diferencias de sangría; conserva diferencias de texto, atributos, consultas y anclas. Ambos comandos informan errores sin corregir ni sobrescribir archivos; ante un error del sidebar, revisa la plantilla y ejecuta el actualizador; para otros errores, consulta la ruta indicada.

Revisa además el acceso, el dashboard, un formulario de producción y un gráfico en escritorio; el menú abierto y cerrado en móvil, incluida la navegación por teclado; y la vista previa de impresión de un reporte. Las comprobaciones automáticas no sustituyen esta revisión visual.

## Agregar una pantalla

1. Consulta la matriz, los casos de uso y los nombres del SQL. Revisa `documentos/Caso de uso - Impresion3d.eap` antes de implementar un flujo.
2. Copia una pantalla del módulo correspondiente y guárdala en su carpeta `pages/`.
3. Actualiza título, encabezado, migas, navegación activa y etiquetas del formulario. Mantén los datos de ejemplo identificados como ilustrativos.
4. Usa rutas relativas al archivo. Desde `features/<modulo>/pages/`, los recursos compartidos comienzan por `../../../shared/`, los de Bootstrap por `../../../vendor/` y otro módulo por `../../<otro-modulo>/pages/`.
5. Comprueba rutas con `pwsh -File tools/verificar-rutas.ps1` desde la raíz. Revisa también navegación, formularios y presentación en escritorio y móvil.

Usa HTML semántico, indentación de dos espacios, texto en español y clases CSS en kebab-case. Conserva el alcance estático; cualquier dependencia, JavaScript, backend/API o cambio de base de datos requiere consulta previa.

## Migración de rutas

Las páginas antes situadas en `Frontend/pages/<modulo>/` están ahora en `Frontend/features/<modulo>/pages/`. Los enlaces internos ya usan la nueva ubicación; los marcadores externos a las rutas anteriores deben actualizarse. La entrada única está en `Frontend/features/acceso/pages/index.html`.

Los recursos de acceso se centralizaron en `Frontend/shared/styles/acceso.css` y `Frontend/shared/assets/img/engranaje-helicoidal.png`. Las cuatro pantallas de acceso usan estas ubicaciones.

## Bloques reutilizables y mejoras visuales

El lateral de acceso tiene una única fuente en `Frontend/shared/templates/acceso-lateral.html`. Mantiene el lateral coherente en las cuatro pantallas de acceso. Edita esa plantilla y ejecuta `pwsh -File tools/actualizar-lateral-acceso.ps1`; el marcador `{{raiz}}` ajusta las rutas de cada página. El comando comprueba todos los delimitadores antes de escribir. Su opción `-Comprobar` valida sin modificar archivos y forma parte del verificador de bloques compartidos.

Usuarios y roles muestran interruptores accesibles de activo/inactivo y un lápiz para editar cada registro de ejemplo. Los cambios de estado son visuales y no se guardan. En usuarios, los tres lápices abren un único `editar.html` con datos ilustrativos fijos; no carga los datos de la fila seleccionada. En roles, cada lápiz abre la muestra correspondiente a su fila. Los formularios de roles permiten actualizar nombre, descripción y permisos por módulo, reflejando RF-2.2; también se accede a ellos desde cada matriz de permisos. No se incluye eliminación.

Los reportes presentan un catálogo de informes, ficha y resultados con apariencia de documento. Las páginas de reportes de usuarios y roles siguen la misma presentación. Los botones Descargar PDF y Exportar CSV están deshabilitados: son una propuesta visual, sin generación de archivos. Los datos y períodos siguen siendo ilustrativos; los filtros no modifican los resultados. La impresión del navegador sigue disponible.

Para revisar: alterna un interruptor con clic y con la barra espaciadora; comprueba que los tres lápices de usuarios abren el formulario común de ejemplo y que los de roles muestran el nombre y los permisos correspondientes a su fila; revisa acceso y recuperación con la misma ventana; comprueba el catálogo de reportes y las vistas previas en escritorio y móvil.

### Controles compactos de gestión

Las tablas de usuarios, roles, catálogos, materiales, equipos y laboratorios usan `tabla-gestion`. Las columnas `columna-estado` y `columna-acciones` centran sus controles y reservan solo el ancho necesario. Los interruptores de activo/inactivo no muestran texto adicional; su nombre y estado se anuncian mediante controles nativos accesibles. El lápiz usa el recurso compartido `shared/assets/img/editar.svg`, sin recuadro permanente, con fondo al pasar el cursor y foco visible. Ambos conservan un área pulsable de 44 × 44 px.

Usuarios comparte un único formulario de edición de ejemplo; las filas de los demás listados disponen de sus muestras de edición. Los materiales PETG y ABS conservan sus saldos, límites y avisos de existencias. Los colores Natural y Negro, los tipos ABS y PETG y las impresoras Ender 3 y Form 3 tienen formularios propios. Las impresoras tienen además una acción separada para su estado operativo, sin convertirlo en un interruptor. Parámetros conserva su edición conjunta con lápiz y texto. Los informes mantienen sus etiquetas informativas.

Los botones de edición de usuarios apuntan al formulario común de ejemplo; en los demás listados deben apuntar a la muestra correspondiente. El stock actual, los códigos inmutables y el estado operativo mostrado en edición conservan sus restricciones. Los interruptores solo representan cambios locales de la maqueta; no guardan ni modifican los formularios o reportes.

## Abrir al depurar en Visual Studio Code

Abre la carpeta raíz del proyecto y pulsa F5. La configuración Abrir inicio de sesión de .vscode/launch.json abre Chrome directamente en Frontend/features/acceso/pages/index.html, independientemente del archivo que estés editando. No requiere servidor ni JavaScript.

El enlace Cerrar sesión pertenece al sidebar compartido y vuelve al inicio de sesión. En móvil aparece al desplegar el menú. Es una navegación de muestra: la maqueta no mantiene ni cierra sesiones reales.

## Encabezado y pie compartidos

Edita `Frontend/shared/templates/encabezado-gestion.html` o `Frontend/shared/templates/pie-gestion.html` y ejecuta desde la raíz:

```powershell
pwsh -File tools/actualizar-encabezado-pie.ps1
```

El comando actualiza ambos bloques en las 90 páginas de gestión y conserva el contenido de cada pantalla. No afecta al módulo de acceso. Usa -Comprobar para validar sin escribir; esta revisión está integrada en verificar-bloques-compartidos.ps1. Conserva los comentarios Inicio y Fin de ambos bloques, también al copiar una pantalla para crear otra.

Las plantillas de shared/templates/ terminan en .html, pero siguen siendo fragmentos reutilizables, no pantallas completas. Conserva los marcadores de rutas y módulo activo. verificar-rutas.ps1 excluye esta carpeta y revisa las páginas generadas; verificar-bloques-compartidos.ps1 comprueba que esas páginas coincidan con sus plantillas.
