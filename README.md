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
- `shared/styles/components/formularios.css`: campos, etiquetas, títulos de grupos y textos de ayuda.
- `shared/styles/components/tablas.css`: tablas y sus títulos (`caption`).
- `shared/styles/components/paneles.css`: paneles, indicadores, fichas y gráficos.
- `shared/styles/layouts/gestion.css`: menú y distribución general, incluida la presentación móvil y de impresión.

Mantén el orden de las importaciones en `components.css` y de las hojas CSS en el HTML: puede afectar qué regla se aplica. Los cambios de responsabilidad ya realizados conservan los valores y selectores existentes.


### Datos ilustrativos relacionados

Las cifras están escritas directamente en el HTML. No se actualizan solas al cambiar otra página. Esta tabla indica las pantallas que debes revisar juntas; todas las rutas son relativas a `Frontend/features/`.

| Ejemplo | Pantallas relacionadas |
|---|---|
| Trabajo finalizado `TR-024` y su costo real | `produccion/pages/finalizado.html`, `costeo/pages/detalle.html`, `costeo/pages/precision.html`, `costeo/pages/detalle.html#comprobante` |
| Cotización `COT-017` convertida en `TR-024` | `costeo/pages/cotizacion.html`, `costeo/pages/cotizacion.html#comprobante`, `produccion/pages/finalizado.html`, `costeo/pages/precision.html` |
| Resumen de 24 piezas y 48 horas | `dashboard/pages/index.html`, `estadisticas/pages/index.html`, `reportes/pages/produccion.html`, `reportes/pages/produccion.html#resultado` |

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

Se mantienen separados registro y edición, acceso y recuperación, permisos de consulta por rol, fichas por estado de producción y formularios de actualización por escenario, informes por finalidad y períodos de estadísticas: representan operaciones o escenarios distintos. No se han cambiado sus reglas para reducir archivos.

### Registro de movimientos

En Movimientos, selecciona Tipo (Entrada, Merma o Ajuste) y pulsa Registrar. Sin selección, Registrar está deshabilitado. CSS muestra únicamente el enlace al formulario correspondiente; el selector es independiente del filtro Tipo del historial. Consultar salidas se presenta como botón secundario: las salidas se originan al finalizar un trabajo. Los formularios y sus validaciones permanecen sin cambios. Sin JavaScript adicional ni persistencia.

En Catálogos de material, Tipo permite elegir Color o Tipo de filamento. Un solo Registrar visible abre el formulario correspondiente; sin selección está deshabilitado. La selección usa CSS, sin JavaScript adicional. Las tablas y los formularios conservan sus datos y validaciones.

### Presentación documental de informes y comprobantes

El reporte de consumo de Inventario y los cinco comprobantes de Costeo integrados en sus fichas (detalle y ficha común de cotización) reutilizan reportes.css: barra de exportación, ficha y resultados con apariencia de documento. Descargar PDF y Exportar CSV permanecen deshabilitados. La impresión del navegador sigue disponible y oculta la barra de exportación. El catálogo de Reportes incluye el consumo de materiales; los comprobantes conservan sus accesos desde Costeo y Cotizaciones. No se alteraron importes, estados, períodos, registros, fórmulas ilustrativas ni filtros; no hay nuevas dependencias, JavaScript ni generación de archivos.

### Actualizar estado de producción

Producción sigue el patrón de Equipos: acción compacta en tabla-gestion que abre directamente un formulario con Estado actual de solo lectura y Nuevo estado. Los trabajos pendientes abren estado-pendiente.html (En proceso o Cancelado); los trabajos en proceso abren estado.html (Finalizado o Cancelado). Son dos escenarios con datos fijos de TR-026 y TR-025 y requisitos diferentes, no una carga dinámica del registro. Finalizados y cancelados mantienen solo consulta. El selector muestra mediante CSS el formulario correspondiente: cierre con tiempo y gramos reales obligatorios (máximo ilustrativo 150 g), cancelación con motivo obligatorio y aviso de rol Administrador/Instructor, inicio con comprobación ilustrativa de recursos. Solo se valida el formulario visible; no se añadió JavaScript, backend, persistencia ni comprobación real de permisos. Las operaciones de inicio, cierre y cancelación se conservan como opciones de los dos formularios de estado; se retiraron los cuatro formularios anteriores tras revisión documental favorable, sin perder campos ni validaciones.

