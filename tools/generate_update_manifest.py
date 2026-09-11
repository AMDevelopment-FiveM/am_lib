from pathlib import Path
import json, re

ROOT = Path(__file__).resolve().parents[1]
EXCLUDE_FILES = {'config.lua', 'update.json'}
EXCLUDE_PREFIXES = ('custom/', 'backups/', '.git/', 'tools/')

fx = (ROOT / 'fxmanifest.lua').read_text(encoding='utf-8')
m = re.search(r"version\s+['\"]([^'\"]+)['\"]", fx)
if not m:
    raise SystemExit('Could not find version in fxmanifest.lua')

files = []
for p in ROOT.rglob('*'):
    if not p.is_file():
        continue
    rel = p.relative_to(ROOT).as_posix()
    if rel in EXCLUDE_FILES or any(rel.startswith(prefix) for prefix in EXCLUDE_PREFIXES):
        continue
    files.append({'path': rel})

manifest = {
    'name': 'am_lib',
    'version': m.group(1),
    'files': sorted(files, key=lambda x: x['path']),
    'delete': []
}
(ROOT / 'update.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
print(f"Generated update.json for v{manifest['version']} with {len(files)} files")
