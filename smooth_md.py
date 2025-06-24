import os
import re

# Paths
SRC = "V3/V3-1(accurate)/resource2FULL.md"
DST = "V3/V3-1(accurate)/V3/V3-1(accurate)/resource2FULL-smoothed.md"

os.makedirs(os.path.dirname(DST), exist_ok=True)

with open(SRC, "r", encoding="utf-8") as f:
    lines = f.readlines()

output = []
skip_next = False

for i, line in enumerate(lines):
    # Remove mechanical part/jump lines
    if re.match(r"^_?Proceed to Chapter \d+|End of Chapter \d+|Continue in Part \d+", line.strip(), re.IGNORECASE):
        continue
    # Remove lines like "Part N", "====", etc. if not wanted
    if re.match(r"^#+\s*Part\s+\d+", line.strip(), re.IGNORECASE):
        continue
    # Remove repeated headings (e.g., two "# Chapter X" in a row)
    if output and output[-1].strip() == line.strip() and line.startswith("#"):
        continue
    # Remove lines that just say "---" if there are two in a row
    if line.strip() == "---" and output and output[-1].strip() == "---":
        continue
    output.append(line)

with open(DST, "w", encoding="utf-8") as f:
    f.writelines(output)

print(f"Smoothed Markdown written to {DST}")