La acción de actualizar el estado en la tabla de Producción usa el mismo lápiz compartido de los otros módulos, con nombre accesible y título «Actualizar estado».

RI-7.2: estado.html valida el consumo y abre cierre-ejemplo.html, escenario fijo TR-025 con identificación, horas, gramos, fecha de fin y estado Finalizado. Su historial muestra CE-025-01 estimado y CE-025-02 real nuevo al cerrar, ilustrando 1:N sin sobrescribir el anterior. No persiste ni reproduce entradas. El SQL conserva uq_costeo_trabajo (1:1): incompatibilidad pendiente para una futura implementación, fuera del alcance de la maqueta.

La ficha en-proceso.html permite consultar el cierre y el historial ilustrativos de TR-025 sin enviar el formulario. Ambos accesos indican que son ejemplos, pues el estado de la ficha no cambia. cierre-ejemplo.html incluye retorno a la ficha. El historial conserva el estimado de 40 g y marca el real más reciente como vigente (RN-8.0).

### Comprobantes integrados en las fichas de Costeo

Se retiraron los cinco archivos independientes tras comparar sus fichas y tablas y verificar las cinco vistas previas de impresión. Ver comprobante lleva a #comprobante dentro de cada ficha; detalle.html incluye responsable, material, equipo y tipo real. Se conservan importes, estados, parámetros y acciones. reportes.css limita la impresión documental de estas fichas a A4 con margen de 15 mm, sin menú, barra de exportación ni acciones; se corrigió una página final vacía causada por el cambio de página con nombre. Los cinco casos de muestra se comprobaron completos en una sola página, con Guardar como PDF como destino de vista previa. PDF/CSV automáticos siguen deshabilitados; usar Imprimir en el navegador. Sin JavaScript adicional, backend ni cambios SQL.

### Ficha única de cotización

cotizacion.html reemplaza las cuatro fichas por estado. Todos los accesos de la lista abren una muestra fija COT-017, no el registro seleccionado; se avisa en lista y ficha. detalle.html conserva el costeo real separado. El comprobante, los parámetros y estilos de impresión se mantienen en la ficha común. Los ejemplos de revisar COT-019 en Borrador y convertir COT-018 Aprobada siguen accesibles en Otros escenarios de ejemplo, sin aplicarse a COT-017 Convertida.

Preparación para una futura integración: main[data-cotizacion] identifica la muestra y los elementos data-campo delimitan pieza, estado, responsable, equipo, material y estimación. La futura carga deberá actualizar también título, migas, identificador/membrete del comprobante, desglose, parámetros y enlaces de acciones con los datos del mismo registro. Aún no hay lectura de URL, carga de datos ni control real de permisos.

| Escenario ilustrativo conservado como referencia | Pieza | Estimación | Total / margen / precio COP |
| --- | --- | --- | --- |
| COT-019 · Borrador | Soporte de prueba | 35 g / 1 h | 5.000 / 1.000 / 6.000 |
| COT-018 · Aprobada | Guía de ensamble | 50 g / 2 h | 8.400 / 1.680 / 10.080 |
| COT-017 · Convertida en TR-024 | Engranaje helicoidal | 50 g / 1,6 h | 7.520 / 1.504 / 9.024 |
| COT-016 · Rechazada | Base de prueba | 30 g / 1,2 h | 5.040 / 1.008 / 6.048 |

Reglas para la futura integración: la revisión Borrador → Aprobada/Rechazada corresponde a Administrador/Instructor; solo una Aprobada puede convertirse en trabajo y pasa automáticamente a Convertida. La consulta del aprendiz se limita a sus propias cotizaciones. Rechazada y Convertida no muestran acciones de aprobación o conversión. Los estados siguen ilustrados en la lista; su detalle por registro y sus acciones dinámicas quedan pendientes de conectar. Sin JavaScript adicional, backend, dependencias o cambios SQL.
### Integración de Reportes y consulta de Roles

Los tres informes de Reportes conservan filtros y documento en gastos.html, ganancia.html y produccion.html. El formulario valida campos y navega a #resultado; los datos del informe son fijos y no reproducen cambios en filtros. Producción conserva fechas, responsable y tipo de pieza; gastos/ganancia mantienen perfil Administrador/Coordinador y producción añade Instructor. Se retiraron las tres vistas independientes tras comparar fichas y tablas y verificar cada vista previa A4 de una página.

