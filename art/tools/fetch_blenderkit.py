"""Search or download BlenderKit models into art/models/<id>/ (git-ignored).

usage:
  BLENDERKIT_API_KEY=... python3 -I art/tools/fetch_blenderkit.py search "pickup truck" [--free]
  BLENDERKIT_API_KEY=... python3 -I art/tools/fetch_blenderkit.py get <assetBaseId-prefix> <id> "<search words>"

Royalty-free BlenderKit models may ship inside the game as renders but must not be
redistributed as source files, so the .blend never enters git. Each download is
recorded in art/models/LICENSES.csv.
"""
import csv
import json
import os
import sys
import urllib.parse
import urllib.request
import uuid

API = "https://www.blenderkit.com/api/v1"
ART = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def call(url):
    req = urllib.request.Request(url, headers={"Authorization": "Bearer " + os.environ["BLENDERKIT_API_KEY"]})
    with urllib.request.urlopen(req) as r:
        return json.load(r)


def search(words, free=False):
    q = urllib.parse.quote_plus(words) + "+asset_type:model+order:-score" + ("+is_free:true" if free else "")
    return call(f"{API}/search/?query={q}&page_size=20")["results"]


def main():
    cmd = sys.argv[1]
    if cmd == "search":
        for a in search(sys.argv[2], "--free" in sys.argv):
            faces = next((p["value"] for p in a.get("parameters", []) if p.get("parameterType") == "faceCount"), "?")
            print(a["assetBaseId"][:8], a["license"], "free" if a.get("isFree") else "paid", faces, a["name"])
        return
    prefix, rid, words = sys.argv[2:5]
    a = next(x for x in search(words) if x["assetBaseId"].startswith(prefix))
    blend = next(f["downloadUrl"] for f in a["files"] if f["fileType"] == "blend")
    signed = call(f"{blend}?scene_uuid={uuid.uuid4()}")["filePath"]
    out = os.path.join(ART, "models", rid)
    os.makedirs(out, exist_ok=True)
    urllib.request.urlretrieve(signed, os.path.join(out, "model.blend"))
    with open(os.path.join(ART, "models", "LICENSES.csv"), "a", newline="") as f:
        csv.writer(f).writerow([f"models/{rid}/model.blend", f"https://www.blenderkit.com/asset-gallery-detail/{a['id']}/",
                                a["author"]["fullName"], a["license"]])
    print("saved", out)


if __name__ == "__main__":
    main()
