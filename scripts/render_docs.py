"""
render_docs.py — Balleck Team / Plinko
Convertit tous les fichiers .md du projet en .html lisibles dans un navigateur.
Usage : python scripts/render_docs.py
"""

import os
import markdown
from pathlib import Path

ROOT = Path(__file__).parent.parent

STYLE = """
<style>
  :root {
    --bg: #0f0f1a;
    --surface: #1a1a2e;
    --border: #2e2e4e;
    --accent: #7c5cbf;
    --accent2: #00c8ff;
    --text: #e0e0f0;
    --muted: #8888aa;
    --green: #4caf82;
    --red: #e05c5c;
    --yellow: #f0c040;
  }

  * { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    background: var(--bg);
    color: var(--text);
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    font-size: 15px;
    line-height: 1.7;
    padding: 40px 20px;
  }

  .container {
    max-width: 860px;
    margin: 0 auto;
  }

  .header {
    border-bottom: 1px solid var(--border);
    padding-bottom: 20px;
    margin-bottom: 36px;
  }

  .breadcrumb {
    font-size: 12px;
    color: var(--muted);
    margin-bottom: 8px;
    letter-spacing: 0.05em;
    text-transform: uppercase;
  }

  h1 { font-size: 28px; font-weight: 700; color: #fff; margin-bottom: 6px; }
  h2 { font-size: 20px; font-weight: 600; color: var(--accent2); margin: 36px 0 12px; padding-bottom: 6px; border-bottom: 1px solid var(--border); }
  h3 { font-size: 16px; font-weight: 600; color: #ccc; margin: 24px 0 8px; }
  h4 { font-size: 14px; font-weight: 600; color: var(--muted); margin: 16px 0 6px; text-transform: uppercase; letter-spacing: 0.05em; }

  p { margin: 10px 0; color: var(--text); }

  a { color: var(--accent2); text-decoration: none; }
  a:hover { text-decoration: underline; }

  strong { color: #fff; font-weight: 600; }
  em { color: var(--accent2); font-style: normal; }

  code {
    background: var(--surface);
    border: 1px solid var(--border);
    padding: 2px 6px;
    border-radius: 4px;
    font-family: 'SF Mono', 'Fira Code', monospace;
    font-size: 13px;
    color: #a0d0ff;
  }

  pre {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 20px;
    overflow-x: auto;
    margin: 16px 0;
  }

  pre code {
    background: none;
    border: none;
    padding: 0;
    font-size: 13px;
    color: #c0e0ff;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    margin: 16px 0;
    font-size: 14px;
  }

  th {
    background: var(--surface);
    color: var(--accent2);
    font-weight: 600;
    text-align: left;
    padding: 10px 14px;
    border: 1px solid var(--border);
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  td {
    padding: 9px 14px;
    border: 1px solid var(--border);
    color: var(--text);
    vertical-align: top;
  }

  tr:nth-child(even) td { background: rgba(255,255,255,0.02); }

  ul, ol {
    padding-left: 24px;
    margin: 10px 0;
  }

  li { margin: 4px 0; }

  blockquote {
    border-left: 3px solid var(--accent);
    padding: 10px 16px;
    margin: 16px 0;
    background: var(--surface);
    border-radius: 0 6px 6px 0;
    color: var(--muted);
    font-style: italic;
  }

  hr {
    border: none;
    border-top: 1px solid var(--border);
    margin: 36px 0;
  }

  .footer {
    margin-top: 48px;
    padding-top: 16px;
    border-top: 1px solid var(--border);
    font-size: 12px;
    color: var(--muted);
    display: flex;
    justify-content: space-between;
  }

  .tag {
    display: inline-block;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 4px;
    padding: 2px 8px;
    font-size: 11px;
    color: var(--muted);
    margin-right: 4px;
  }
</style>
"""

TEMPLATE = """<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{title} — Balleck Team</title>
  {style}
</head>
<body>
  <div class="container">
    <div class="header">
      <div class="breadcrumb">Balleck Team · Plinko · {filepath}</div>
      <h1>{title}</h1>
    </div>
    <div class="content">
      {content}
    </div>
    <div class="footer">
      <span>Balleck Team — Plinko Project</span>
      <span>{filepath}</span>
    </div>
  </div>
</body>
</html>"""

SKIP_FILES = {'scripts', '.git', 'node_modules', 'flutter', 'plinko_app'}

def convert_file(md_path: Path):
    rel = md_path.relative_to(ROOT)

    # Skip flutter source files
    parts = rel.parts
    if any(p in SKIP_FILES for p in parts):
        return

    with open(md_path, 'r', encoding='utf-8') as f:
        text = f.read()

    # Extract title from first h1
    title = md_path.stem.replace('-', ' ').replace('_', ' ').title()
    for line in text.splitlines():
        if line.startswith('# '):
            title = line[2:].strip()
            break

    html_content = markdown.markdown(
        text,
        extensions=['tables', 'fenced_code', 'nl2br']
    )

    html = TEMPLATE.format(
        title=title,
        filepath=str(rel),
        style=STYLE,
        content=html_content
    )

    html_path = md_path.with_suffix('.html')
    with open(html_path, 'w', encoding='utf-8') as f:
        f.write(html)

    print(f"  ✅ {rel} → {html_path.name}")

def main():
    print(f"\n📄 Balleck Team — Rendu des docs\n{'─'*40}")
    count = 0
    for md_path in sorted(ROOT.rglob('*.md')):
        rel_parts = md_path.relative_to(ROOT).parts
        if any(p in SKIP_FILES for p in rel_parts):
            continue
        convert_file(md_path)
        count += 1
    print(f"\n✨ {count} fichiers convertis.\n")

if __name__ == '__main__':
    main()
