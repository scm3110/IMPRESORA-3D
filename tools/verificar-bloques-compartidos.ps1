param([string]$FrontendPath = (Join-Path $PSScriptRoot '../Frontend'))

$ErrorActionPreference = 'Stop'
$raiz = [IO.Path]::GetFullPath($FrontendPath)
$errores = [Collections.Generic.List[string]]::new()

function Atributo([string]$etiqueta, [string]$nombre) {
  return [regex]::Match($etiqueta, '\s' + [regex]::Escape($nombre) + '\s*=\s*"(?<valor>[^"]*)"').Groups['valor'].Value
}

# Las plantillas deben conservar la estructura que espera el cargador de JavaScript.
$estructuras = @{
  'sidebar' = '(?s)^\s*<aside class="lateral">.*</aside>\s*$'
  'acceso-lateral' = '(?s)^\s*<aside class="identidad">.*</aside>\s*$'
  'encabezado-gestion' = '(?s)^\s*<header class="barra">.*</header>\s*$'
  'pie-gestion' = '(?s)^\s*<footer class="pie-interno">.*</footer>\s*$'
}
foreach ($nombre in $estructuras.Keys) {
  $contenido = [IO.File]::ReadAllText((Join-Path $raiz ('shared/templates/' + $nombre + '.html')))
  if ($contenido -notmatch $estructuras[$nombre]) { $errores.Add("Estructura de plantilla incorrecta: $nombre") }
  $sinMarcadores = [regex]::Replace($contenido, '\{\{(?:raiz|activo:[a-z0-9-]+)\}\}', '')
  if ($sinMarcadores -match '\{\{') { $errores.Add("Marcador desconocido en $nombre") }
}
$sidebar = [IO.File]::ReadAllText((Join-Path $raiz 'shared/templates/sidebar.html'))
$sinComentarios = [regex]::Replace($sidebar, '(?s)<!--.*?-->', '')
$orden = '<input\b[^>]*\bid="control-menu"[^>]*>\s*<label\b[^>]*\bfor="control-menu"[^>]*>[^<]*</label>\s*<nav\b[^>]*\bid="navegacion"'
if ($sinComentarios -notmatch $orden) { $errores.Add('Orden input/label/nav del menú móvil alterado.') }
foreach ($modulo in Get-ChildItem -LiteralPath (Join-Path $raiz 'features') -Directory) {
  if ($modulo.Name -eq 'acceso') { continue }
  $enlace = 'href="{{raiz}}features/' + $modulo.Name + '/pages/index.html"{{activo:' + $modulo.Name + '}}'
  if ([regex]::Matches($sidebar, [regex]::Escape($enlace)).Count -ne 1) {
    $errores.Add("Enlace o marcador activo incorrecto para el módulo $($modulo.Name)")
  }
}
if ([regex]::Matches($sidebar, 'class="cerrar-sesion"').Count -ne 1 -or
    $sidebar -notmatch 'href="\{\{raiz\}\}features/acceso/pages/index.html" class="cerrar-sesion"') {
  $errores.Add('Cerrar sesión debe aparecer una vez y enlazar al acceso.')
}

$total = 0
foreach ($pagina in Get-ChildItem -LiteralPath (Join-Path $raiz 'features') -Recurse -File -Filter '*.html') {
  $relativa = [IO.Path]::GetRelativePath($raiz, $pagina.FullName).Replace('\', '/')
  if ($relativa -notmatch '^features/(?<modulo>[^/]+)/pages/[^/]+\.html$') { throw "Ruta no admitida: $relativa" }
  $modulo = $Matches['modulo']
  $layout = if ($modulo -eq 'acceso') { 'acceso' } else { 'gestion' }
  $html = [IO.File]::ReadAllText($pagina.FullName)
  $body = [regex]::Match($html, '<body\b[^>]*>').Value
  if ((Atributo $body 'data-layout') -ne $layout -or (Atributo $body 'data-modulo') -ne $modulo) {
    $errores.Add("Layout o módulo incorrecto: $relativa")
  }
  if ([regex]::Matches($html, '<main\b[^>]*\bid="contenido"').Count -ne 1) {
    $errores.Add("Debe existir un único contenido principal: $relativa")
  }
  $scripts = [regex]::Matches($html, '<script\b[^>]*>')
  if ($scripts.Count -ne 1 -or (Atributo $scripts[0].Value 'src') -ne '../../../shared/scripts/layout.js' -or $scripts[0].Value -notmatch '\sdefer\b') {
    $errores.Add("Carga del script compartido incorrecta: $relativa")
  }
  if ($html -match '<aside\b|<header class="barra"|<footer class="pie-interno"|\{\{') {
    $errores.Add("Hay copias de bloques compartidos o marcadores en la pantalla: $relativa")
  }
  $ids = @([regex]::Matches($html, '\bid="(?<id>[^"]+)"') | ForEach-Object { $_.Groups['id'].Value })
  if (@($ids | Group-Object | Where-Object Count -gt 1).Count) { $errores.Add("IDs duplicados: $relativa") }
  $total++
}
$acceso = [IO.File]::ReadAllText((Join-Path $raiz 'features/acceso/pages/index.html'))
if ([regex]::Matches($acceso, '<form\b').Count -ne 1) { $errores.Add('El inicio de sesión debe tener un único formulario.') }
if (-not (Test-Path -LiteralPath (Join-Path $raiz 'shared/scripts/layout.js') -PathType Leaf)) {
  $errores.Add('No existe shared/scripts/layout.js.')
}
if ($errores.Count) {
  $errores | ForEach-Object { Write-Output $_ }
  throw "$($errores.Count) errores en bloques compartidos. No se modificó ningún archivo."
}
Write-Output "$total pantallas y 4 plantillas verificadas; carga compartida, módulos y menú móvil coherentes. No se modificó ningún archivo."
