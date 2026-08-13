- [ ] create NetworkedGame wrapping around generic Game

- [ ] throwing blocks
  - on press grab:
    - delete the first block that overlaps with the cursor
    - set player holding state to true
    - while holding, show a fake block in place of the cursor
  - on release grab:
    - set player holding state to false
    - create flying block where held block was, going in the faced direction

- [ ] flying blocks
  - goes fast in one direction
  - explodes after its max lifetime is up (7s)
  - can hit 2 blocks before it explodes on the third
  - kills players on contact

- [ ] pause menu
