# Dungeon exploration 23/12/01 - 24/02/01

Write a rouguelike dungeon crawler in a similar style to [NetHack](https://www.nethack.org/)
(play it) with treasure, monsters, and character classes of a similar style.

The game must feature:
- multiple rooms containing either a door to the next floor, hostile entities, treasure, equiptment, and/or empty space
- multiple floors consisting of rooms
- difficulty increasing as the player ventures deeper incrementing the floor index
- hostile entities that move between rooms
- potions (or equivalent) to restore health
- potions (or equivalent) to restore stamina and/or mana equivalent
- a health system where damage varies based on equiptment currently in use
- a companion (dog, fellow adventurer, or similar) which the player may recruit
- permanent death (die and you start again) with persistance (can find their body from a previous run)

The game may feature:
- entities that move between floors
- a minor boss room every 5 floors with a hostile entity that's of higher difficulty equivalent in difficulty to rooms 5 floors ahead
- a major boss room every 15 floors with a hostile entity that's of higher difficulty equivalient in difficulty to rooms 15 floors ahread
- a level system whwre the player stats increases as they slay hostile entities

The game shall:
- be playable on linux
- have floors generated iteratively (e.g wavefunction collapse, markov chain tile generation)