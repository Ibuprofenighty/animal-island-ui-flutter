"""Give the generated Gallery entry scripts content identities for static hosting.

GitHub Pages can retain a prior Flutter service worker and unversioned scripts.
Publish one content-named bootstrap and app script, with no duplicate runtime.
Run after `flutter build web`, before uploading the generated directory.
"""
from pathlib import Path
import hashlib
import json


def prepare(directory):
    root = Path(directory)
    app = root / "main.dart.js"
    bootstrap = root / "flutter_bootstrap.js"
    index = root / "index.html"
    app_name = "main." + hashlib.sha256(app.read_bytes()).hexdigest()[:16] + ".dart.js"
    loader = bootstrap.read_text(encoding="utf-8")
    old_path = '"mainJsPath":"main.dart.js"'
    if loader.count(old_path) != 1:
        raise ValueError("Expected one generated dart2js entrypoint")
    loader = loader.replace(old_path, '"mainJsPath":' + json.dumps(app_name))
    loader_bytes = loader.encode("utf-8")
    bootstrap_name = "flutter_bootstrap." + hashlib.sha256(loader_bytes).hexdigest()[:16] + ".js"
    html = index.read_text(encoding="utf-8")
    if html.count('src="flutter_bootstrap.js"') != 1:
        raise ValueError("Expected one bootstrap script in Gallery index")
    html = html.replace('src="flutter_bootstrap.js"', 'src="' + bootstrap_name + '"')
    if (root / app_name).exists() or (root / bootstrap_name).exists():
        raise FileExistsError("Use a fresh Flutter build output")
    app.rename(root / app_name)
    bootstrap.write_bytes(loader_bytes)
    bootstrap.rename(root / bootstrap_name)
    index.write_text(html, encoding="utf-8", newline="\n")
    return {"app": app_name, "bootstrap": bootstrap_name}


if __name__ == "__main__":
    print(json.dumps(prepare(Path(__file__).resolve().parents[1] / "example/build/web")))
