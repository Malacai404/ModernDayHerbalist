import pathlib, re
root = pathlib.Path(r"c:\GodotProjects\ModernDayHerbalist\scripts")
for p in root.rglob("*.gd"):
    t = p.read_text(encoding="utf-8")
    lines = t.splitlines()
    out=[]
    for l in lines:
        ls = l.strip()
        # skip debug prints
        if ls.startswith("print(") or re.match(r"^\s*print\(.*", l):
            continue
        # skip full-line comments but keep docstring style? drop lines where stripped starts with #
        if ls.startswith("#"):
            continue
        # strip inline comments? keep code, drop trailing # comment only if " # " not in string
        # For this project we drop trailing comments naively when " # " appears outside quotes
        # simpler: if " # " in l and not '"' in l and not "'" in l: strip it
        # We'll attempt minimal: find last " # " and strip if before is code
        if " # " in l:
            # quick heuristic: if line contains '\"' skip
            if '"' not in l and "'" not in l:
                l = l.split(" # ")[0].rstrip()
        out.append(l.rstrip())
    # collapse multiple blank lines to one
    out2=[]
    prev_blank=False
    for l in out:
        is_blank = (l.strip()=="")
        if is_blank and prev_blank:
            continue
        out2.append(l)
        prev_blank=is_blank
    new_text = "\n".join(out2) + "\n"
    p.write_text(new_text, encoding="utf-8")
    print(f"cleaned {p.relative_to(root)}")
print("done strip")
