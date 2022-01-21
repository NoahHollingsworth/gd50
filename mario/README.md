# Project 4: Mario
Implementation of additional features for the course's Super Mario Bros game. 

## Specfication

* Program it such that when the player is dropped into the level, they’re always done so above solid ground.
* In `LevelMaker.lua`, generate a random-colored key and lock block (taken from keys_and_locks.png in the graphics folder of the distro). The key should unlock the block when the player collides with it, triggering the block to disappear. 
* Once the lock has disappeared, trigger a goal post to spawn at the end of the level. Goal posts can be found in `flags.png`; feel free to use whichever one you’d like! Note that the flag and the pole are separated, so you’ll have to spawn a `GameObject` for each segment of the flag and one for the flag itself. 
* When the player touches this goal post, we should regenerate the level, spawn the player at the beginning of it again (this can all be done via just reloading `PlayState`), and make it a little longer than it was before. 


## Acknowledgements
Original code and assets provided as part of Harvard's CS50 Introduction to Game Development course, [found here](https://github.com/NoahHollingsworth/gd50/tree/main/mario).

Implementation decribed in the specification made by Noah Hollingsworth (hollingsworthjh@protonmail.com).

