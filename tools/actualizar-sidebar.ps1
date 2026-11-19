param(
  [switch]$Comprobar,
  [string]$FrontendPath = (Join-Path $PSScriptRoot '../Frontend')
)

$ErrorActionPreference = 'Stop'
$raiz = [IO.Path]::GetFullPath($FrontendPath)
$rutaPlantilla = Join-Path $raiz 'shared/templates/sidebar.html'
$plantilla = [IO.File]::ReadAllText($rutaPlantilla).TrimEnd()
$patron = '(?s)      <!-- Inicio del menú compartido\. Mantener sus copias sincronizadas\. -->.*?      <!-- Fin del menú compartido\. -->'
$paginas = @(Get-ChildItem -LiteralPath (Join-Path $raiz 'features') -Recurse -Filter '*.html' -File)
$cambios = @()
$total = 0

# Preparar todos los bloques y validar los delimitadores antes de escribir.
foreach ($pagina in $paginas) {
  $relativa = [IO.Path]::GetRelativePath($raiz, $pagina.FullName).Replace('\', '/')
  if ($relativa -notmatch '^features/(?<modulo>[^/]+)/pages/[^/]+\.html$') {
    throw "Página fuera de la estructura esperada: $relativa"
  }
  $modulo = $Matches['modulo']
  if ($modulo -eq 'acceso') { continue }
  if ([regex]::Matches($plantilla, [regex]::Escape('{{activo:' + $modulo + '}}')).Count -ne 1) {
    throw "La plantilla debe tener un marcador activo para el módulo: $modulo"
  }
  $html = [IO.File]::ReadAllText($pagina.FullName)
  $bloques = [regex]::Matches($html, $patron)
  if ($bloques.Count -ne 1) { throw "Delimitadores del sidebar ausentes o duplicados: $($pagina.FullName)" }
  $prefijo = [IO.Path]::GetRelativePath($pagina.DirectoryName, $raiz).Replace('\', '/') + '/'
  $lateral = $plantilla.Replace('{{raiz}}', $prefijo)
  $lateral = [regex]::Replace($lateral, '\{\{activo:(?<modulo>[^}]+)\}\}', [Text.RegularExpressions.MatchEvaluator]{
    param($m)
    if ($m.Groups['modulo'].Value -eq $modulo) { return ' class="actual" aria-current="location"' }
    return ''
  })
  if ($lateral -match '\{\{') { throw "Marcador de plantilla sin resolver: $($pagina.FullName)" }
  $bloque = "      <!-- Inicio del menú compartido. Mantener sus copias sincronizadas. -->`r`n" + $lateral + "`r`n      <!-- Fin del menú compartido. -->"
  if ($bloques[0].Value.Replace("`r`n", "`n") -cne $bloque.Replace("`r`n", "`n")) {
    $cambios += @{ Ruta = $pagina.FullName; Contenido = $html.Replace($bloques[0].Value, $bloque) }
  }
  $total++
}
if ($Comprobar) {
  if ($cambios.Count) { throw "Hay $($cambios.Count) sidebars distintos de la plantilla. Ejecuta tools/actualizar-sidebar.ps1." }
  Write-Output "$total sidebars coherentes con la plantilla. No se modificó ningún archivo."
} else {
  foreach ($cambio in $cambios) {
    [IO.File]::WriteAllText($cambio.Ruta, $cambio.Contenido, [Text.UTF8Encoding]::new($false))
  }
  Write-Output "$($cambios.Count) sidebars actualizados desde la plantilla."
}
