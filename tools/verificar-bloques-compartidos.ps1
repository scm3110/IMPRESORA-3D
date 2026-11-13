param(
  [string]$FrontendPath = (Join-Path $PSScriptRoot '../Frontend')
)

$ErrorActionPreference = 'Stop'
$raiz = [IO.Path]::GetFullPath($FrontendPath)
$errores = [Collections.Generic.List[string]]::new()

# Lee un atributo sin depender de su posición dentro de la etiqueta.
function Obtener-Atributo([string]$etiqueta, [string]$nombre) {
  $patron = '\s' + [regex]::Escape($nombre) + '\s*=\s*(["''])(?<valor>.*?)\1'
  return [regex]::Match($etiqueta, $patron).Groups['valor'].Value
}

function Obtener-Bloque([string]$html, [string]$patron, [string]$archivo) {
  $bloques = [regex]::Matches($html, $patron, 'Singleline')
  if ($bloques.Count -ne 1) {
    throw "Se esperaba un único bloque compartido en $archivo; encontrados: $($bloques.Count)."
  }
  return $bloques[0].Value
}

# Compara destinos: ../../../index.html y index.html pueden señalar el mismo archivo.
# Conserva consultas y anclas para no ocultar cambios en esos valores.
function Resolver-Ruta([string]$ruta, [string]$archivo) {
  if ($ruta -match '^(?:[a-zA-Z][a-zA-Z0-9+.-]*:|//)') { return $ruta }
  $partes = [regex]::Match($ruta, '^(?<archivo>[^?#]*)(?<sufijo>.*)$')
  $rutaLocal = [Uri]::UnescapeDataString($partes.Groups['archivo'].Value)
  $destino = if (-not $rutaLocal) { $archivo } else {
    [IO.Path]::GetFullPath((Join-Path ([IO.Path]::GetDirectoryName($archivo)) $rutaLocal))
  }
  $relativa = [IO.Path]::GetRelativePath($raiz, $destino).Replace('\', '/')
  return 'frontend:/' + $relativa + $partes.Groups['sufijo'].Value
}

function Normalizar-Bloque([string]$bloque, [string]$archivo, [switch]$Menu) {
  $normalizado = [regex]::Replace($bloque, '<!--.*?-->', '', 'Singleline')
  $patronRuta = '(?<atributo>\s(?:href|src|action))\s*=\s*(?<comilla>["''])(?<ruta>.*?)\k<comilla>'
  $normalizado = [regex]::Replace($normalizado, $patronRuta, [Text.RegularExpressions.MatchEvaluator]{
    param($m)
    $m.Groups['atributo'].Value + '="' + (Resolver-Ruta $m.Groups['ruta'].Value $archivo) + '"'
  })
  if ($Menu) {
    # El estado activo se valida por separado; el resto del menú debe ser idéntico.
    $normalizado = [regex]::Replace($normalizado, '<a\b[^>]*>', [Text.RegularExpressions.MatchEvaluator]{
      param($m)
      $enlace = [regex]::Replace($m.Value, '\sclass=(["''])(?<clases>.*?)\1', [Text.RegularExpressions.MatchEvaluator]{
        param($clase)
        $restantes = @($clase.Groups['clases'].Value -split '\s+' | Where-Object { $_ -and $_ -ne 'actual' })
        if ($restantes.Count) { return ' class="' + ($restantes -join ' ') + '"' }
        return ''
      })
      return [regex]::Replace($enlace, '\saria-current=(["'']).*?\1', '')
    })
  }
  return [regex]::Replace($normalizado, '\s+', ' ').Trim()
}

function Validar-Menu([string]$bloque, [string]$archivo, [string]$modulo) {
  $navegacion = Obtener-Bloque $bloque '<nav\b[^>]*\bid="navegacion"[^>]*>.*?</nav>' $archivo
  $activos = 0
  foreach ($enlace in [regex]::Matches($navegacion, '<a\b[^>]*>')) {
    $clases = (Obtener-Atributo $enlace.Value 'class') -split '\s+'
    $estado = Obtener-Atributo $enlace.Value 'aria-current'
    $tieneEstado = $enlace.Value -match '\saria-current\s*='
    if ('actual' -in $clases -or $tieneEstado) {
      $activos++
      $destino = Resolver-Ruta (Obtener-Atributo $enlace.Value 'href') $archivo
      if ('actual' -notin $clases -or $estado -ne 'location' -or $destino -ne "frontend:/features/$modulo/pages/index.html") {
        $errores.Add("Estado activo incorrecto: $archivo")
      }
    }
  }
  if ($activos -ne 1) { $errores.Add("Debe haber un único módulo activo: $archivo") }

  # La etiqueta debe seguir inmediatamente al input y nav debe ser su hermano.
  $sinComentarios = [regex]::Replace($bloque, '<!--.*?-->', '', 'Singleline')
  $ordenMovil = '<input\b[^>]*\bid="control-menu"[^>]*>\s*<label\b[^>]*\bfor="control-menu"[^>]*>[^<]*</label>\s*<nav\b[^>]*\bid="navegacion"'
  if ($sinComentarios -notmatch $ordenMovil) {
    $errores.Add("Orden de elementos del menú móvil alterado: $archivo")
  }
}

$archivoReferencia = Join-Path $raiz 'features/dashboard/pages/index.html'
$patronMenu = '<aside\b[^>]*\bclass="lateral"[^>]*>.*?</aside>'
$htmlReferencia = [IO.File]::ReadAllText($archivoReferencia)
$menuReferencia = Obtener-Bloque $htmlReferencia $patronMenu $archivoReferencia
$menuEsperado = Normalizar-Bloque $menuReferencia $archivoReferencia -Menu
$paginas = @(Get-ChildItem -LiteralPath (Join-Path $raiz 'features') -Recurse -Filter '*.html' -File)
$menus = 0
foreach ($pagina in $paginas) {
  $relativa = [IO.Path]::GetRelativePath($raiz, $pagina.FullName).Replace('\', '/')
  if ($relativa -notmatch '^features/(?<modulo>[^/]+)/pages/') { throw "Página fuera de la estructura esperada: $relativa" }
  $modulo = $Matches['modulo']
  if ($modulo -eq 'acceso') { continue }
  $html = [IO.File]::ReadAllText($pagina.FullName)
  $menu = Obtener-Bloque $html $patronMenu $pagina.FullName
  Validar-Menu $menu $pagina.FullName $modulo
  if ((Normalizar-Bloque $menu $pagina.FullName -Menu) -cne $menuEsperado) {
    $errores.Add("Menú distinto de la referencia dashboard: $($pagina.FullName)")
  }
  $menus++
}

# Se compara todo el contenido de acceso: título, formulario y enlace de recuperación.
$accesos = @((Join-Path $raiz 'features/acceso/pages/index.html'), (Join-Path $raiz 'index.html'))
$accesoEsperado = $null
foreach ($archivo in $accesos) {
  $html = [IO.File]::ReadAllText($archivo)
  $contenido = Obtener-Bloque $html '<main\b[^>]*>.*?</main>' $archivo
  if ([regex]::Matches($contenido, '<form\b').Count -ne 1) { $errores.Add("Debe existir un único formulario de acceso: $archivo") }
  $acceso = Normalizar-Bloque $contenido $archivo
  if ($null -eq $accesoEsperado) { $accesoEsperado = $acceso } elseif ($acceso -cne $accesoEsperado) {
    $errores.Add("Acceso distinto de la referencia del módulo: $archivo")
  }
}

if ($errores.Count) {
  $errores | ForEach-Object { Write-Output $_ }
  throw "$($errores.Count) diferencias en bloques compartidos. No se modificó ningún archivo."
}
Write-Output "$menus menús y 2 accesos coherentes; estados activos y orden del menú móvil verificados. No se modificó ningún archivo."
