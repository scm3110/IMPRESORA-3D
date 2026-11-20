# Guía para contribuir al repositorio

## Estructura del proyecto y organización de módulos

Edita las pantallas completas en Frontend/features/<modulo>/pages/. Los módulos contienen únicamente pages/. El contenido propio permanece en main#contenido; no dupliques allí el sidebar, encabezado ni pie. Las cuatro plantillas HTML están en Frontend/shared/templates/ y shared/scripts/layout.js las carga con fetch. El body indica data-layout y data-modulo. CSS en shared/styles/, recursos en shared/assets/ y Bootstrap en vendor/bootstrap/. Consulta README.md, documentos/ y Base de datos/.

## Comandos de desarrollo y compilación

Usa Go Live (Live Server), con raíz /Frontend y puerto 5500, abriendo features/acceso/pages/index.html. F5 abre esa misma URL y requiere Live Server iniciado. No abras las páginas por file://. No hay compilación, generador ni carpeta de salida. Ejecuta pwsh -File tools/verificar-rutas.ps1 y pwsh -File tools/verificar-bloques-compartidos.ps1; ambos son de solo lectura.

## Estilo de código y convenciones de nombres

Usa HTML semántico e indentación de dos espacios. Escribe en español los textos y comentarios. Nombra las clases CSS en kebab-case, define valores visuales compartidos con variables CSS y guarda los estilos en archivos CSS, no inline. Usa Bootstrap para la cuadrícula y componentes. El alcance es una maqueta estática con JavaScript autorizado solo para cargar bloques compartidos, sin backend ni librerías nuevas.

Conserva los comentarios que delimitan bloques compartidos y el orden input/label/nav del menú móvil. Usa la plantilla del sidebar y el acceso del módulo como referencias; consulta el README antes de modificar sus copias o datos ilustrativos relacionados.

## Requisitos y reglas del dominio

Usa la matriz y los casos de uso para definir pantallas, roles, campos y reglas; consulta el SQL para verificar nombres y relaciones. Revisa `documentos/Caso de uso - Impresion3d.eap` antes de implementar flujos. Figma orienta el diseño, no las reglas de negocio. Marca las métricas y registros de ejemplo como ilustrativos.

## Criterios de prueba

No hay marco de pruebas ni objetivo de cobertura. Revisa en un navegador los enlaces, las etiquetas de formularios, la legibilidad, el contraste y la adaptación a escritorio y móvil. No agregues dependencias de pruebas o análisis sin una necesidad acordada.

## Commits y solicitudes de cambio

El historial tiene un commit de documentación en español con prefijo de tipo; no hay una convención consolidada. Usa asuntos breves, por ejemplo: `frontend: agregar vista de inventario`. Describe los módulos afectados en las solicitudes de cambio e incluye capturas de los cambios visuales.

## Instrucciones para agentes

Lee `MEMORY.md` al inicio de cada tarea y actualízalo al terminar; mantenlo en unas 50 líneas o menos. Nunca guardes contraseñas, tokens ni datos personales. Pregunta antes de agregar dependencias, funcionalidad JavaScript adicional al cargador compartido, backend/API o modificar la base de datos.
