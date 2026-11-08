"""Live /simulate contract test (F11; stdlib only).

Boots the real server on an ephemeral port, POSTs a small sim, asserts the
JSON contract (keys, nested n x n grid, value ranges), then kills the server.
Usage:  py -3 scripts/web_contract_live.py
Exit 0 = contract holds against the RUNNING server (promotes static G6).
"""
import json
import subprocess
import sys
import time
import urllib.request

PORT = 18091
ROOT = __file__.rsplit("scripts", 1)[0] or "."


def main():
    srv = subprocess.Popen(
        ["julia", "--project=.", "src/web_server.jl", str(PORT)],
        cwd=ROOT, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    try:
        ok = False
        for _ in range(60):
            time.sleep(5)
            try:
                with urllib.request.urlopen(f"http://127.0.0.1:{PORT}/",
                                            timeout=5) as r:
                    if r.status == 200:
                        ok = True
                        break
            except Exception:
                pass
        if not ok:
            print("FAIL boot: server never listened")
            return 1
        payload = {"grid_size": 15, "F": 5, "Q": 3, "steps": 50,
                   "epsilon": 0.3, "mutation": 0.0}
        req = urllib.request.Request(
            f"http://127.0.0.1:{PORT}/simulate",
            data=json.dumps(payload).encode(),
            headers={"Content-Type": "application/json"})
        with urllib.request.urlopen(req, timeout=120) as r:
            data = json.load(r)
        problems = []
        for k in ("agents", "compliance", "partial", "regions",
                  "largest_region", "largest_share", "grid"):
            if k not in data:
                problems.append(f"missing key {k}")
        g = data.get("grid", [])
        if not (isinstance(g, list) and len(g) == 15
                and all(isinstance(row, list) and len(row) == 15
                        for row in g)):
            problems.append("grid not nested 15x15")
        else:
            flat = [v for row in g for v in row]
            if min(flat) < 1 or max(flat) > 3:
                problems.append("grid values outside 1..Q")
        if not (data.get("agents") == 225 and data.get("regions", 0) >= 1):
            problems.append("agents/regions implausible")
        if not (0.0 <= data.get("partial", -1) <= 1.0):
            problems.append("partial outside [0,1]")
        if problems:
            print("FAIL contract:", "; ".join(problems))
            return 1
        print(f"PASS live contract (regions={data['regions']} "
              f"partial={data['partial']:.3f})")
        return 0
    finally:
        srv.terminate()


if __name__ == "__main__":
    sys.exit(main())
