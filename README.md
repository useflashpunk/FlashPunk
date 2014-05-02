FlashPunk
=========

Create games. Easy.
-------------------

FlashPunk is a free ActionScript 3 library designed for developing 2D Flash games. It provides you with a fast, clean framework to prototype and develop your games in. This means that most of the dirty work is already done, letting you concentrate on the design and testing of your game.

[Get FlashPunk!](https://github.com/useflashpunk/FlashPunk/releases)

### The _total_ package.

Not only is FlashPunk absolutely free, it also contains everything you'll need to make the game you want. From its robust and dead-simple sprite-based graphics handling to its powerful live debugger, you won't need a team of berets and neckbeards to make your game come to life.

Features
--------

### Graphics

Helper classes for animations, tilemaps, text, backdrops, and more with z-sorted render lists for easy depth management.

``` actionscript
// Create a new Image from imported image.
[Embed(source = 'player.png')]
private const PLAYER_IMAGE:Class;
var playerImage:Image = new Image(PLAYER_IMAGE);
```

### Collision

Fast and manageable rectangle, pixel, and grid collision system with a plethora of built-in collision options.

``` actionscript
// Check for collision between the player and all enemies.
var touchedEnemy:Entity = player.collide("enemy", player.x, player.y);
```

### Motion

Powerful motion tweening for linear, curved, and path-based movement as well as spritesheet support and image transformation.

``` actionscript
// Move an enemy across the screen with a tween, stopping against walls.
enemy.moveBy(5, 0, "wall");
```

### Audio

Sound effect support with volume, panning, and fading/crossfading, complete with one-line sound playback.

``` actionscript
// Play a shoot sound.
[Embed(source = 'shoot.mp3')] private const SHOOT:Class;
var shoot:Sfx = new Sfx(SHOOT);
shoot.play();
```

### Particles

Quick and efficient particle effects and emitters allow for beautiful particle systems without slowing things down.

### Timesteps

Framerate-independent and fixed-framerate timestep support allow you to decide what mode is best for you and your game.

``` actionscript
// Add the frame time to a timer.
timer += FP.elapsed;
```

### Input

Simple keyboard and mouse input state checking makes setting keys and events incredibly easy, yet powerful.

``` actionscript
// Call a function when Space is pressed.
if (Input.pressed(Key.Space)) {
  spacebar();
}
```

### Built-in Debugging

Handy console for real-time debugging and information tracking. It even allows moving the camera and inspecting entities while playing!

``` actionscript
// Enable the debugger and watch the player's speed.
FP.console.enable();
FP.console.watch(player.speed);
```

Community
---------

If all this just isn't enough and you absolutely require a team of berets and neckbeards, the [FlashPunk Developers community](http://developers.useflashpunk.net) is an incredible resource eager to answer any question you can fathom. Oh, and its free as well.
