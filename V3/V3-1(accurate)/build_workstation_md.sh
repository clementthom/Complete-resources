#!/bin/bash
# Concatenate all .md files from part1Workstation and part2 into 'Workstation.md' with TOC

OUTPUT="Workstation.md"
TMP_TOC="toc.tmp"
TMP_BODY="body.tmp"
> "$TMP_TOC"
> "$TMP_BODY"

# Find all .md files in both directories, sorted
FILES=$(find resourceWorkstationPart1/part1Workstation resourceWorkstationPart2 -type f -name "*.md" | sort)

echo "# Workstation Resource" > "$OUTPUT"
echo "" >> "$OUTPUT"
echo "## Table of Contents" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Build TOC and Body
for FILE in $FILES; do
  # Find first H1 or H2 heading
  TITLE=$(grep -m1 -E '^#+' "$FILE" | sed -E 's/^#+ //')
  [ -z "$TITLE" ] && continue
  ANCHOR=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9 ]//g' | sed -E 's/ /-/g')
  echo "- [$TITLE](#$ANCHOR)" >> "$TMP_TOC"
  echo "" >> "$TMP_BODY"
  echo "## $TITLE" >> "$TMP_BODY"
  # Add content, skipping first heading and any transition lines
  tail -n +2 "$FILE" | sed '/^---*$/d' >> "$TMP_BODY"
  echo "" >> "$TMP_BODY"
done

cat "$TMP_TOC" >> "$OUTPUT"
echo "" >> "$OUTPUT"
cat "$TMP_BODY" >> "$OUTPUT"

rm "$TMP_TOC" "$TMP_BODY"

echo "Done! See $OUTPUT"