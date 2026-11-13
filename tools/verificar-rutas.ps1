$ErrorActionPreference = 'Stop'
$frontend = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../Frontend'))
$errores = [Collections.Generic.List[string]]::new()
$referencias = 0
$paginas = @(Get-ChildItem -LiteralPath $frontend -Recurse -Filter '*.html' -File)
$estilos = @(Get-ChildItem -LiteralPath $frontend -Recurse -Filter '*.css' -File)

foreach ($archivo in @($paginas) + @($estilos)) {
  $contenido = [IO.File]::ReadAllText($archivo.FullName)
  $patron = if ($archivo.Extension -eq '.html') {
    '\b(?:href|src|action)\s*=\s*["''](?<ruta>[^"'']+)["'']'
  } else {
    'url\(\s*["'']?(?<ruta>[^)"'']+)["'']?\s*\)'
  }
  foreach ($coincidencia in [regex]::Matches($contenido, $patron)) {
    $ruta = $coincidencia.Groups['ruta'].Value.Trim()
    if ($ruta -match '^(?:[a-zA-Z][a-zA-Z0-9+.-]*:|//)') { continue }
    $referencias++
    $partes = $ruta -split '#', 2
    $rutaArchivo = ($partes[0] -split '\?', 2)[0]
    $destino = if (-not $rutaArchivo) { $archivo.FullName } else {
      [IO.Path]::GetFullPath((Join-Path $archivo.DirectoryName ([Uri]::UnescapeDataString($rutaArchivo))))
    }
    if (-not (Test-Path -LiteralPath $destino -PathType Leaf)) {
      $errores.Add("$($archivo.FullName) -> $ruta")
      continue
    }
    if ($partes.Count -eq 2 -and $partes[1] -and [IO.Path]::GetExtension($destino) -eq '.html') {
      $id = [regex]::Escape([Uri]::UnescapeDataString($partes[1]))
      if ([IO.File]::ReadAllText($destino) -notmatch ('\bid\s*=\s*["'']' + $id + '["'']')) {
        $errores.Add("Ancla inexistente: $($archivo.FullName) -> $ruta")
      }
    }
  }
}
if ($errores.Count) {
  $errores | ForEach-Object { Write-Output $_ }
  throw "$($errores.Count) referencias inválidas."
}
Write-Output "$($paginas.Count) páginas y $($estilos.Count) hojas CSS verificadas; $referencias referencias locales válidas."