Las cuatro consultas individuales de permisos se integraron en roles/pages/reporte.html#administrador, #instructor, #aprendiz y #coordinador. La lista enlaza directamente al rol correcto. Se compararon las 176 casillas con los originales antes de retirarlos. Administrador conserva todos los permisos y el aviso de protección; las demás secciones ofrecen edición común de ejemplo con datos fijos de Instructor. El perfil de consulta sigue siendo Administrador. No se implementa autorización real.

La impresión de Roles se comprobó en cinco páginas A4: resumen y una matriz completa por rol. Los permisos se imprimen como Sí/No según checked, sin casillas ni enlaces de edición. Se preservan estados, usuarios asignados y permisos. Navegación y exportación se ocultan al imprimir; PDF/CSV siguen como propuesta visual deshabilitada. Sin JavaScript adicional, backend, cambios SQL, commit ni push.
RF-8.9 visible desde Cotizaciones previas: Acciones incluye el lápiz compartido de Producción para revisar COT-019 Borrador en revisar.html (perfil Administrador/Instructor), con retorno a la lista. Las demás filas conservan el espacio del control y la consulta de ejemplo; no enlazan erróneamente a la revisión de otro registro. Se mantiene la conversión automática desde RF-7.5, sin selector manual Convertida ni persistencia. La maqueta no implementa permisos reales ni carga por registro.

RF-8.9 corregido: Borrador, Aprobada y Rechazada ofrecen lápiz a revisar.html; Convertida conserva solo consulta y reserva vacía para alineación. La revisión común muestra COT-019 fija con aviso explícito; admite Borrador/Aprobada/Rechazada, requiere elegir destino y no ofrece Convertida manualmente (RN-8.9, RF-7.5). La carga y guardado por registro siguen pendientes de implementación, sin JavaScript ni backend.

### Decisión de diseño: cotizaciones convertidas

Una cotización Convertida permanece solo para consulta en la maqueta. Esta es una decisión de diseño para conservar la coherencia con el trabajo asociado, no una prohibición explícita de la matriz. RF-8.9 permite cambiar estados; RN-8.9 reserva la asignación de Convertida al flujo automático RF-7.5; RN-7.5.1 limita la conversión a una sola vez y RN-7.5.2 vincula la creación del trabajo con el cambio de estado. Estas reglas no definen expresamente la reapertura de una cotización ya convertida.

Permitir esa reapertura requeriría definir previamente qué sucede con el trabajo asociado y cómo se impide una segunda conversión. Hasta aclararlo, la fila Convertida no ofrece lápiz, conserva la consulta y mantiene el espacio reservado en Acciones. No se añade JavaScript ni backend; no hay cambios de base de datos ni persistencia.

### Estadísticas: navegación y presentación

Las tres muestras de Estadísticas se conservan: diario (9 nov 2026), semanal (2–8 nov) y mensual acumulado (1–9 nov). estadisticas.css concentra estilos propios del módulo. El selector indica el período activo con aria-current; se mantienen los cuatro indicadores, las tres gráficas y la tabla de rendimiento por responsable. Las barras SVG son estáticas y conservan las proporciones originales; etiquetas y cifras permanecen como texto accesible. Los intervalos agrupados representan totales, no tasas directamente comparables. No se cambiaron las cifras; los decimales usan coma y el singular de pieza se corrigió.

La revisión cubrió escritorio a 1440 px y móvil a 390 px: gráficas en tres columnas desde 1200 px, apiladas debajo; solo la tabla se desplaza horizontalmente. Se verificaron navegación por teclado, foco visible, sumas, etiquetas y referencias. Las tres vistas previas A4 muestran período, indicadores, barras y tabla completos en una página cada una; las barras siguen visibles sin gráficos de fondo activados. Imprimir/Guardar como PDF se realiza desde el navegador con Ctrl+P.

Cobertura de maqueta: RF-9.0/RI-9.0, RN-9.0.1, RF-9.1 y RF-9.2/RI-9.2 están representados con datos ilustrativos. RN-9.0 (consolidación real excluyendo cancelados) y RN-9.2 (actualización desde Producción) quedan pendientes del sistema funcional. RF-9.3/RN-9.3 tienen impresión PDF manual; no exportación automática propia. Sin JavaScript adicional, backend, dependencias ni cambios SQL. No se eliminan páginas ni se realiza commit o push en este cambio.
