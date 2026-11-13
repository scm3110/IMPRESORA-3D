# Guía para contribuir al repositorio

## Estructura del proyecto y organización de módulos

Usa la arquitectura híbrida por funcionalidad de `Frontend/`. Edita las vistas en `Frontend/features/<modulo>/pages/` y los estilos y recursos exclusivos en las carpetas `styles/` y `assets/` de ese módulo. Los estilos comunes están en `Frontend/shared/styles/`, los recursos comunes en `Frontend/shared/assets/` y Bootstrap en `Frontend/vendor/bootstrap/`. La navegación y los layouts están escritos en cada HTML; mantén consistentes los cambios comunes. Consulta el README para crear una pantalla. Los requisitos y prototipos están en `documentos/` y los modelos en `Base de datos/`.

## Comandos de desarrollo y compilación

Abre `Frontend/index.html` en el navegador; esta copia contiene HTML y CSS estáticos, sin instalación ni compilación. Ejecuta `pwsh -File tools/verificar-rutas.ps1` y `pwsh -File tools/verificar-bloques-compartidos.ps1` desde la raíz para comprobar rutas y consistencia de menús y accesos. Ambas herramientas son de solo lectura.

## Estilo de código y convenciones de nombres

Usa HTML semántico e indentación de dos espacios. Escribe en español los textos y comentarios. Nombra las clases CSS en kebab-case, define valores visuales compartidos con variables CSS y guarda los estilos en archivos CSS, no inline. Usa Bootstrap para la cuadrícula y componentes. El alcance es una maqueta estática, sin JavaScript en el navegador ni backend.

Conserva los comentarios que delimitan bloques compartidos y el orden input/label/nav del menú móvil. Usa el menú del dashboard y el acceso del módulo como referencias; consulta el README antes de modificar sus copias o datos ilustrativos relacionados.

## Requisitos y reglas del dominio

Usa la matriz y los casos de uso para definir pantallas, roles, campos y reglas; consulta el SQL para verificar nombres y relaciones. Revisa `documentos/Caso de uso - Impresion3d.eap` antes de implementar flujos. Figma orienta el diseño, no las reglas de negocio. Marca las métricas y registros de ejemplo como ilustrativos.

## Criterios de prueba

No hay marco de pruebas ni objetivo de cobertura. Revisa en un navegador los enlaces, las etiquetas de formularios, la legibilidad, el contraste y la adaptación a escritorio y móvil. No agregues dependencias de pruebas o análisis sin una necesidad acordada.

## Commits y solicitudes de cambio

El historial tiene un commit de documentación en español con prefijo de tipo; no hay una convención consolidada. Usa asuntos breves, por ejemplo: `frontend: agregar vista de inventario`. Describe los módulos afectados en las solicitudes de cambio e incluye capturas de los cambios visuales.

## Instrucciones para agentes

Lee `MEMORY.md` al inicio de cada tarea y actualízalo al terminar; mantenlo en unas 50 líneas o menos. Nunca guardes contraseñas, tokens ni datos personales. Pregunta antes de agregar dependencias, JavaScript, backend/API o modificar la base de datos.
