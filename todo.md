## milestone: prototype / playtest

- player can no longer interact with the world after dying once
	- this includes picking up blocks, getting squished, and getting killed by flying blocks, but for some reason, they can always get crushed
	- some guesses:
		- a regression from the intangibility refactor
		- something related to collision masks

- cannot paste from clipboard on web (severity: minor, effort: high)

### polish

- performance (severity: moderate, effort: high): game freezes on on first block break
  - at first I assumed this was because I forgot to preload the explosion scene, but that's not the case. now it looks like some kind of shader cache problem, and i only found weird hacky-looking fixes for it, so I'm deferring this for now

- use overview camera before join
- client-side prediction
- timed round structure with ready lobby
- leaderboard
- CPU players
- sfx
- a11y options, e.g. reduce/disable screen shake, glow

## ideas

- block grab cooldown?
- player colors
