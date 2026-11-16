param([switch]$Comprobar)

$ErrorActionPreference = 'Stop'
$raiz = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../Frontend'))
$plantilla = [IO.File]::ReadAllText((Join-Path $raiz 'shared/templates/acceso-lateral.html.tpl')).TrimEnd()
$paginas = @((Join-Path $raiz 'index.html')) + @(Get-ChildItem -LiteralPath (Join-Path $raiz 'features/acceso/pages') -Filter '*.html' -File | ForEach-Object FullName)
$patron = '(?s)    <!-- Inicio del lateral de acceso compartido\. -->.*?    <!-- Fin del lateral de acceso compartido\. -->'
$cambios = @()
# Validar todos los destinos antes de escribir cualquiera.
foreach ($pagina in $paginas) {
  $html = [IO.File]::ReadAllText($pagina)
  if ([regex]::Matches($html, $patron).Count -ne 1) { throw "Delimitadores del lateral ausentes o duplicados: $pagina" }
  $prefijo = if ($pagina -eq (Join-Path $raiz 'index.html')) { '' } else { '../../../' }
  $bloque = "    <!-- Inicio del lateral de acceso compartido. -->`r`n" + $plantilla.Replace('{{raiz}}', $prefijo) + "`r`n    <!-- Fin del lateral de acceso compartido. -->"
  $actual = [regex]::Match($html, $patron).Value
  if ($actual.Replace("`r`n", "`n") -cne $bloque.Replace("`r`n", "`n")) {
    $cambios += @{ Ruta = $pagina; Contenido = $html.Replace($actual, $bloque) }
  }
}
if ($Comprobar) {
  if ($cambios.Count) { throw "Hay $($cambios.Count) laterales distintos de la plantilla. Ejecuta tools/actualizar-lateral-acceso.ps1." }
  Write-Output "$($paginas.Count) laterales coherentes con la plantilla. No se modificó ningún archivo."
} else {
  foreach ($cambio in $cambios) { [IO.File]::WriteAllText($cambio.Ruta, $cambio.Contenido, [Text.UTF8Encoding]::new($false)) }
  Write-Output "$($cambios.Count) laterales actualizados desde la plantilla."
}
