#!/usr/bin/env bash
# Creates ~/demo with real folders and files for the recorded demo of the Smart Archive Agent.
# Safe to run again: it only deletes and rebuilds ~/demo.
#   bash demo/setup_demo.sh
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEMO="${DEMO_DIR:-$HOME/demo}"

rm -rf "$DEMO"
mkdir -p "$DEMO"/project/{src,data,logs,docs} "$DEMO"/reports "$DEMO"/photos
cd "$DEMO"

# --- project/: a small student project (the folder the brief's example talks about) ---
cat > project/README.md <<'EOF'
# Library Management System
Mini project for the OS lab. Keeps track of books, members and loans.
Run: python3 src/main.py
EOF

cat > project/src/main.py <<'EOF'
from library import Library

def main():
    lib = Library("data/books.csv")
    print("Books available:", len(lib.available()))
    for book in lib.search("operating systems"):
        print(" -", book["title"], "by", book["author"])

if __name__ == "__main__":
    main()
EOF

cat > project/src/library.py <<'EOF'
import csv

class Library:
    def __init__(self, path):
        with open(path, newline="") as f:
            self.books = list(csv.DictReader(f))

    def available(self):
        return [b for b in self.books if b["status"] == "available"]

    def search(self, text):
        text = text.lower()
        return [b for b in self.books if text in b["title"].lower()]
EOF

python3 - <<'EOF'
import csv, random
random.seed(12)
titles = ["Operating Systems Concepts", "Modern Operating Systems", "Computer Networks", "Database Systems",
          "Linux Kernel Development", "The C Programming Language", "Clean Code", "Algorithms Unlocked"]
authors = ["Silberschatz", "Tanenbaum", "Kurose", "Elmasri", "Love", "Kernighan", "Martin", "Cormen"]
with open("project/data/books.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["id", "title", "author", "year", "status"])
    for i in range(1, 3001):
        k = random.randrange(len(titles))
        w.writerow([i, f"{titles[k]} (copy {i})", authors[k], random.randint(1990, 2025),
                    random.choice(["available", "loaned", "reserved"])])
with open("project/data/members.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["member_id", "name", "branch", "joined"])
    for i in range(1, 801):
        w.writerow([f"M{i:04d}", f"Student {i}", random.choice(["CSE", "ECE", "IT", "MECH"]),
                    f"2025-{random.randint(1, 12):02d}-{random.randint(1, 28):02d}"])
# A server log compresses very well, which makes the size reduction easy to see.
with open("project/logs/server.log", "w") as f:
    for i in range(60000):
        f.write(f"2026-10-{1 + i % 28:02d} 10:{i % 60:02d}:{(i * 7) % 60:02d} INFO request /books/{i % 3000} "
                f"status=200 time={(i * 13) % 90}ms\n")
EOF

cp "$REPO/docs/architecture.png" project/docs/
cp "$REPO/docs/architecture.md" project/docs/

# --- reports/: text and CSV files ---
cat > reports/semester_report.txt <<'EOF'
Semester Report - Operating Systems Lab
Team 12: Smart Archive Agent
Work done: archive, compression, extraction, inspection, encryption and decryption from plain English.
EOF
python3 - <<'EOF'
import csv, random
random.seed(7)
with open("reports/marks.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["reg_no", "review1", "review2", "review3", "total"])
    for i in range(1, 201):
        r = [random.randint(10, 20) for _ in range(3)]
        w.writerow([f"24BCE{i:04d}", *r, sum(r)])
EOF

# --- photos/: images (already compressed, so they shrink very little) ---
cp "$REPO/docs/architecture.png" photos/architecture.png
cp "$REPO/docs/workflow.png" photos/workflow.png

# --- notes.txt: a single large text file for single-file compression ---
python3 - <<'EOF'
with open("notes.txt", "w") as f:
    for i in range(1, 4001):
        f.write(f"Note {i}: tar bundles files, gzip/bzip2/xz compress them, gpg encrypts them.\n")
EOF

# --- evil.tar: a malicious archive (Zip Slip) whose member tries to escape the destination ---
python3 - <<'EOF'
import io, tarfile
with tarfile.open("evil.tar", "w") as t:
    data = b"this file should never be written outside the folder\n"
    info = tarfile.TarInfo("../../escaped.txt")
    info.size = len(data)
    t.addfile(info, io.BytesIO(data))
EOF

echo "Demo folder ready: $DEMO"
find "$DEMO" -maxdepth 3 | sort | sed "s|$HOME|~|"
du -sh "$DEMO"/project "$DEMO"/reports "$DEMO"/photos "$DEMO"/notes.txt
