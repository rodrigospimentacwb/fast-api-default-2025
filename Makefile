SHELL := powershell.exe
.SHELLFLAGS := -NoProfile -Command

.PHONY: clean-cache
clean-cache:
	Get-ChildItem -Path . -Recurse -Force -Include '__pycache__','*.pyc','*.pyo','.pytest_cache','.mypy_cache','.ruff_cache' | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# ---------------------------------------------------------------------------
# clean-cache: remove caches Python e de ferramentas (silencioso se nada houver)
# ---------------------------------------------------------------------------
clean-cache:
	powershell -NoProfile -Command "Get-ChildItem -Path . -Recurse -Force -Include '__pycache__','*.pyc','*.pyo','.pytest_cache','.mypy_cache','.ruff_cache' | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"

# ---------------------------------------------------------------------------
# dev: sobe a API local na porta 8082
# ---------------------------------------------------------------------------
dev:
	uv run uvicorn app.main:create_app --factory --port 8082 --reload

# ---------------------------------------------------------------------------
# stop-dev: derruba o processo que está escutando a porta 8082
# ---------------------------------------------------------------------------
stop-dev:
	$pid = (Get-NetTCPConnection -LocalPort 8082 -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty OwningProcess); \
	if ($pid) { Stop-Process -Id $$pid -Force; Write-Host "Parado PID $$pid (porta 8082)." } else { Write-Host "Nenhum processo na porta 8082." }

# ---------------------------------------------------------------------------
# ruff-check: executa lint (sem formatar)
# ---------------------------------------------------------------------------
ruff-check:
	uv run ruff check .

# ---------------------------------------------------------------------------
# ruff-fix: executa lint com correções automáticas
# ---------------------------------------------------------------------------
ruff-fix:
	uv run ruff check . --fix

# ---------------------------------------------------------------------------
# pre-commit-update: atualiza versões dos hooks (rev: ...)
# ---------------------------------------------------------------------------
pre-commit-update:
	uv run pre-commit autoupdate

# ---------------------------------------------------------------------------
# check-all: roda TODOS os hooks em TODOS os arquivos (mais lento)
# ---------------------------------------------------------------------------
check-all:
	uv run pre-commit run --all-files

# ---------------------------------------------------------------------------
# check: roda hooks só nos arquivos staged/alterados (fluxo rápido do dia a dia, afeta apenas os aqruivos do commit)
# ---------------------------------------------------------------------------
check:
	uv run pre-commit run

# ---------------------------------------------------------------------------
# uv-reinstall: reinstala dependências do projeto (inclui dev)
# ---------------------------------------------------------------------------
uv-reinstall:
	uv sync --dev --reinstall

# ---------------------------------------------------------------------------
# test: executa a suíte de testes via uv (usa o venv do projeto)
# ---------------------------------------------------------------------------
test:
	uv run pytest -q
