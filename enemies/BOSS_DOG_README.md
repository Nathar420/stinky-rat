# Boss Dog setup (Godot 4.7)

The dog is a second boss for Stinky Rat. Its script is `enemies/boss_dog.gd` (`class_name BossDog`). There is no scene file yet on purpose: you build that in the editor, with your own drawings.

You can fight the dog before the art is done. If an animation is missing, the script skips it and uses a timer instead. Until `dog_walk` has frames, it draws a simple brown dog. The bark ring, the dirt mound, and the eruption also draw simple shapes when you have not assigned art for them.

Nothing in the cat boss was changed. The cat keeps spawning as long as you leave its spawner alone.

## 1. Make the scene

1. Open the project in Godot 4.7.
2. In the Scene menu, choose **New Scene**.
3. In the Scene dock, click **Other Node**, search for `CharacterBody2D`, and create it. Rename the root to `BossDog`.
4. Select `BossDog`. In the Inspector, find **Script** (it says `[empty]`). Click the dropdown arrow and choose **Load**. Pick `res://enemies/boss_dog.gd`.

   The script extends `CharacterBody2D`, so the root has to be that node type. Load the file that is already in the project. Do not use **New Script**, or Godot will make a second empty script.

5. With `BossDog` selected, click **Add Child Node** (the **+** at the top of the Scene dock) and add an `AnimatedSprite2D`. Rename it to exactly `dog_animation` (all lowercase, with the underscore). The script looks up that name.
6. Add another child of `BossDog`: `CollisionShape2D`. In the Inspector, set **Shape** to **New CircleShape2D**. Set the radius to about **46**. (The cat's body circle is about 38. The dog is a bit bigger.)
7. Add a child of `BossDog`: `Area2D`. Then add a child of that `Area2D`: `CollisionShape2D`. Give it a **New CircleShape2D** with radius about **54**. (The cat's touch circle is about 44.)

   This area is what hurts the player on touch. Do not connect any signals. The script connects `body_entered` itself. Leave the collision layer and mask on the defaults, the same way the cat scene does. The player is on layer 1, and a new Area2D already listens to layer 1.

8. Optional effect nodes. Skip these if you want the script to draw circles for you. If you add them, the names have to match:

   | Node name (child of BossDog) | What it is |
   | --- | --- |
   | `Shockwave` | The bark ring. `Sprite2D` or `AnimatedSprite2D`. |
   | `DirtMound` | The dirt pile that slides toward the player. `Sprite2D` or `AnimatedSprite2D`. |
   | `Eruption` | The dirt burst when the dog jumps out. `Sprite2D`, `AnimatedSprite2D`, or `CPUParticles2D`. |

   Click the eye next to each of these so they start hidden. The script shows them when that attack happens.

   You can also save each effect as its own scene and assign it in the Inspector (see the scene list below). If both a scene and a child exist, the script uses the scene and leaves the child hidden. The scene's root node has to be a `Node2D` (`Sprite2D`, `AnimatedSprite2D`, and particle nodes all count).

Your scene tree should look like this:

```
BossDog                 (CharacterBody2D, script: boss_dog.gd)
├── dog_animation       (AnimatedSprite2D)
├── CollisionShape2D    (CircleShape2D, radius ~46)
├── Area2D
│   └── CollisionShape2D (CircleShape2D, radius ~54)
├── Shockwave           (optional, hidden)
├── DirtMound           (optional, hidden)
└── Eruption            (optional, hidden)
```

## 2. Add the animations

Select `dog_animation`. In the Inspector, next to **Sprite Frames**, choose **New SpriteFrames**. Click the new SpriteFrames resource. A **SpriteFrames** panel opens at the bottom of the editor.

Godot starts you with one animation called `default`. Double-click that name in the animation list and rename it to `dog_walk`. To add another one, click **Add Animation** (the page icon with a plus) and name it.

Names have to match exactly, including the `dog_` prefix. Capital letters count, so `Dog_Walk` will not play.

For each animation:

- Select it in the list.
- Set **Speed (FPS)** to the number in the art table below.
- Turn **Loop** on only for the rows that say yes. The loop button is the circular arrows next to the FPS.
- Drag your PNG frames from the FileSystem dock onto the frame strip, left to right, in the order they should play.

Add these nine animations when you have the drawings. You can leave any of them out while you are still drawing. The dog will not crash, and it will not wait forever on a clip that is not there.

| Animation name | What it should look like | Frames | Loop | FPS |
| --- | --- | --- | --- | --- |
| `dog_walk` | Side view, trotting. Legs cycle. Facing right. | 5 | yes | 8 |
| `dog_shake` | Plants its paws and shakes. Later frames can show fleas flying off. | 5 | no | 10 |
| `dog_charge_windup` | Crouches low. Front paws scrape backward. Facing right. | 4 | no | 8 |
| `dog_charge` | Body stretched out in a full sprint, ears back. Facing right. | 4 | yes | 12 |
| `dog_skid` | Leans back, paws dug in, a little dust. | 3 | no | 8 |
| `dog_bark` | Stands still, head up, mouth open. | 4 | no | 8 |
| `dog_dig` | Paws digging, body sinking a little lower each frame. | 5 | no | 8 |
| `dog_emerge` | Bursts up out of the ground, dirt around it. | 5 | no | 10 |
| `dog_death` | Collapses or flops. The last frame can stay on the ground. | 5 | no | 6 |

The cat's walk, pounce, and shake clips in the editor are set to **5 FPS**. Use 5 instead of the numbers above if you want the dog to feel like the same choppy timing. The higher numbers are so the dash and the burst read a bit clearer.

### Canvas size

Look in `enemies/boss cat animations/`. The frames the cat scene actually uses (`cat_walk`, `cat_pounce`, `cat_shake`) are **128 pixels wide and 64 pixels tall**. Draw every dog frame at **128×64** with a transparent background so it sits in the same box.

`cat_animation_1.png` is 92×48 and is not used by the cat scene. Do not match that size.

In `scenes/boss_cat.tscn`, the cat sprite is scaled to about **x = 1.65, y = 1.81**. Set `dog_animation`'s **Scale** to the same (`1.65` and `1.81`). A 128×64 drawing then shows up at about 211×116 pixels, the same size as the cat. You can nudge it later.

Draw every dog frame **facing right**. The script flips the sprite when the dog faces left.

Keep the paws near the bottom center of the picture so the dog stands on the collision circle. The cat sprite is nudged to about `(-1, 1)` in its scene. You can do the same if the dog looks a pixel off.

If the pictures look blurry, click a PNG in the FileSystem dock, open the **Import** tab, set **Filter** to **Nearest**, and click **Reimport**.

A good place to keep the files is a new folder `enemies/boss dog animations/`, next to `enemies/boss cat animations/`.

### Effect sprites

These are separate from the nine dog animations. Put them on the optional child nodes, or save each one as a tiny scene and assign the scene in the Inspector.

| Sprite | What to draw | Canvas | Frames | Loop | FPS |
| --- | --- | --- | --- | --- | --- |
| Shockwave ring | A hollow ring, centered, with a transparent hole. Not a filled circle. | 128×128 (256×256 is fine if you want it smoother) | 1, or 4 if you want it to shimmer | yes, if it has more than one frame | 8 |
| Dirt mound | A heap of dirt, maybe with a few pebbles | 128×64 | 4 | yes | 6 |
| Eruption burst | Dirt flying outward from the center | 128×128 | 5 or 6 | no | 12 |

The script grows the shockwave by scaling that picture. If the ring touches the edges of a 128×128 canvas, leave **Shockwave Sprite Radius** at **64** (half of 128). If you use a 256×256 picture, set it to **128**.

You do not need these three to test. With nothing assigned, the bark draws a pale ring, the dig draws a brown mound, and the pop-out draws a fading dirt circle.

## 3. Assign the scenes in the Inspector

Select the `BossDog` root. The exported scenes are at the bottom of the Inspector.

| Inspector property | Scene to assign |
| --- | --- |
| `enemy_flea_scene` | `res://scenes/enemy_flea.tscn` |
| `xp_drop_scene` | `res://scenes/xp_drop.tscn` |
| `gold_pickup_scene` | `res://scenes/gold_pickup.tscn` |
| `health_pickup_scene` | `res://scenes/health_pickup.tscn` |
| `floating_score_scene` | `res://scenes/floating_score.tscn` |
| `floating_damage_scene` | `res://ui/floating_damage.tscn` |
| `loot_chest_scene` | `res://scenes/loot_chest.tscn` |
| `death_particles_scene` | Leave empty for now. There is no death-particle scene in the project yet. |
| `shockwave_scene` | Optional. Leave empty to use the `Shockwave` child, or a drawn ring. |
| `dirt_mound_scene` | Optional. Leave empty to use the `DirtMound` child, or a drawn mound. |
| `eruption_scene` | Optional. Leave empty to use the `Eruption` child, or a drawn burst. |

If a scene has moved to another folder, pick it from wherever it lives now. The script does not hard-code those paths.

Save the scene with **Ctrl+S** as `res://scenes/boss_dog.tscn`.

### What the spawner copies, and what it does not

`enemies/boss_spawner.gd` was written for the cat. When it spawns a boss it copies these onto the boss, using the cat's property names:

- `xp_drop_scene`
- `health_pickup_scene` (from the spawner's **Health Drop Scene**)
- `gold_pickup_scene`
- `floating_score_scene`
- `floating_damage_scene`
- `enemy_flea_scene`

The dog uses those same names, so pointing a spawner at the dog fills them in. You can leave those six empty on the dog scene if the spawner already has them. The spawner's values win at spawn time.

The spawner does **not** copy `loot_chest_scene` or `death_particles_scene`. Set those on the dog scene itself or they stay empty.

Each flea the dog shakes off receives every drop the dog has:

- XP, health, gold, floating score, floating damage
- `loot_chest_scene` (the cat boss never passes this one)
- `death_particles_scene`, but only if the flea script actually has a variable with that name

The current flea script does not have `death_particles_scene` yet, so fleas ignore it and nothing breaks. When that variable exists, the dog will hand the scene over. The dog also plays `death_particles_scene` on its own death if you assigned one.

Health and gold use different names on the flea (`health_drop_scene`, `gold_drop_scene`). The dog translates them. You do not need to rename anything.

## 4. Make a spawner spawn the dog, and keep the cat

The cat is spawned by the `BossSpawner` node in `scenes/world.tscn`. That node currently points at `scenes/boss_cat.tscn`. In this world scene its **Spawn Time** is **10** seconds so the cat shows up quickly. The spawner script's own default is **420** seconds (7 minutes). Do not change the cat node's scene if you want both bosses.

To add the dog beside the cat:

1. Open `scenes/world.tscn`.
2. Select the `BossSpawner` node.
3. Duplicate it with **Ctrl+D**.
4. Rename the copy to `BossSpawnerDog`.
5. In the Inspector, set **Boss Scene** to `res://scenes/boss_dog.tscn`.
6. Set **Spawn Time** to a number later than the cat. If the cat node is still at 10 seconds, try **70** for a quick test, or **600** (10 minutes) for a real run so the cat happens first.
7. Leave the original `BossSpawner`'s **Boss Scene** on `scenes/boss_cat.tscn`.
8. Save the world scene.

The duplicate keeps the original drop-scene assignments. That is what you want. Do not clear them.

The spawner still prints `BOSS CAT SPAWNING` in the Output panel, because that text lives in the shared spawner script. If the dog appears, the spawn worked.

To spawn only the dog, change **Boss Scene** on the original `BossSpawner` to `scenes/boss_dog.tscn` instead of duplicating. The cat will not spawn from that node.

## 5. Try it before the drawings are finished

Press **F5**. After the dog's spawn time, a brown placeholder walks in, circles you, then picks an attack. You can damage it, and the killing blow drops loot and score the same way the cat does (XP, gold, and health pickups, plus a floating score number).

While the art is missing you will see:

- A brown stand-in dog, which turns red for a moment when it is hit. It goes away once `dog_walk` has at least one frame.
- A red aim line during the charge crouch, until `dog_charge_windup` has frames.
- A pale ring for the bark.
- A brown mound while the dog is underground, then a dirt burst when it jumps out.

One temporary PNG on `dog_walk` is enough to see your real drawing move around. The other attacks still work without their clips.

## What the dog does

It does one thing at a time. Between attacks it circles you. When it picks an attack, it will not pick that same attack next. A forced flea shake (the timer, or a health threshold) can still happen after a random shake.

- **Chase.** Walks in until it is about 190 pixels away, then circles. Animation: `dog_walk`.
- **Flea shake.** Stops and flings a ring of fleas outward. Happens on a timer (about every 11 seconds), at 75%, 50%, and 25% health, and sometimes as the random attack. Animation: `dog_shake`.
- **Charge.** Crouches (`dog_charge_windup`), then sprints in a straight line at the spot where you were when the crouch ended (`dog_charge`). It does not turn mid-dash. Touching it during the dash hurts more (42, instead of 24) and knocks you back. It then skids (`dog_skid`) and takes extra damage during that slide.
- **Bark.** Stops and barks (`dog_bark`). A ring grows outward. You get hit and knocked back only when the edge of the ring reaches you, not from standing in the middle after it has passed. Fleas the ring touches are flung outward.
- **Dig.** Digs down (`dog_dig`), disappears, and cannot be hit. A dirt mound slides toward you for a couple of seconds, then stops and the screen shakes. Step off the mound. The dog bursts out of that spot (`dog_emerge`) and hurts you if you are still in the small circle.
- **Zoomies.** Under 30% health the dog moves faster, its cooldowns finish sooner, and a charge becomes 2 or 3 dashes in a row. The crouch after the first dash is shorter.

Default health is **1750**. Contact damage is **24**, the dash is **42**, the bark is **20**, and the eruption is **36**. Killing it is worth **14000** score. All of those are exports, so you can retune them without editing the script.

## Tuning values

Select the `BossDog` root. These are the Inspector values and what they change. The number in parentheses is the default.

### Health and contact

| Variable | What it does |
| --- | --- |
| `max_health` (1750) | How many hit points the dog has. Zoomies starts from the fraction below. |
| `contact_damage` (24) | Damage when the player walks into the dog. |
| `charge_contact_damage` (42) | Damage while the dog is mid-dash. |
| `charge_knockback` (520) | How far the dash flings the player. |
| `contact_cooldown` (0.5) | Seconds before the same touch can hurt again. |
| `score_reward` (14000) | Score given when the dog dies. |
| `skid_damage_taken_multiplier` (1.5) | Damage the dog takes during the skid. 1.5 means 50% more. |

### Chase

| Variable | What it does |
| --- | --- |
| `chase_speed` (115) | Speed while walking in or circling. |
| `keep_distance` (190) | Distance it tries to keep. Farther than this, it walks straight at the player. |
| `orbit_speed_ratio` (0.5) | Circle speed as a fraction of chase speed. 0.5 matches the cat. |
| `decision_interval` (2.2) | Seconds of circling between special attacks. |

### Zoomies

| Variable | What it does |
| --- | --- |
| `enrage_health_ratio` (0.30) | Health fraction that starts Zoomies. 0.30 is 30%. |
| `enrage_speed_multiplier` (1.45) | Multiplier on chase speed and on the underground mound. |
| `enrage_cooldown_multiplier` (0.60) | Cooldowns finish sooner. 0.6 means they take 60% as long. |
| `enrage_charge_speed_multiplier` (1.15) | Extra dash speed while enraged. Kept small so the dash stays readable. |
| `enrage_anim_speed_scale` (1.3) | Playback speed of `dog_animation` while enraged. |
| `charge_chain_min` (2) | Fewest dashes in a row once Zoomies starts. |
| `charge_chain_max` (3) | Most dashes in a row once Zoomies starts. |

### Charge

| Variable | What it does |
| --- | --- |
| `charge_speed` (620) | Straight-line dash speed. |
| `charge_windup_time` (0.55) | Crouch time before the first dash. The aim locks at the end. |
| `charge_chain_windup_time` (0.32) | Shorter crouch for the 2nd and 3rd dashes in a chain. |
| `charge_duration` (0.45) | How long the dash travels. |
| `skid_duration` (0.48) | Recovery after each dash. The dog slides and takes extra damage. |
| `skid_speed` (160) | Speed at the start of the skid. It eases down to zero. |
| `charge_cooldown` (5.5) | Seconds before Charge can be picked again. |

### Bark

| Variable | What it does |
| --- | --- |
| `bark_windup_time` (0.45) | Time spent barking before the ring starts growing. |
| `bark_recover_time` (0.20) | Extra time the dog holds still after the ring is done. |
| `bark_cooldown` (7.5) | Seconds before Bark can be picked again. |
| `shockwave_max_radius` (280) | How far the ring travels, in pixels. |
| `shockwave_expand_speed` (340) | How fast the ring grows, in pixels per second. |
| `shockwave_thickness` (36) | Thickness of the edge that hurts. The inside of the ring does not. |
| `shockwave_sprite_radius` (64) | Radius of your ring picture at scale 1. Half the canvas width if the ring touches the edges. |
| `bark_damage` (20) | Damage when the ring's edge hits the player. |
| `bark_knockback` (700) | How far the bark flings the player. |
| `flea_bark_knockback` (520) | How hard the bark flings fleas outward. |

### Dig

| Variable | What it does |
| --- | --- |
| `dig_down_time` (0.60) | Time spent digging before the dog vanishes. |
| `burrow_time` (2.5) | How long the mound chases, including the warning. |
| `burrow_warning_time` (0.55) | Last part of the burrow. The mound stops chasing and the camera shakes. |
| `mound_speed` (140) | How fast the mound slides toward the player. |
| `mound_stop_distance` (18) | The mound stops nudging once it is this close, before the warning lock. |
| `emerge_radius` (78) | Eruption hits the player inside this many pixels. |
| `emerge_damage` (36) | Damage dealt by the eruption. |
| `emerge_knockback` (480) | How far the eruption flings the player. |
| `emerge_recover_time` (0.55) | Time the dog holds the emerge pose before chasing again. |
| `dig_cooldown` (9.0) | Seconds before Dig can be picked again. |

### Fleas, loot, and camera shake

| Variable | What it does |
| --- | --- |
| `fleas_per_spawn` (12) | Fleas flung out in one shake. |
| `flea_spawn_cooldown` (11) | Seconds between automatic shakes. Also the cooldown before Shake can be picked as an attack. |
| `flea_spawn_radius` (54) | How far from the dog's center the fleas appear. |
| `flea_leap_speed` (2200) | Launch speed given to each flea. The flea script turns it into a short hop. |
| `shake_duration` (0.80) | How long the dog stands still in the shake. |
| `flea_release_delay` (0.25) | Seconds into the shake before the fleas actually launch. |
| `xp_drops_count` (6) | XP pickups dropped on death. |
| `gold_drops_count` (10) | Gold pickups dropped on death. |
| `health_drops_count` (4) | Health pickups dropped on death. |
| `death_fallback_time` (1.0) | How long the corpse stays if `dog_death` is missing. If the animation exists, the script waits for its real length instead. |
| `charge_shake` (4) | Camera shake when a dash connects. |
| `bark_shake` (5) | Camera shake when the bark starts. |
| `warning_shake` (3) | Camera shake while the mound is about to erupt. |
| `emerge_shake` (8) | Camera shake when the dog bursts out. |
| `enrage_shake` (6) | Camera shake when Zoomies starts. |

The scene slots (`enemy_flea_scene`, the drop scenes, and the three effect scenes) are listed in section 3.
