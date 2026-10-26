$ErrorActionPreference = 'Stop'

$ModuleDir = $PSScriptRoot
$RepoDir = Split-Path -Parent $ModuleDir
$VenvPython = Join-Path $ModuleDir '.venv\Scripts\python.exe'

if (-not (Test-Path -LiteralPath $VenvPython)) {
  Write-Host '[setup:toxicity] Creant l’entorn Python 3.14 dins del mòdul'
  & py -3.14 -m venv (Join-Path $ModuleDir '.venv')
  if ($LASTEXITCODE -ne 0) { throw 'No s’ha pogut crear toxicity-classificator/.venv' }
}

Write-Host '[setup:toxicity] Instal·lant PyTorch CPU'
& $VenvPython -m pip install --disable-pip-version-check --index-url https://download.pytorch.org/whl/cpu 'torch>=2.0.0'
if ($LASTEXITCODE -ne 0) { throw 'No s’ha pogut instal·lar PyTorch CPU' }

Write-Host '[setup:toxicity] Instal·lant Laya i les dependències del servici'
& $VenvPython -m pip install --disable-pip-version-check -r (Join-Path $ModuleDir 'requirements.txt')
if ($LASTEXITCODE -ne 0) { throw 'No s’han pogut instal·lar les dependències del classificador' }

& $VenvPython -m pip check
if ($LASTEXITCODE -ne 0) { throw 'L’entorn de toxicity-classificator té dependències incompatibles' }

Write-Host '[setup:toxicity] Entorn preparat. Per a iniciar el sidecar:'
Write-Host "  & '$VenvPython' -m uvicorn server:app --app-dir `"$ModuleDir`" --host 127.0.0.1 --port 8001"
Write-Host '[setup:toxicity] El model es descarregarà de Hugging Face en el primer inici del servici.'
