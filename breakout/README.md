# Project 2: Breakout
Implementation of additional features for the course's Breakout game. 

## Specfication



* Add a `Powerup` class to the game that spawns a powerup. This `Powerup` should spawn randomly, and gradually descend toward the player. Once collided with the `Paddle`, two more `Ball`s should spawn and behave identically to the original, including all collision and scoring points for the player. Once the player wins and proceeds to the `VictoryState` for their current level, the `Ball`s should reset so that there is only one active again.
* Grow and shrink the `Paddle` such that it’s no longer just one fixed size forever. In particular, the Paddle should shrink if the player loses a heart (but no smaller of course than the smallest paddle size) and should grow if the player exceeds a certain amount of score (but no larger than the largest Paddle). 
* Add a locked `Brick` to the level spawning, as well as a key powerup. The locked Brick should not be breakable by the ball normally, unless they of course have the key `Powerup`! The key `Powerup` should spawn randomly just like the `Ball` `Powerup` and descend toward the bottom of the screen just the same, where the `Paddle` has the chance to collide with it and pick it up. 

## Acknowledgements
Original code and assets provided as part of Harvard's CS50 Introduction to Game Development course, [found here](https://cs50.harvard.edu/games/2018/projects/2/breakout/).
Implementation decribed in the specification made by Noah Hollingsworth (hollingsworthjh@protonmail.com).