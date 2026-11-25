#!/bin/sh
# Builds index.html (the page the website serves) from src/app.html.
cd "$(dirname "$0")"
{ printf '<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n<meta name="app-build" content="%s">\n</head>\n<body>\n' "$(date -u +%Y%m%d%H%M%S)"; cat src/app.html; printf '\n</body>\n</html>\n'; } > index.html
