ABOUT
=====

FlashPunk is a free ActionScript 3 library designed for developing 2D Flash games. It provides you with a fast, clean framework to prototype and develop your games in. This means that most of the dirty work (timestep, animation, input, and collision to name a few) is already coded for you and ready to go, giving you more time and energy to concentrate on the design and testing of your game.

FEATURES
========

* Framerate-independent and fixed-framerate timestep support.
* Fast & manageable rectangle, pixel, and grid collision system.
* Helper classes for animations, tilemaps, text, backdrops, and more.
* Sound effect support with volume, panning, and fading/crossfading.
* Powerful motion tweening for linear, curved, and path-based movement.
* Z-sorted render lists for easy depth management.
* Simple keyboard and mouse input state checking.
* Quick & efficent particle effects and emitters.
* Handy console for real-time debugging and information tracking.

OVERVIEW
========

This is a quick overview of some of the features and how they've changed since FlashPunk's previous versions.

### TIMESTEPS
Support for both fixed-framerate and framerate-independent timesteps. Previously, FlashPunk used a fixed-framerate timestep decoupled from the drawing rate, meaning that if you set your game to run at 60 FPS, it would try to run at that rate constantly, and skip rendering frames occasionally if it was falling behind. Now, in Engine’s constructor, you can choose whether you want a fixed-framerate or not. If not, Flash Player will update using ENTER_FRAME using your frameRate as a target, and you can use FP’s elapsed property to determine how much time has passed since the last frame and use that to determine movement and timer rates, something that Flixel developers will be used to.

### GRAPHICS
The Actor and Acrobat classes from previous versions no longer exist, all your game objects will extend the Entity class, and what they draw to the screen will depend on what you assign their Graphic property to. FlashPunk provides a useful set of Graphic components for different uses, such as Image for still images (optionally transformed), Spritemap for animated sprite strips, or Emitter as an efficient particle emitter option.
Note that a Graphiclist type also exists, which can be assigned to an Entity and contain multiple different Graphic types, all which can have different offsets, transformations, and animations. This provides a useful system for multi-sprite objects in your game (for example: an overhead display object that contains multiple hearts and a powerup meter).

### COLLISION
Collision works largely the same, except has also been improved using a component system similar to graphics. All Entity objects still use a Hitbox rectangle as their default collision bounds, but you can assign a specialized Mask to an Entity for more advanced collision. For example, you can assign it a Pixelmask type for pixel-perfect collision, or a Grid type to determine a large area of solid/nonsolid grid cells. This latter type works well in combination with the Tilemap graphic type, allowing a single Entity object to possibly handle an entire scene’s collision and rendering. Using a single Grid mask for collision is significantly faster than using a bunch of invisible Entity objects’ hitboxes.

### TWEENING
One of FlashPunk’s more specific and powerful features are the new Tween classes. All Entities and Worlds can have any amount of Tweens added to it. Currently the Tweens are divided into 3 categories: motion, sound, and miscellaneous tweens. Motion tweens provide you with a powerful set of objects useful for planned motion. For example, if I wanted an Entity to move from one point to another, I could assign it a LinearMotion tween and have its position sync with that tween’s x and y position when it updates (an Entity’s tweens are updated immediately before the Entity’s update() function itself is called). Classes for curved (quadratic and cubic bezier), paths (linear paths and quadtratic paths), and circular motion are also provided. Tweens can be made even more effective when combined with Easing functions, allowing smooth transitions and other functionality.

### DEBUGGING
FlashPunk now has a console which lets you view lots of useful information in real-time, such as FPS, frame timing info, Entity count, and user-logged information. The user can select Entities and move them around while the console is paused, pan the camera, and also view user-specified properties for each Entity in the debug panel.

### AND MORE...
There are also many other various changes and improvements across the board, all which I cannot list off the top of my head. Suffice to say, version 0.87 has a total of 16 different classes, and the new version has over 40. FlashPunk is still simple to use and prototype in, but with version 1.0 onward, I aim to make it not only effectively simple and fast, but contain powerful and efficent internal systems for those who know how to use them.