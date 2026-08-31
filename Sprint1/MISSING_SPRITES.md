# Missing Sprites & Placeholders

> All 10 new fruits **function** today; they render with placeholder textures/meshes.
> Replace each `PLACEHOLDER` entry below with final art and the code will pick it up automatically
> (no logic changes needed — just swap `preload("res://textures/...")` / `.tres` `texture`).

## 1) Fruits — `scripts/weapons/*.gd`

Each currently preloads a reused texture. Create the real file and change the preload path (or keep path and overwrite the file):

| Fruit (weapon id) | File | Current placeholder | Needs | Used by |
|---|---|---|---|---|
| Cherry (6) | `scripts/weapons/cherry.gd` | `res://textures/apple.png` | `textures/cherry.png` (fruit icon, 64–128px) + `textures/cherry_seed.png` | `cherry_seed.tres`, shop, inventory `slot.gd` |
| Mango (7) | `mango.gd` | `banana.png` | `mango.png` + `mango_seed.png` | `mango_seed.tres` |
| Kiwi (8) | `kiwi.gd` | `lemon.png` | `kiwi.png` + `kiwi_seed.png` | `kiwi_seed.tres` |
| Peach (9) | `peach.gd` | `apple.png` | `peach.png` + `peach_seed.png` | `peach_seed.tres` |
| Plum (10) | `plum.gd` | `Grape.png` | `plum.png` + `plum_seed.png` | `plum_seed.tres` |
| Orange (11) | `orange.gd` | `lemon.png` | `orange.png` + `orange_seed.png` | `orange_seed.tres` |
| Strawberry (12) | `strawberry.gd` | `apple.png` | `strawberry.png` + `strawberry_seed.png` | `strawberry_seed.tres` |
| Coconut (13) | `coconut.gd` | `watermelon_fruit.png` | `coconut.png` + `coconut_seed.png` | `coconut_seed.tres` |
| Dragonfruit (14) | `dragonfruit.gd` | `pineapple.png` | `dragonfruit.png` + `dragonfruit_seed.png` | `dragonfruit_seed.tres` |
| Passionfruit (15) | `passionfruit.gd` | `Grape.png` | `passionfruit.png` + `passionfruit_seed.png` | `passionfruit_seed.tres` |

Recommended size: `64×64` or `128×128` PNG, transparent BG, centered.

## 2) Seeds — `scripts/seeds/*.tres`

All 10 new `.tres` currently point at reused seed textures
(`grape_seed.png` / `apple_seed.png` / `banana_seed.png` / `lemon.png` / `watermelon_seeds.png`).

For each of the 10 above, when you create `textures/<fruit>_seed.png`, edit its `.tres`:

```ini
[ext_resource type="Texture2D" uid="..." path="res://textures/<fruit>_seed.png" id="2"]
```

UID can stay the same; just change `path`.

## 3) Projectiles — `objects/projectiles/*.tscn` + `scripts/projectiles/*.gd`

All 12 new projectiles use **procedural placeholder meshes**:

- Spheres: `cherry_pit`, `mango_slice`, `kiwi_shard`, `peach_fuzz`, `plum_blob`, `orange_segment`, `strawberry_dart`, `coconut_ball`, `dragon_orb`, `passion_pulp` — `SphereMesh` + `SphereShape3D`, colored `StandardMaterial3D` (emission on)
- Cylinders (AoE): `kiwi_cloud` (`r=0.9, h=0.25`, pale green), `passion_puddle` (`r=1.2, h=0.25`, amber)

These plus the moved-in originals `boomerang / scattershot / explosive / explosion / melon_shot` share `objects/projectiles/` now.

**To add sprite art**:
- Replace the `MeshInstance3D` with a `Sprite3D` (billboard) or keep mesh for 3D.
- Keep the `CollisionShape3D` size the same as `mesh.radius` / `cylinder.height/radius` so hitboxes stay correct.
- Suggested sprite names (all `textures/projectiles/`): `cherry_pit.png`, `mango_slice.png`, `kiwi_shard.png`, `kiwi_cloud.png`, `peach_fuzz.png`, `plum_blob.png`, `orange_segment.png`, `strawberry_dart.png`, `coconut_ball.png`, `dragon_orb.png`, `passion_pulp.png`, `passion_puddle.png`.

## 4) Pot growth sprites — `scripts/plantpot.gd`

`plantpot.tscn` swaps `ungrown` / `plantpot_growing` / `plantpot_grown` nodes and at harvest sets `plant_1/2/3.texture = SeedData._get_plant(plantid).texture`.
New fruits already plug in via the new `texture` — you only need the fruit icon. If you want per-stage growth sprites (sprout → sapling → fruit), add textures `textures/growth/<fruit>_stage0.png` … `_stage2.png` and extend `plantpot.gd: _process()` to pick stage.

## 5) Enemies — `objects/enemy*.tscn` + `scripts/enemies/*.gd`

- `enemy.tscn` (base), `enemy_brute.tscn`, `enemy_sprinter.tscn`, `enemy_spitter.tscn` currently share `models/enemy/enemy_Material.png` + `enemy_Sphere Base Color.png` with a runtime tint override in each `*.gd`:
  - Brute red `Color(0.72,0.2,0.2)`, Sprinter green `(0.35,0.82,0.4)`, Spitter purple `(0.65,0.55,0.95)`
- When models are ready, replace the `ArrayMesh`/`StandardMaterial3D` in each tscn; keep the node names (`MeshInstance3D`, `CollisionShape3D`, `NavigationAgent3D`, `healthbar`) and the `enemy` group + `damage(hurt)` method or `outerworld.gd` and all projectiles break.
- Enemy scripts expose `enemy_kind` / `loot_rolls` / `money_min/max` for tuning.

## 6) Shop — `ShopData` + `ShopController`

Shop is **data-driven** from `SeedData`. No per-fruit sprite plumbing — it just calls `get_icon()`/`get_display_name()` on whatever `SeedData._get_seed/_get_plant` returns. Once fruit/seed textures exist, shop slots auto-show them.

## Checklist (swap order)

1. Create `textures/cherry.png` … `passionfruit.png` + `textures/*_seed.png` (20 files)
2. Update `scripts/weapons/*.gd` preload paths → `textures/<fruit>.png`
3. Update `scripts/seeds/*_seed.tres` → `textures/<fruit>_seed.png`
4. (Optional) Replace `objects/projectiles/*.tscn` meshes with sprites
5. (Optional) Replace `models/enemy/*` / tint overrides when enemy art ready
6. Reimport — no code changes.
