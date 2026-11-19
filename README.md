# Gestión de impresión 3D

Maqueta estática del laboratorio SENA con 81 pantallas de muestra. Las pantallas se escriben en HTML y los estilos en CSS. Un único archivo JavaScript carga el menú, encabezado, pie y lateral de acceso desde sus archivos compartidos. No hay compilación, backend ni dependencias nuevas.

## Abrir el proyecto

1. Abre esta carpeta en Visual Studio Code.
2. Abre `Frontend/features/acceso/pages/index.html`.
3. Haz clic derecho y selecciona Open with Live Server, o pulsa Go Live.
4. Edita, guarda y recarga el navegador: no hay que ejecutar un actualizador.

La configuración de Live Server sirve `Frontend/` en el puerto 5500. Si ya estaba iniciado con otra configuración, detenlo y vuelve a iniciarlo. F5 abre `http://127.0.0.1:5500/features/acceso/pages/index.html`; requiere que Live Server esté iniciado. Si el puerto está ocupado, detén el otro servidor antes de iniciar este proyecto.

**No abras los HTML mediante doble clic:** la carga de bloques con fetch necesita HTTP. Si se abre una página como archivo local, aparece un aviso para usar Go Live.

## Qué debes editar

| Quiero cambiar | Dónde editar |
|---|---|
| Una pantalla, sus datos o título de pestaña | `Frontend/features/<modulo>/pages/<pagina>.html` |
| Menú y Cerrar sesión | `Frontend/shared/templates/sidebar.html` |
| Barra superior | `Frontend/shared/templates/encabezado-gestion.html` |
| Pie de página | `Frontend/shared/templates/pie-gestion.html` |
| Logo e imagen lateral del acceso | `Frontend/shared/templates/acceso-lateral.html` |
| Comportamiento de carga de bloques | `Frontend/shared/scripts/layout.js` |
| Estilos | `Frontend/shared/styles/` |
| Imágenes y fuentes | `Frontend/shared/assets/` |

Cada pantalla conserva su head, estilos, título, enlace al script y contenido principal. El script incorpora la estructura del sidebar y el área de gestión, o el lateral de acceso. Los formularios siguen siendo ilustrativos; JavaScript solo carga los bloques compartidos.

## Organización

```text
Frontend/
  features/<modulo>/pages/       # Pantallas HTML que editas
  shared/
    templates/                  # Cuatro bloques HTML compartidos
    scripts/layout.js           # Cargador común, sin librerías
    styles/                     # Estilos propios
    assets/                     # Imágenes y fuentes
  vendor/bootstrap/             # CSS de terceros
tools/
  verificar-rutas.ps1
  verificar-bloques-compartidos.ps1
documentos/                     # Requisitos y casos de uso
Base de datos/                  # Modelos y SQL
```

Los cambios de plantillas se ven al recargar: ya no hay comandos de actualización ni páginas de salida separadas.

## Crear una pantalla

1. Consulta la matriz, los casos de uso y el SQL. Revisa `documentos/Caso de uso - Impresion3d.eap` antes de implementar flujos.
2. Copia una pantalla del mismo módulo dentro de su carpeta `pages/`.
3. Cambia el title, el h1, las migas y el contenido propio. Conserva el enlace a layout.js con defer.
4. El body debe indicar `data-layout="gestion"` o `data-layout="acceso"` y `data-modulo="<nombre-del-modulo>"`. El módulo determina qué enlace del sidebar queda activo.
5. No copies el menú, barra o pie al HTML de la pantalla. Conserva `main id="contenido"` y el enlace de salto.
6. Mantén rutas relativas: `../../../shared/` para recursos y `../../<otro-modulo>/pages/` para otras pantallas.
7. Comprueba y revisa escritorio, móvil y teclado en el navegador.

En las plantillas, `{{raiz}}` se convierte en la URL de Frontend y `{{activo:modulo}}` señala el módulo activo. Los fragmentos no son pantallas para abrir directamente con Go Live.

## Comprobaciones

Desde la raíz:

```powershell
pwsh -File tools/verificar-rutas.ps1
pwsh -File tools/verificar-bloques-compartidos.ps1
```

Ambos comandos son de solo lectura. El primero revisa archivos, recursos y anclas, incluidas las rutas de las plantillas. El segundo comprueba módulos, estructura del menú móvil, carga del script e inexistencia de copias de los bloques en las pantallas.

Revisa también en el navegador el menú abierto/cerrado, teclado, legibilidad y vista de impresión. Si falta un archivo compartido, el contenido principal se conserva y se muestra un aviso de error.

## Flujo de trabajo con Git

