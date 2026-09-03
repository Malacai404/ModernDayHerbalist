import pathlib, re
roots = [pathlib.Path(r"c:\GodotProjects\ModernDayHerbalist\scripts"), pathlib.Path(r"c:\GodotProjects\ModernDayHerbalist\addons")]
for root in roots:
    if not root.exists(): continue
    for p in root.rglob("*.gd"):
        if "addons/dialogue_manager" in str(p): continue
        t = p.read_text(encoding="utf-8")
        out_lines=[]
        for line in t.splitlines():
            s=line.strip()
            if s.startswith("#"):
                continue
            if re.match(r"^\s*print\s*\(.*", line):
                continue
            if "print(" in line and s.startswith("print"):
                if re.match(r"^\s*print\(.*", line):
                    continue
            # also strip trailing comments not in strings: naive
            # keep line as is minus trailing # comment if outside quotes
            # We already skipped full-line comments
            out_lines.append(line.rstrip())
        # remove push_warning that is debug? keep push_warning for real errors? Remove plant debug ones
        filtered=[]
        for l in out_lines:
            ls=l.strip()
            # remove our debug prints that escaped: contains "[PlantMenu" or "[Player]"
            if '"[PlantMenu' in l or "'[PlantMenu" in l or '"[Player]' in l or "'[Player]" in l:
                # if line is print or push_warning with that tag, skip
                if "print" in ls or "push_warning" in ls:
                    continue
            filtered.append(l)
        # collapse double blanks
        final=[]
        prev=False
        for l in filtered:
            blank = (l.strip()=="")
            if blank and prev:
                continue
            final.append(l)
            prev=blank
        new_t = "\n".join(final)+"\n"
        if new_t != t:
            p.write_text(new_t, encoding="utf-8")
            print(f"cleaned {p}")
print("done")
