#!/usr/bin/env bash
set -euo pipefail

echo "→ Finding all exports generated using turbo..."
exports=()
while IFS= read -r file; do
  exports+=("$file")
done < <(find ./turbo/keys -type f -name "*-export.json")

echo "found exports: ${#exports[@]}"

if [ ${#exports[@]} -eq 0 ]; then
  echo "⚠️ No export files found under ./turbo/keys/"
  exit 1
fi

echo "→ Copying exports to python_orchestrator/web/ ..."
mkdir -p python_orchestrator/web/

for file in "${exports[@]}"; do
  echo "   copying $(basename "$file")"
  cp "$file" python_orchestrator/web/
done

echo "→ Initializing mining process..."
cd python_orchestrator

echo "→ Reading all export files from python_orchestrator/web/"
uv run main.py init web/*.json

echo "→ Starting mining..."
uv run main.py run