`master` es la rama principal y contiene la versión aceptada. `frontend/estructura-hibrida` es la rama de trabajo actual. Las ramas de Git no forman carpetas ni subramas: sus cambios se incorporan a la principal mediante una pull request.

1. Realiza los cambios en la rama de trabajo.
2. Registra un commit y súbelo a esa misma rama.
3. Abre una pull request con destino (`base`) `master` y origen (`compare`) la rama de trabajo.
4. Revisa los archivos y commits de la solicitud; incorpora los cambios con `Merge pull request` cuando los aceptes.

`master` tiene una regla de protección que exige pull requests, también para administradores. Los pushes directos, los pushes forzados y la eliminación de la rama están bloqueados. Trabaja y sube tus commits a `frontend/estructura-hibrida`; después revisa y fusiona la pull request hacia `master`.

No se exige una aprobación de otra persona: GitHub no permite aprobar una pull request propia. Como propietario puedes revisar los cambios y aceptarlos con `Merge pull request`. La revisión y la fusión quedan a cargo del usuario.



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


## Comportamiento de las muestras

Usuarios y roles muestran interruptores accesibles de activo/inactivo y un lápiz para editar cada registro de ejemplo. Los cambios de estado son visuales y no se guardan. En usuarios, los tres lápices abren un único `editar.html` con datos ilustrativos fijos; no carga los datos de la fila seleccionada. En roles también se comparte un único formulario de edición con datos fijos de Instructor; las cuatro matrices de consulta conservan los permisos propios de cada rol. Los formularios de roles permiten actualizar nombre, descripción y permisos por módulo, reflejando RF-2.2; también se accede a ellos desde cada matriz de permisos. No se incluye eliminación.

Los reportes presentan un catálogo de informes, ficha y resultados con apariencia de documento. Las páginas de reportes de usuarios y roles siguen la misma presentación. Los botones Descargar PDF y Exportar CSV están deshabilitados: son una propuesta visual, sin generación de archivos. Los datos y períodos siguen siendo ilustrativos; los filtros no modifican los resultados. La impresión del navegador sigue disponible.

Para revisar: alterna un interruptor con clic y con la barra espaciadora; comprueba que los lápices de usuarios y roles abren sus formularios comunes y que cada matriz de consulta conserva los permisos del rol indicado; revisa acceso y recuperación con la misma ventana; comprueba el catálogo de reportes y las vistas previas en escritorio y móvil.

### Controles compactos de gestión

Las tablas de usuarios, roles, catálogos, materiales, equipos y laboratorios usan `tabla-gestion`. Las columnas `columna-estado` y `columna-acciones` centran sus controles y reservan solo el ancho necesario. Los interruptores de activo/inactivo no muestran texto adicional; su nombre y estado se anuncian mediante controles nativos accesibles. El lápiz usa el recurso compartido `shared/assets/img/editar.svg`, sin recuadro permanente, con fondo al pasar el cursor y foco visible. Ambos conservan un área pulsable de 44 × 44 px.

Usuarios y roles comparten un formulario de edición de ejemplo por módulo. Inventario comparte uno para materiales, otro para colores y otro para tipos de filamento. Equipos comparte un formulario de edición y otro de cambio de estado. Todos muestran datos fijos y no cargan el registro seleccionado. Las tablas conservan los datos de cada fila, incluidos saldos y alertas de PETG y ABS. Las impresoras tienen además una acción separada para su estado operativo, sin convertirlo en un interruptor. Parámetros conserva su edición conjunta con lápiz y texto. Los informes mantienen sus etiquetas informativas.

Los botones de edición de usuarios, roles, impresoras, materiales, colores y tipos de filamento apuntan al formulario de ejemplo correspondiente a su operación. El stock actual, los códigos inmutables y el estado operativo mostrado en edición conservan sus restricciones. Los interruptores solo representan cambios locales de la maqueta; no guardan ni modifican los formularios o reportes.


Cerrar sesión vuelve al acceso como navegación de muestra; no existe una sesión real. Las modificaciones de datos y estados no persisten. El usuario autorizó JavaScript únicamente para cargar bloques compartidos. Consulta antes de añadir dependencias, más funcionalidad de navegador, backend/API o cambios de base de datos.

## Formularios comunes de ejemplo

Se retiraron 13 copias que solo cambiaban datos de muestra. Roles conserva editar.html; equipos conserva editar.html y estado.html; inventario conserva editar.html, editar-color.html y editar-tipo.html. Los avisos explican que siempre se muestran los mismos datos. Los campos inmutables y restricciones se conservan.

Se mantienen separados registro y edición, acceso y recuperación, permisos de consulta por rol, estados y cancelaciones de producción, informes por finalidad y períodos de estadísticas: representan operaciones o escenarios distintos. No se han cambiado sus reglas para reducir archivos.
