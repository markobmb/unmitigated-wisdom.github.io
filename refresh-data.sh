#!/usr/bin/env bash
# Refresh the website's published Mixture-of-Experts data from the canonical
# JSON in Wisdom/data/ (which is its own git repo, untracked here).
# Run from the repo root.

set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/Wisdom/data/Expert_Prediction_Tracker_V24_FULL.json"
OUT_DIR="$HERE/data"
mkdir -p "$OUT_DIR"

python3 - "$SRC" "$OUT_DIR" <<'PY'
import json, os, shutil, sys
src, out_dir = sys.argv[1], sys.argv[2]
with open(src) as f:
    data = json.load(f)
# Publish the JSON unchanged (so a fetch fallback still works).
json_dst = os.path.join(out_dir, 'mixture-of-experts.json')
shutil.copyfile(src, json_dst)
# Publish a JS wrapper so the page works under file:// too.
js_dst = os.path.join(out_dir, 'mixture-of-experts.js')
with open(js_dst, 'w') as f:
    f.write('window.TRACKER_DATA = ')
    json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
    f.write(';\n')
print(f'wrote {json_dst} ({os.path.getsize(json_dst)} bytes)')
print(f'wrote {js_dst} ({os.path.getsize(js_dst)} bytes)')
PY
