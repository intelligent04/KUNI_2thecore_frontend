#!/bin/bash

# GitHub Wiki Upload Script
# Usage: ./wiki/upload-wiki.sh

set -e

REPO_URL="https://github.com/Kernel360/KUNI_2thecore_frontend.wiki.git"
WIKI_DIR="wiki"
TEMP_DIR="wiki-repo-temp"

echo "=== GitHub Wiki Upload Script ==="
echo ""

# Check if wiki directory exists
if [ ! -d "$WIKI_DIR" ]; then
    echo "Error: wiki directory not found"
    exit 1
fi

# Remove temp directory if exists
rm -rf "$TEMP_DIR"

# Clone wiki repository
echo "1. Cloning Wiki repository..."
if git clone "$REPO_URL" "$TEMP_DIR" 2>/dev/null; then
    echo "   Wiki repository cloned successfully"
else
    echo "Error: Failed to clone Wiki repository"
    echo ""
    echo "Please ensure that:"
    echo "1. GitHub Wiki is enabled for this repository"
    echo "2. You have created at least one Wiki page manually"
    echo "3. You have push permissions"
    echo ""
    echo "To enable Wiki:"
    echo "1. Go to https://github.com/Kernel360/KUNI_2thecore_frontend/settings"
    echo "2. Under 'Features', check 'Wikis'"
    echo "3. Go to Wiki tab and create a first page"
    exit 1
fi

# Copy markdown files
echo "2. Copying documentation files..."
cp "$WIKI_DIR"/*.md "$TEMP_DIR/"
echo "   Copied $(ls -1 $WIKI_DIR/*.md | wc -l) files"

# Commit and push
echo "3. Committing changes..."
cd "$TEMP_DIR"
git add .

if git diff --cached --quiet; then
    echo "   No changes to commit"
else
    git commit -m "docs: Update project documentation

Generated with Claude Code Wiki

Files updated:
- Home.md (main page)
- Architecture.md
- Data-Flow.md
- Diagrams.md
- API-Reference.md
- Module-*.md (8 modules)
- Getting-Started.md
- Deployment.md
- _Sidebar.md"

    echo "4. Pushing to GitHub..."
    git push origin master
    echo "   Push successful!"
fi

# Cleanup
cd ..
rm -rf "$TEMP_DIR"

echo ""
echo "=== Upload Complete ==="
echo ""
echo "View your Wiki at:"
echo "https://github.com/Kernel360/KUNI_2thecore_frontend/wiki"
