#!/usr/bin/env python3
"""Build release assets without modifying sources. Requires Python 3 and msgfmt."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
DOMAIN = "plasma_applet_org.kde.simpleMonitor"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tag", help="Must match the package version, e.g. v0.7.0")
    parser.add_argument("--output", type=Path, default=ROOT / "dist")
    args = parser.parse_args()
    version = json.loads((ROOT / "plasmoid/metadata.json").read_text())["KPlugin"]["Version"]
    tag = "v" + version
    if args.tag is not None and args.tag != tag:
        parser.error(f"tag {args.tag!r} does not match metadata version {tag!r}")
    if not shutil.which("msgfmt"):
        parser.error("GNU gettext msgfmt is required")
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    catalogs = sorted((ROOT / "translations").glob(f"*/LC_MESSAGES/{DOMAIN}.po"))
    if not catalogs:
        parser.error("no translation catalogs found")
    with tempfile.TemporaryDirectory(prefix="simplemonitor-release-") as directory:
        package = Path(directory) / "package"
        shutil.copytree(ROOT / "plasmoid", package)
        locale = package / "contents/locale"
        for po in catalogs:
            target = locale / po.relative_to(ROOT / "translations").with_suffix(".mo")
            target.parent.mkdir(parents=True, exist_ok=True)
            subprocess.run(["msgfmt", "--check", "-o", str(target), str(po)], check=True)
        for name in ("COPYING", "AUTHORS.md", "LOGO-SOURCES.md"):
            shutil.copy2(ROOT / name, package / name)
        archive = output / f"plasma-simpleMonitor-{tag}.plasmoid"
        with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as bundle:
            for path in sorted(package.rglob("*")):
                if path.is_file():
                    bundle.write(path, path.relative_to(package))
        translations = output / f"plasma-simpleMonitor-{tag}-translations.tar.gz"
        with tarfile.open(translations, "w:gz") as bundle:
            bundle.add(locale, arcname="locale")
    assets = [archive, translations]
    (output / "SHA256SUMS").write_text("".join(
        f"{hashlib.sha256(path.read_bytes()).hexdigest()}  {path.name}\n" for path in assets
    ))
    print(f"Built {tag}: {len(catalogs)} catalogs; assets in {output}")


if __name__ == "__main__":
    main()
