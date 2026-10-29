# Demo Video Script — Smart Archive Agent (Team 12)

Every command below runs on real folders and files that `setup_demo.sh` creates in `~/demo`.
Run everything in the **Ubuntu terminal** (on our laptop: Start menu → `Ubuntu`). Length: about 8–10 minutes.

## 0. Before you press Record (not recorded)

```bash
cd ~/SMART-ARCHIVE-AGENT
git pull
bash demo/setup_demo.sh
clear
```

* Maximise the terminal and press **Ctrl + `+`** two or three times so the text is readable.
* Passphrase for the video: **`demo123`** (type it the same way every time; it stays hidden).
* Start recording: **Win + Shift + R** (Snipping Tool) → select the Ubuntu window → **Start**.

---

## 1. Introduction and health check

```bash
cd ~/SMART-ARCHIVE-AGENT
git log --oneline | head -5
python3 -m smart_archive_agent --version
python3 -m smart_archive_agent --doctor
```
*Say:* "This is our Smart Archive Agent, agent 12 of the Agentic Shell. `--doctor` checks that tar, gzip, bzip2, xz, zip and gpg are installed."

## 2. Show the real files we will work on

```bash
cd ~/demo
export PYTHONPATH=~/SMART-ARCHIVE-AGENT
find . | sort
du -sh project reports photos notes.txt
head -3 project/data/books.csv
```
*Say:* "`project` is a small library-management project, `reports` has text and CSV files, `photos` has images, `notes.txt` is a large text file, and `evil.tar` is a malicious archive for the security test."

## 3. The agent in plain English

```bash
python3 -m smart_archive_agent
```

Type each line at the `You:` prompt. Wait for the result before typing the next one.

| # | Type this at `You:` | Then | What it proves |
|---|---|---|---|
| 1 | `Zip up my project folder, compress it heavily, and encrypt it.` | `y`, then `demo123` twice | The brief's example: 3-step plan, tar + xz -9e (4.2 MB → about 200 KB), GPG AES-256, temporary file removed |
| 2 | `archive ./reports quickly` | `y` | "quickly" → gzip fast level |
| 3 | `inspect archive ./reports.tar.gz` | — | Inspecting an archive without extracting it |
| 4 | `back up ./reports with normal compression` | `y` | Synonym "back up" → tar.xz, normal level |
| 5 | `zip ./photos into ./photos.zip` | `y` | ZIP format; images barely shrink (already compressed) |
| 6 | `list what is inside ./photos.zip` | — | Listing archive contents |
| 7 | `unzip ./photos.zip into ./photos_restored` | `y` | Extraction to a chosen folder |
| 8 | `compress ./notes.txt with bzip2` | `y` | Single-file compression (about 310 KB → 5 KB) |
| 9 | `decompress ./notes.txt.bz2 to ./notes_restored.txt` | `y` | Single-file decompression |
| 10 | `decrypt ./project.tar.xz.gpg and extract it` | `y`, then a **wrong** passphrase, e.g. `abc` | Wrong passphrase is rejected and nothing is written |
| 11 | `decrypt ./project.tar.xz.gpg and extract it` | `y`, then `demo123` | Decrypt + extract + clean-up from one sentence |
| 12 | `extract ./evil.tar into ./safe` | `y` | **Zip Slip attack blocked** before anything is created |
| 13 | `archive ./does_not_exist` | `y` if asked | Clear error for a missing path |
| 14 | `rm -rf /` | — | Dangerous command blocked by the guardrail |
| 15 | `archive ./reports; rm -rf ~` | — | Command injection blocked |
| 16 | `delete ./reports` | — | Out of scope: deleting belongs to another agent |
| 17 | `What is the weather today?` | — | Out of scope |
| 18 | `exit` | — | Quits |

## 4. Prove the results are real

```bash
ls -lh ~/demo
file project.tar.xz.gpg reports.tar.gz reports.tar.xz photos.zip notes.txt.bz2
diff -r project project-extracted/project && echo "Decrypted project is IDENTICAL to the original"
cmp notes.txt notes_restored.txt && echo "notes.txt restored exactly"
ls photos_restored/photos
ls safe 2>/dev/null || echo "Zip Slip: folder 'safe' was never created"
ls ~/escaped.txt 2>/dev/null || echo "Zip Slip: no file escaped"
```
*Say:* "The encrypted archive decrypts to an exact copy of the original project, and the malicious archive wrote nothing."

## 5. One-shot mode (how another program calls the agent)

```bash
python3 -m smart_archive_agent --yes "compress ./reports/marks.csv heavily"
ls -lh reports
```

## 6. Integration with the Agentic Shell

```bash
cd ~/SMART-ARCHIVE-AGENT
python3 -m smart_archive_agent --manifest | head -30
python3 examples/agentic_shell_example.py
```
*Say:* "The teacher's shell reads our manifest and tool schemas, and calls `execute_tool`. No LLM is needed for this example."

## 7. Automated tests and benchmark

```bash
python3 -m pytest -v
python3 benchmarks/evaluate.py
```
*Say:* "58 tests pass. The benchmark shows 80% intent accuracy on held-out sentences and 18 out of 18 error cases handled correctly."

**Stop recording:** Snipping Tool → Stop. The video is saved in `Videos\Screen Recordings`.

---

## If you need to record again

```bash
cd ~/SMART-ARCHIVE-AGENT && bash demo/setup_demo.sh && clear
```
This rebuilds `~/demo` exactly as at the start, so every command gives the same result again.

## If something goes wrong

| Problem | Fix |
|---|---|
| `No module named smart_archive_agent` | New terminal: run `export PYTHONPATH=~/SMART-ARCHIVE-AGENT` again |
| Files named `project-1.tar.xz.gpg` or `Output already exists` | Old outputs are still there: run the setup line above |
| Decrypt says wrong passphrase in step 11 | Type `demo123` exactly as in step 1 |
