## milestone: lobby

- timed round structure
- leaderboard

### polish

- bug: cannot paste from clipboard on web (severity: minor, effort: high)
- gameplay edge cases:
  - squish detection: it doesn't require that the top and bottom overlaps are two separate bodies, ergo, you could spawn inside of a block and die immediately

- performance (severity: moderate, effort: high): game freezes on on first block break
  - at first I assumed this was because I forgot to preload the explosion scene, but that's not the case. now it looks like some kind of shader cache problem, and i only found weird hacky-looking fixes for it, so I'm deferring this for now

- use overview camera before join
- client-side prediction
- CPU players
- sfx
- a11y options, e.g. reduce/disable screen shake, glow

## ideas

- interactive tutorial or somethin
- player colors
- different kinds of blocks, e.g. hyperspeed blocks, invulnerable blocks, exploding blocks
- block grab cooldown?
