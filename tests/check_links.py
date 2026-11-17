#!/usr/bin/env python3
"""
check_links.py — Internal Markdown link validator for VELOOP D05/D06 artifacts.

Reads D05, SE1, SE2, D06, and SF1. Extracts all [text](target) markdown links
where the target is a relative path or a #anchor. Verifies:
  - Relative path links point to files that exist on disk.
  - Anchor links (#heading) resolve to a heading that exists in the same file.
  - Cross-file anchors (file.md#heading) resolve to a heading in the target file.

Does NOT validate external http/https URLs.

Exit 0 if all checked links pass, exit 1 on any failure.
"""

import sys
import re
import os
from pathlib import Path
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parent.parent

FILES = {
    'D05': ROOT / 'submission/05_earning_reward_analytics/earning_reward_analytics_specification.md',
    'SE1': ROOT / 'submission/05_earning_reward_analytics/se1_failed_activity_classification.md',
    'SE2': ROOT / 'submission/05_earning_reward_analytics/se2_reward_event_requirements.md',
    'D06': ROOT / 'submission/06_wallet_withdrawal_analytics/wallet_withdrawal_analytics_specification.md',
    'SF1': ROOT / 'submission/06_wallet_withdrawal_analytics/sf1_withdrawal_lifecycle.md',
}

# Regex: match [text](target) but not ![img](url)
LINK_RE = re.compile(r'(?<!!)\[([^\]]*)\]\(([^)]+)\)')


def heading_to_anchor(heading_text: str) -> str:
    """Convert a Markdown heading to a GitHub-style anchor slug."""
    # Lowercase, strip non-alphanumeric except hyphens and spaces, replace spaces with hyphens
    text = heading_text.strip().lower()
    text = re.sub(r'[^\w\s-]', '', text)      # remove punctuation except hyphen
    text = re.sub(r'\s+', '-', text)           # spaces → hyphens
    text = re.sub(r'-+', '-', text)            # collapse multiple hyphens
    return text.strip('-')


def extract_anchors(content: str) -> set:
    """Return the set of anchor slugs for all headings in a Markdown file."""
    anchors = set()
    for line in content.splitlines():
        m = re.match(r'^(#{1,6})\s+(.*)', line)
        if m:
            anchors.add(heading_to_anchor(m.group(2)))
    return anchors


def main():
    failures = []
    file_contents = {}
    file_anchors = {}

    # Load all files
    for label, path in FILES.items():
        if not path.exists():
            failures.append(f"[{label}] File not found: {path}")
            continue
        content = path.read_text(encoding='utf-8')
        file_contents[path] = content
        file_anchors[path] = extract_anchors(content)

    if failures:
        for f in failures:
            print(f"FAIL: {f}")
        sys.exit(1)

    # Check links in each file
    for label, src_path in FILES.items():
        if src_path not in file_contents:
            continue
        content = file_contents[src_path]
        src_dir = src_path.parent

        for m in LINK_RE.finditer(content):
            link_text, raw_target = m.group(1), m.group(2)
            target = unquote(raw_target.strip())

            # Skip external URLs
            if target.startswith('http://') or target.startswith('https://'):
                continue
            # Skip mailto
            if target.startswith('mailto:'):
                continue
            # Skip file:// protocol links
            if target.startswith('file://'):
                continue

            if '#' in target:
                file_part, anchor_part = target.split('#', 1)
            else:
                file_part, anchor_part = target, None

            # Resolve target file
            if file_part:
                target_path = (src_dir / file_part).resolve()
                if not target_path.exists():
                    failures.append(
                        f"[{label}] Broken file link: [{link_text}]({raw_target}) → {target_path} not found"
                    )
                    continue
                # Check anchor in target file
                if anchor_part and target_path in file_anchors:
                    slug = heading_to_anchor(anchor_part)
                    if slug not in file_anchors[target_path]:
                        failures.append(
                            f"[{label}] Broken anchor: [{link_text}]({raw_target}) "
                            f"→ #{slug} not found in {target_path.name}"
                        )
            else:
                # Pure same-file anchor: #section
                if anchor_part:
                    slug = heading_to_anchor(anchor_part)
                    if slug not in file_anchors.get(src_path, set()):
                        failures.append(
                            f"[{label}] Broken same-file anchor: [{link_text}](#{anchor_part}) "
                            f"→ #{slug} not found in {src_path.name}"
                        )

    if failures:
        print(f"Internal Markdown link check: {len(failures)} broken link(s) found.")
        for f in failures:
            print(f"  BROKEN: {f}")
        sys.exit(1)
    else:
        print(f"Internal Markdown link check: all relative links in D05/SE1/SE2/D06/SF1 resolve correctly.")
        sys.exit(0)


if __name__ == '__main__':
    main()
