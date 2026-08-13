- throwing blocks
  - on press grab:
    - [x] delete the first block that overlaps with the cursor
    - [x] set player holding state to true
    - [x] while holding, show a fake block in place of the cursor, interpolated to make it look like it's being "dragged along"
  - on release grab:
    - [x] set player holding state to false
    - [ ] create flying block where held block was, going in the faced direction
  - [x] players should release if they die while holding

- flying blocks
  - [ ] goes fast in one direction
  - [ ] explodes after its max lifetime is up (7s)
  - [ ] can hit 2 blocks before it explodes on the third
  - [ ] kills any player on contact (except the one who yeeted it)

- [ ] pause menu

## ideas

- block grab cooldown?
