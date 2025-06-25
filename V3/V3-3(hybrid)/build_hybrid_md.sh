#!/bin/bash
# Concatenate all .md files into a single 'Hybrid.md' with a generated TOC

OUTPUT="Hybrid.md"
TMP_TOC="toc.tmp"
TMP_BODY="body.tmp"
> "$TMP_TOC"
> "$TMP_BODY"

echo "# Hybrid Resource" > "$OUTPUT"
echo "" >> "$OUTPUT"
echo "## Table of Contents" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Get all .md files in sort order (edit this pattern if you want to specify order)
FILES=$(ls *.md | sort)

# Build TOC and Body
for FILE in $FILES; do
  # Find the first H1 or H2 heading as the section title
  TITLE=$(grep -m1 -E '^#+' "$FILE" | sed -E 's/^#+ //')
  # Skip if no title found
  [ -z "$TITLE" ] && continue
  # Make anchor (GitHub style)
  ANCHOR=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9 ]//g' | sed -E 's/ /-/g')
  echo "- [$TITLE](#$ANCHOR)" >> "$TMP_TOC"
  # Add a section break and heading to body
  echo "" >> "$TMP_BODY"
  echo "## $TITLE" >> "$TMP_BODY"
  # Add the file content, but remove its first heading and any "----" transitions
  tail -n +2 "$FILE" | sed '/^---*$/d' >> "$TMP_BODY"
  echo "" >> "$TMP_BODY"
done

# Combine TOC and body
cat "$TMP_TOC" >> "$OUTPUT"
echo "" >> "$OUTPUT"
cat "$TMP_BODY" >> "$OUTPUT"

# Clean up temp files
rm "$TMP_TOC" "$TMP_BODY"

echo "Done! See $OUTPUT"