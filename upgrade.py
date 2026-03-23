#!/usr/bin/env python3
"""
upgrade.py - Check and update hardcoded software versions in installation scripts.

Targets:
  - Terraform            -> root/bin/terraform-install.sh
  - Cloud SQL Proxy      -> root/bin/gcloud-sql-proxy-install.sh
  - Debian forky slim    -> aws/Dockerfile

Usage:
  python3 upgrade.py            # check and update
  python3 upgrade.py --dry-run  # check only, no file changes
"""

import json
import re
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path

WORKSPACE = Path(__file__).parent

TERRAFORM_SCRIPT  = WORKSPACE / "root/bin/terraform-install.sh"
CSP_SCRIPT        = WORKSPACE / "root/bin/gcloud-sql-proxy-install.sh"
AWS_DOCKERFILE    = WORKSPACE / "aws/Dockerfile"
GCLOUD_DOCKERFILE = WORKSPACE / "gcloud/Dockerfile"


# ---------------------------------------------------------------------------
# HTTP helpers
# ---------------------------------------------------------------------------

def fetch_json(url, headers=None):
    req = urllib.request.Request(url, headers=headers or {})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        raise RuntimeError(f"HTTP {e.code} fetching {url}") from e
    except urllib.error.URLError as e:
        raise RuntimeError(f"Network error fetching {url}: {e.reason}") from e


# ---------------------------------------------------------------------------
# Version fetchers
# ---------------------------------------------------------------------------

def get_latest_terraform():
    data = fetch_json("https://api.releases.hashicorp.com/v1/releases/terraform/latest")
    return data["version"]


def get_latest_cloud_sql_proxy():
    data = fetch_json(
        "https://api.github.com/repos/GoogleCloudPlatform/cloud-sql-proxy/releases/latest",
        headers={
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
        },
    )
    tag = data["tag_name"]  # e.g. "v2.15.0"
    return tag.lstrip("v")


def get_installed_gcloud():
    """Return the gcloud version from the locally installed SDK."""
    result = subprocess.run(
        ["bash", "-c", "gcloud --version | head -n1 | awk '{ print $4 }'"],
        capture_output=True, text=True, check=True,
    )
    return result.stdout.strip()


def get_latest_debian_forky_slim():
    """Return the latest forky-YYYYMMDD-slim tag from Docker Hub."""
    url = (
        "https://hub.docker.com/v2/repositories/library/debian/tags"
        "?name=forky-&ordering=last_updated&page_size=100"
    )
    data = fetch_json(url)
    pattern = re.compile(r"^forky-(\d{8})-slim$")
    candidates = []
    for result in data.get("results", []):
        m = pattern.match(result["name"])
        if m:
            candidates.append((m.group(1), result["name"]))  # (date_str, full_tag)
    if not candidates:
        raise RuntimeError("No forky-YYYYMMDD-slim tags found on Docker Hub")
    candidates.sort(key=lambda x: x[0], reverse=True)
    return candidates[0][1]  # e.g. "forky-20260223-slim"


# ---------------------------------------------------------------------------
# File helpers
# ---------------------------------------------------------------------------

def read_current(path, pattern):
    """Extract current value using a regex with one capture group."""
    content = path.read_text()
    m = re.search(pattern, content)
    if not m:
        raise RuntimeError(f"Pattern {pattern!r} not found in {path}")
    return m.group(1)


def update_file(path, pattern, replacement, dry_run=False):
    """Replace first regex match in file. Returns True if content would change."""
    content = path.read_text()
    new_content, count = re.subn(pattern, replacement, content, count=1)
    if count == 0:
        raise RuntimeError(f"Pattern {pattern!r} not found in {path}")
    if new_content == content:
        return False
    if not dry_run:
        path.write_text(new_content)
    return True


# ---------------------------------------------------------------------------
# Per-tool check + update logic
# ---------------------------------------------------------------------------

def check(name, current, latest, path, search_pattern, replacement, dry_run):
    if current == latest:
        print(f"  ok        {current}")
        return False
    print(f"  outdated  {current} -> {latest}")
    changed = update_file(path, search_pattern, replacement, dry_run)
    if changed and not dry_run:
        print(f"  updated   {path.relative_to(WORKSPACE)}")
    elif changed and dry_run:
        print(f"  would update {path.relative_to(WORKSPACE)}")
    return changed


def run_terraform(dry_run):
    print("[terraform]")
    current = read_current(TERRAFORM_SCRIPT, r"TF_VERSION='([^']+)'")
    latest  = get_latest_terraform()
    return check(
        "terraform", current, latest,
        TERRAFORM_SCRIPT,
        r"TF_VERSION='[^']+'",
        f"TF_VERSION='{latest}'",
        dry_run,
    )


def run_cloud_sql_proxy(dry_run):
    print("[cloud-sql-proxy]")
    current = read_current(CSP_SCRIPT, r"CSP_VERSION='([^']+)'")
    latest  = get_latest_cloud_sql_proxy()
    return check(
        "cloud-sql-proxy", current, latest,
        CSP_SCRIPT,
        r"CSP_VERSION='[^']+'",
        f"CSP_VERSION='{latest}'",
        dry_run,
    )


def run_gcloud(dry_run):
    print("[gcloud]")
    current = read_current(GCLOUD_DOCKERFILE, r"google-cloud-cli:([^-]+)-stable")
    latest  = get_installed_gcloud()
    return check(
        "gcloud", current, latest,
        GCLOUD_DOCKERFILE,
        r"google-cloud-cli:[^-]+-stable",
        f"google-cloud-cli:{latest}-stable",
        dry_run,
    )


def run_debian_forky(dry_run):
    print("[debian forky slim]")
    current = read_current(AWS_DOCKERFILE, r"FROM debian:(\S+)")
    latest  = get_latest_debian_forky_slim()
    return check(
        "debian", current, latest,
        AWS_DOCKERFILE,
        r"FROM debian:\S+",
        f"FROM debian:{latest}",
        dry_run,
    )


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

CHECKS = [
    run_terraform,
    run_cloud_sql_proxy,
    run_debian_forky,
    run_gcloud,
]


def main():
    dry_run = "--dry-run" in sys.argv
    if dry_run:
        print("=== DRY-run mode: no files will be modified ===\n")

    any_updated = False
    any_error   = False

    for fn in CHECKS:
        try:
            updated = fn(dry_run)
            any_updated = any_updated or updated
        except Exception as e:
            print(f"  ERROR: {e}")
            any_error = True
        print()

    if any_error:
        print("Finished with errors.")
        sys.exit(1)
    elif any_updated and dry_run:
        print("Updates available (dry-run, no files changed).")
    elif any_updated:
        print("All updates applied.")
    else:
        print("Everything is up to date.")


if __name__ == "__main__":
    main()
