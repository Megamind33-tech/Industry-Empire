"""Batch-render every asset in art/assets.csv that has a model, in parallel, skipping unchanged ones.

usage: python3 -I art/tools/render_all.py [--jobs N] [--draft] [--only CATEGORY] [--force]

The "model" column is a procedural module name (art/blender/models/<name>.py) or a path
under art/ to a downloaded model, optionally followed by ";yaw=90;paint=regex".
A render is skipped when a hash of the model file, the renderer and its options
matches the stamp left by the last render.
"""
import argparse
import csv
import hashlib
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

ART = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BLENDER = os.environ.get("BLENDER", "blender")


def model_path(spec):
    name = spec.split(";")[0]
    proc = os.path.join(ART, "blender", "models", name + ".py")
    return (proc if os.path.exists(proc) else os.path.join(ART, name)), name


def digest(row, samples):
    h = hashlib.sha256()
    path, _ = model_path(row["model"])
    for f in (path, os.path.join(ART, "blender", "te_render.py"), os.path.join(ART, "tools", "pack_vehicle.py")):
        with open(f, "rb") as fh:
            h.update(fh.read())
    h.update(f"{row['model']}|{row['category']}|{samples}".encode())
    return h.hexdigest()


def render(row, samples, threads, force):
    out = os.path.join(ART, "build", row["id"])
    stamp = os.path.join(out, ".stamp")
    d = digest(row, samples)
    if not force and os.path.exists(stamp) and open(stamp).read() == d:
        return row["id"], "cached"
    path, name = model_path(row["model"])
    opts = dict(kv.split("=", 1) for kv in row["model"].split(";")[1:])
    cmd = [BLENDER, "-b", "-t", str(threads), "-P", os.path.join(ART, "blender", "te_render.py"), "--",
           "--model", name if path.endswith(".py") else path, "--out", out,
           "--samples", str(samples), "--category", row["category"]]
    if "yaw" in opts:
        cmd += ["--yaw", opts["yaw"]]
    if "paint" in opts:
        cmd += ["--paint", opts["paint"]]
    log = subprocess.run(cmd, capture_output=True, text=True)
    if log.returncode or "Traceback" in log.stdout + log.stderr:
        return row["id"], "FAILED\n" + (log.stdout + log.stderr)[-1500:]
    subprocess.run([sys.executable, "-I", os.path.join(ART, "tools", "pack_vehicle.py"), out,
                    os.path.join(ART, "grf", "gfx"), row["id"]], check=True)
    with open(stamp, "w") as f:
        f.write(d)
    return row["id"], "rendered"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--jobs", type=int, default=max(1, os.cpu_count() // 2))
    ap.add_argument("--draft", action="store_true", help="16 samples for quick look checks")
    ap.add_argument("--only")
    ap.add_argument("--force", action="store_true")
    a = ap.parse_args()
    with open(os.path.join(ART, "assets.csv"), newline="") as f:
        rows = [r for r in csv.DictReader(f) if r["model"] and r["kind"] == "vehicle"
                and (not a.only or r["category"] == a.only)]
    samples = 16 if a.draft else 128
    threads = max(1, (os.cpu_count() or 2) // a.jobs)
    with ThreadPoolExecutor(a.jobs) as pool:
        for rid, result in pool.map(lambda r: render(r, samples, threads, a.force), rows):
            print(f"{rid}: {result}")


if __name__ == "__main__":
    main()
