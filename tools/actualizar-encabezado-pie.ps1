param(
  [switch]$Comprobar,
  [string]$FrontendPath = (Join-Path $PSScriptRoot '../Frontend')
)

$ErrorActionPreference = 'Stop'
$raiz = [IO.Path]::GetFullPath($FrontendPath)
$bloques = @(
  @{ Nombre = 'encabezado'; Elemento = '(?s)<header class="barra">.*?</header>' },
  @{ Nombre = 'pie'; Elemento = '(?s)<footer class="pie-interno">.*?</footer>' }
)
foreach ($bloque in $bloques) {
  $ruta = Join-Path $raiz ('shared/templates/' + $bloque.Nombre + '-gestion.html')
  $bloque.Plantilla = [IO.File]::ReadAllText($ruta).TrimEnd()
  if ([regex]::Matches($bloque.Plantilla, $bloque.Elemento).Count -ne 1 -or
      [regex]::Replace($bloque.Plantilla, $bloque.Elemento, '').Trim()) {
    throw "La plantilla debe contener únicamente un $($bloque.Nombre): $ruta"
  }
  $bloque.Patron = '(?s)        <!-- Inicio del ' + $bloque.Nombre + ' compartido\. -->.*?        <!-- Fin del ' + $bloque.Nombre + ' compartido\. -->'
  $bloque.Esperado = '        <!-- Inicio del ' + $bloque.Nombre + " compartido. -->`r`n" +
    $bloque.Plantilla + "`r`n        <!-- Fin del " + $bloque.Nombre + ' compartido. -->'
}
$cambios = @()
$total = 0

# Validar todas las páginas antes de escribir: un error no deja una actualización parcial.
foreach ($pagina in Get-ChildItem -LiteralPath (Join-Path $raiz 'features') -Recurse -Filter '*.html' -File) {
  $relativa = [IO.Path]::GetRelativePath($raiz, $pagina.FullName).Replace('\', '/')
  if ($relativa -notmatch '^features/(?<modulo>[^/]+)/pages/[^/]+\.html$') {
    throw "Página fuera de la estructura esperada: $relativa"
  }
  if ($Matches['modulo'] -eq 'acceso') { continue }
  $html = [IO.File]::ReadAllText($pagina.FullName)
  $nuevo = $html
  foreach ($bloque in $bloques) {
    $encontrados = [regex]::Matches($nuevo, $bloque.Patron)
    if ($encontrados.Count -ne 1 -or [regex]::Matches($nuevo, $bloque.Elemento).Count -ne 1) {
      throw "Bloque de $($bloque.Nombre) ausente o duplicado: $($pagina.FullName)"
    }
    if ($encontrados[0].Value.Replace("`r`n", "`n") -cne $bloque.Esperado.Replace("`r`n", "`n")) {
      $nuevo = $nuevo.Replace($encontrados[0].Value, $bloque.Esperado)
    }
  }
  if ($nuevo -cne $html) { $cambios += @{ Ruta = $pagina.FullName; Contenido = $nuevo } }
  $total++
}
if ($Comprobar) {
  if ($cambios.Count) { throw "Hay $($cambios.Count) páginas distintas de las plantillas. Ejecuta tools/actualizar-encabezado-pie.ps1." }
  Write-Output "$total encabezados y $total pies coherentes con sus plantillas. No se modificó ningún archivo."
} else {
  foreach ($cambio in $cambios) {
    [IO.File]::WriteAllText($cambio.Ruta, $cambio.Contenido, [Text.UTF8Encoding]::new($false))
  }
  Write-Output "$($cambios.Count) páginas actualizadas desde las plantillas de encabezado y pie."
}
