"""Run real validation and retain raw outputs in a new evidence round.
Python 3.10+ standard library only. Never publishes or declares manual acceptance.
"""
from pathlib import Path
from datetime import datetime, timezone
import argparse, hashlib, json, os, re, shutil, subprocess, sys, time, zipfile

ROOT=Path(__file__).resolve().parents[1]

def dump(path,value):
    path.write_text(json.dumps(value,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")

def source_structure(registry):
    """Check declared source coverage and graph reachability, not semantic acceptance."""
    violations=[]
    scope=set()
    for relative in registry["source_scope"]:
        path=ROOT/relative
        if not path.exists():
            violations.append("Missing source-scope member "+relative)
        for file in path.rglob("*") if path.is_dir() else [path]:
            if file.is_file():scope.add(file.resolve())
    maintained=[p for p in ROOT.iterdir() if p.is_file()]
    maintained += [ROOT/"example/README.md", ROOT/"example/.metadata",
                   ROOT/"example/.gitignore", ROOT/"example/windows/.gitignore"]
    for file in maintained:
        if file.resolve() not in scope:violations.append("Unbound maintained file "+str(file.relative_to(ROOT)))
    component_owners=set()
    exports=(ROOT/"lib/animal_island_ui.dart").read_text(encoding="utf-8")
    for relative in registry["components"]:
        contract=ROOT/relative
        inputs=json.loads(contract.read_text(encoding="utf-8"))["interface"]["inputs"]
        references=re.findall(r"\[([A-Za-z_]\w*)\]\(([^)]+)\)",inputs)
        if not references:violations.append("Missing signature-owner reference "+relative)
        for symbol,link in references:
            owner=(contract.parent/link).resolve()
            if not owner.is_relative_to(ROOT) or owner not in scope or not owner.is_file():
                violations.append("Invalid signature owner "+relative+": "+link)
                continue
            declaration=owner.read_text(encoding="utf-8")
            if not re.search(r"\b"+re.escape(symbol)+r"\b",declaration) or not re.search(r"\b"+re.escape(symbol)+r"\b",exports):
                violations.append("Unresolved public signature "+relative+": "+symbol)
            component_owners.add(owner)
    for uri in re.findall(r"export '([^']+)'",exports):
        if uri.startswith("src/components/") and (ROOT/"lib"/uri).resolve() not in component_owners:
            violations.append("Component export without contract owner "+uri)
    units={p.resolve() for base in ("lib","example/lib") for p in (ROOT/base).rglob("*.dart")}
    graph={}
    for file in units:
        edges=[]
        for directive in re.findall(r"(?m)^(?:import|export|part)\b[\s\S]*?;",file.read_text(encoding="utf-8")):
            for uri in re.findall(r"['\"]([^'\"]+)['\"]",directive):
                if uri.startswith("package:animal_island_ui/"):
                    target=ROOT/"lib"/uri.split("/",1)[1]
                elif ":" in uri:continue
                else:target=file.parent/uri
                target=target.resolve()
                if target not in units:violations.append("Unresolved local import "+str(file.relative_to(ROOT))+": "+uri)
                edges.append(target)
        graph[file]=edges
    reached=set()
    pending=[(ROOT/p).resolve() for p in ("lib/animal_island_ui.dart","lib/animal_island_upload_platform.dart","example/lib/main.dart")]
    while pending:
        file=pending.pop()
        if file in reached:continue
        reached.add(file)
        pending.extend(graph.get(file,[]))
    for file in sorted(units-reached):violations.append("Unreachable source unit "+str(file.relative_to(ROOT)))
    return violations


def gallery_version_source(*, generate=False):
    """Project one package-version owner into the Gallery; never hand-maintain it."""
    def declared(path):
        match=re.search(r"(?m)^version: ([0-9]+\.[0-9]+\.[0-9]+(?:[-+][0-9A-Za-z.+-]+)?)\r?$",path.read_text(encoding="utf-8"))
        if match is None:raise RuntimeError("Missing supported product version: "+str(path))
        return match.group(1)
    version=declared(ROOT/"pubspec.yaml")
    if declared(ROOT/"example/pubspec.yaml")!=version:
        raise RuntimeError("Gallery pubspec version differs from the root product version")
    target=ROOT/"example/lib/shared/version.g.dart"
    expected=("// Generated from root pubspec.yaml by tool/verify.py --generate-gallery-version.\n"
              "// Do not edit; the package configuration is the sole version owner.\n"
              "const String galleryVersion = '"+version+"';\n")
    if generate:target.write_text(expected,encoding="utf-8")
    if not target.is_file() or target.read_text(encoding="utf-8")!=expected:
        raise RuntimeError("Stale Gallery version projection; run python tool/verify.py --generate-gallery-version")
    return {"version":version,"generated":str(target.relative_to(ROOT)),
            "sha256":hashlib.sha256(target.read_bytes()).hexdigest()}


def policy():
    gallery_version_source()
    violations=[]
    for p in (ROOT/"lib").rglob("*.dart"):
        text=p.read_text(encoding="utf-8")
        for banned in ("dart:io","dart:html","package:http/","package:animal_island_ui_re/","example/"):
            if banned in text: violations.append(f"{p.relative_to(ROOT)}: forbidden runtime dependency {banned}")
    for name in ("README.md","README.zh-CN.md","LICENSE","NOTICE","CHANGELOG.md","ARCHITECTURE.md",
                 "docs/API.md","docs/ACCEPTANCE.md","docs/RIGHTS.md","docs/MAINTENANCE.md"):
        if not (ROOT/name).is_file():violations.append("Missing "+name)
    registry=json.loads((ROOT/"library.json").read_text(encoding="utf-8"))
    violations.extend(source_structure(registry))
    for relative in registry["components"]:
        c=json.loads((ROOT/relative).read_text(encoding="utf-8"))
        if not c.get("scenarios"):violations.append("Missing component scenarios "+relative)
    exports=(ROOT/"lib/animal_island_ui.dart").read_text(encoding="utf-8")
    for statement in re.findall(r"^export\b[\s\S]*?;",exports,re.MULTILINE):
        if " show " not in re.sub(r"\s+"," ",statement):violations.append("Implicit export: "+statement)
    if violations:raise RuntimeError("\n".join(violations))
    return {"result":"pass","components":len(registry["components"]),"note":"Source policy and presence only, not semantic or legal acceptance."}

def package_members():
    """Runtime plus the reachable local documentation linked from its READMEs."""
    from urllib.parse import urlsplit, unquote
    files={ROOT/name for name in ("pubspec.yaml","LICENSE","NOTICE","README.md","README.zh-CN.md","CHANGELOG.md")}
    files.update((ROOT/"lib").rglob("*.dart"))
    files.update(p for p in (ROOT/"assets").rglob("*") if p.is_file())
    pending=[p for p in files if p.suffix==".md"]; visited=set()
    while pending:
        source=pending.pop()
        if source in visited:continue
        visited.add(source)
        text=re.sub(r"(?ms)^\s*(```|~~~).*?^\s*\1\s*$", "", source.read_text(encoding="utf-8-sig"))
        urls=re.findall(r"!?\[[^\]\n]*\]\(\s*(<[^>]+>|[^\s)]+)(?:\s+[\"'][^\n]*?[\"'])?\s*\)",text)
        urls+=re.findall(r"(?:href|src)=[\"']([^\"']+)[\"']",text)
        for url in urls:
            parsed=urlsplit(url.strip("<>"))
            if parsed.scheme or parsed.netloc or not parsed.path:continue
            target=(source.parent/unquote(parsed.path)).resolve()
            if not target.is_relative_to(ROOT) or not target.is_file():raise RuntimeError("Invalid package documentation target: "+str(source)+" -> "+url)
            if target not in files:
                files.add(target)
                if target.suffix==".md":pending.append(target)
    return sorted(files)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--flutter",default=shutil.which("flutter") or "flutter")
    parser.add_argument("--builds",action="store_true")
    parser.add_argument("--generate-gallery-version",action="store_true",help="Project root package version into the existing Gallery badge")
    args=parser.parse_args()
    if args.generate_gallery_version:
        print(json.dumps(gallery_version_source(generate=True),ensure_ascii=False,indent=2))
        return
    flutter=str(Path(args.flutter).resolve()) if Path(args.flutter).is_file() else shutil.which(args.flutter)
    if not flutter:raise SystemExit("Flutter command not found.")
    run_id=datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    out=ROOT/"evidence/raw"/run_id;out.mkdir(parents=True)
    records=[]
    def run(name,argv,cwd=ROOT):
        started=time.monotonic()
        log=out/(name+".txt")
        with log.open("w",encoding="utf-8") as stream:
            stream.write("COMMAND "+json.dumps(argv)+"\nCWD "+str(cwd)+"\n");stream.flush()
            try:
                completed=subprocess.run(argv,cwd=cwd,stdout=stream,stderr=subprocess.STDOUT,
                                         timeout=900,encoding="utf-8")
                code=completed.returncode
            except (OSError,subprocess.TimeoutExpired) as exc:
                stream.write("\n"+repr(exc));code=-1
        entry={"name":name,"command":argv,"cwd":str(cwd),"exit_code":code,
               "seconds":round(time.monotonic()-started,2),"log":log.relative_to(ROOT).as_posix(),
               "sha256":hashlib.sha256(log.read_bytes()).hexdigest()}
        records.append(entry);dump(out/"commands.json",records)
        print(f"{name}: {'PASS' if code==0 else 'FAIL'} ({entry['seconds']}s)",flush=True)
        if code:raise RuntimeError(f"{name} failed; inspect {log}")
    try:
        dump(out/"source-policy.json",policy())
        run("reference-coverage",[sys.executable,str(ROOT/"tool/reference_coverage.py")])
        run("sdk",[flutter,"--version","--machine"])
        run("resolve",[flutter,"pub","get"])
        run("root-tests",[flutter,"test","--reporter","json"])
        run("analysis",[flutter,"analyze","--fatal-infos"])
        run("gallery-tests",[flutter,"test","--reporter","json"],ROOT/"example")
        run("dependencies",[flutter,"pub","deps","--json"])
        # Public archive is an explicit manifest, independent of working-copy imports.
        members=package_members()
        version=re.search(r"(?m)^version: ([0-9]+\.[0-9]+\.[0-9]+(?:[-+][0-9A-Za-z.+-]+)?)$", (ROOT/"pubspec.yaml").read_text(encoding="utf-8"))
        if version is None:raise RuntimeError("Missing supported package version.")
        archive=out/("animal_island_ui-"+version.group(1)+".zip")
        with zipfile.ZipFile(archive,"w",zipfile.ZIP_DEFLATED) as z:
            for file in sorted(members):z.write(file,file.relative_to(ROOT).as_posix())
        # Record complete assets; size acceptance is a separate measured release review.
        dump(out/"package.json",{"sha256":hashlib.sha256(archive.read_bytes()).hexdigest(),
            "bytes":archive.stat().st_size,"members":[p.relative_to(ROOT).as_posix() for p in sorted(members)]})
        workspace=ROOT/"scratch"/("consumer-"+run_id)
        extracted=workspace/"package";consumer=workspace/"consumer"
        extracted.mkdir(parents=True);consumer.mkdir()
        with zipfile.ZipFile(archive) as z:z.extractall(extracted)
        (consumer/"test").mkdir()
        (consumer/"pubspec.yaml").write_text(
            "name: island_package_consumer\npublish_to: none\nenvironment:\n  sdk: '>=3.13.3 <4.0.0'\n"
            "dependencies:\n  flutter:\n    sdk: flutter\n  animal_island_ui:\n    path: ../package\n"
            "dev_dependencies:\n  flutter_test:\n    sdk: flutter\n",encoding="utf-8")
        (consumer/"test/consumer_test.dart").write_text(
            "import 'package:flutter/material.dart';\nimport 'package:flutter_test/flutter_test.dart';\n"
            "import 'package:animal_island_ui/animal_island_ui.dart';\n"
            "void main(){testWidgets('extracted public package is usable',(t)async{var calls=0;"
            "await t.pumpWidget(MaterialApp(theme:IslandTheme.create(),home:Scaffold(body:"
            "IslandButton(child:const Text('Visit'),onPressed:()=>calls++))));await t.tap(find.text('Visit'));"
            "expect(calls,1);expect(t.takeException(),isNull);});}\n",encoding="utf-8")
        run("consumer-resolve",[flutter,"pub","get"],consumer)
        config=json.loads((consumer/".dart_tool/package_config.json").read_text())
        package=next(p for p in config["packages"] if p["name"]=="animal_island_ui")
        from urllib.parse import urljoin, urlparse, unquote
        actual=Path(unquote(urlparse(urljoin((consumer/".dart_tool/package_config.json").as_uri(),package["rootUri"])).path))
        if os.name=="nt" and str(actual).startswith("\\"):actual=Path(str(actual)[1:])
        if actual.resolve()!=extracted.resolve():raise RuntimeError("Consumer resolved the wrong package.")
        run("consumer-test",[flutter,"test","--reporter","json"],consumer)
        if args.builds:
            run("web-build",[flutter,"build","web","--release","--no-web-resources-cdn"],ROOT/"example")
            run("windows-build",[flutter,"build","windows","--release"],ROOT/"example")
            run("windows-flow",[flutter,"test","integration_test/gallery_test.dart","-d","windows","--reporter","expanded"],ROOT/"example")
        sizes={}
        for target,folder in [("web",ROOT/"example/build/web"),("windows",ROOT/"example/build/windows/x64/runner/Release")]:
            if folder.exists():sizes[target]=sum(p.stat().st_size for p in folder.rglob("*") if p.is_file())
        dump(out/"build-sizes.json",sizes)
        dump(out/"result.json",{"result":"pass","builds_requested":args.builds,"commands":records,
             "limitations":["Manual visual parity, release rights and performance/size review remain separate. Screen-reader validation is excluded by the user decision on 2026-10-17."]})
        print("EVIDENCE "+str(out),flush=True)
        return 0
    except Exception as exc:
        dump(out/"result.json",{"result":"fail","error":str(exc),"commands":records})
        print(str(exc),file=sys.stderr);return 1
if __name__=="__main__":sys.exit(main())
