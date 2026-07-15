import os
import shutil
from pathlib import Path

root = Path(r"c:\Users\Koray\OneDrive\Desktop\VinclyApp").resolve()

exclude_dirs = {
    '.git', '.dart_tool', '.idea', '.vscode', 'build', 'android/.gradle',
    'ios/Pods', 'macos/Pods', 'linux/flutter', 'windows/flutter'
}

text_suffixes = {
    '.dart', '.kt', '.kts', '.swift', '.java', '.h', '.hpp', '.cc', '.cpp', '.c', '.m', '.mm',
    '.gradle', '.xml', '.html', '.css', '.js', '.ts', '.yaml', '.yml', '.md', '.txt', '.plist',
    '.storyboard', '.xib', '.rc', '.cmake', '.properties', '.lock', '.gradle.kts', '.gitattributes', '.gitignore'
}

files = []
for p in root.rglob('*'):
    if not p.is_file():
        continue
    if any(part in exclude_dirs for part in p.parts):
        continue
    if p.name == '.DS_Store':
        continue
    suffix = p.suffix.lower()
    if suffix in text_suffixes or p.name in {'.gitattributes', '.gitignore'}:
        files.append(p)

for path in files:
    try:
        text = path.read_text(encoding='utf-8')
    except Exception:
        continue

    if path.suffix.lower() in {'.json', '.lock'}:
        continue

    out = []
    i = 0
    in_single = False
    in_double = False
    in_block = False
    in_line = False
    escaped = False

    while i < len(text):
        ch = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ''

        if in_line:
            if ch == '\n':
                in_line = False
                out.append('\n')
            i += 1
            continue

        if in_block:
            if ch == '*' and nxt == '/':
                in_block = False
                out.append(' ')
                out.append(' ')
                i += 2
                continue
            if ch == '\n':
                out.append('\n')
            i += 1
            continue

        if in_single:
            out.append(ch)
            if escaped:
                escaped = False
            elif ch == '\\':
                escaped = True
            elif ch == "'":
                in_single = False
            i += 1
            continue

        if in_double:
            out.append(ch)
            if escaped:
                escaped = False
            elif ch == '\\':
                escaped = True
            elif ch == '"':
                in_double = False
            i += 1
            continue

        if ch == '/' and nxt == '/':
            in_line = True
            i += 2
            continue

        if ch == '/' and nxt == '*':
            in_block = True
            i += 2
            continue

        if ch == "'":
            in_single = True
            out.append(ch)
            i += 1
            continue

        if ch == '"':
            in_double = True
            out.append(ch)
            i += 1
            continue

        out.append(ch)
        i += 1

    new_text = ''.join(out)
    if new_text != text:
        path.write_text(new_text, encoding='utf-8')

# Remove diagnostics and generated artifacts
for rel in [
    'build',
    'android/build/reports',
    'ios/Flutter/ephemeral',
    'macos/Flutter/ephemeral',
    'analysis.txt',
    'analyze_errors.txt',
    'analyze_out.txt',
    'analyze_output.txt',
    'analyze.txt',
    'build_errors.txt',
    'devices.txt',
    'LANGUAGE_CHANGE_DIAGNOSTIC.md',
]:
    p = root / rel
    if p.exists():
        if p.is_dir():
            shutil.rmtree(p)
        else:
            p.unlink()

print('Cleanup completed')
