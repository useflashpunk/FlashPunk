package net.flashpunk
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import net.flashpunk.utils.Draw;
	import net.flashpunk.utils.Input;
	
	/**
	 * Main game Sprite class, added to the Flash Stage. Manages the game loop.
	 */
	public class Engine extends MovieClip
	{
		/**
		 * Constructor. Defines startup information about your game.
		 * @param	width			The width of your game.
		 * @param	height			The height of your game.
		 * @param	frameRate		The game framerate, in frames per second.
		 * @param	fixed			If a fixed-framerate should be used.
		 */
		public function Engine(width:uint, height:uint, frameRate:Number = 60, fixed:Boolean = false) 
		{
			// global game properties
			FP.width = width;
			FP.height = height;
			FP.frameRate = frameRate;
			FP.fixed = fixed;
			
			// global game objects
			FP.engine = this;
			FP.screen = new Screen;
			FP.bounds = new Rectangle(0, 0, width, height);
			FP._world = new World;
			
			// miscellanious startup stuff
			if (FP.randomSeed == 0) FP.randomizeSeed();
			FP.entity = new Entity;
			FP.cleanup();
			
			// on-stage event listener
			addEventListener(Event.ADDED_TO_STAGE, onStage);
		}
		
		/**
		 * Override this, called after Engine has been added to the stage.
		 */
		public function init():void
		{
			
		}
		
		/**
		 * Updates the game, updating the World and Entities.
		 */
		public function update():void
		{
			if (FP._world.active)
			{
				if (FP._world._tween) FP._world.updateTweens();
				FP._world.update();
			}
		}
		
		/**
		 * Renders the game, rendering the World and Entities.
		 */
		public function render():void
		{
			FP.screen.refresh();
			if (FP._world.visible) FP._world.render();
		}
		
		/** @private Event handler for stage entry. */
		private function onStage(e:Event = null):void
		{
			// remove event listener
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			
			// set stage properties
			FP.stage = stage;
			stage.frameRate = FP.frameRate;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.HIGH;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.displayState = StageDisplayState.NORMAL;
			
			// enable input
			Input.enable();
			
			// switch worlds
			if (FP._goto) switchWorld();
			
			// game start
			init();
			
			// start game loop
			if (FP.fixed)
			{
				// fixed framerate
				_rate = 1000 / FP.frameRate;
				_skip = _rate * MAX_FRAMESKIP;
				_last = _prev = getTimer();
				_timer = new Timer(TICK_RATE);
				_timer.addEventListener(TimerEvent.TIMER, onTimer);
				_timer.start();
			}
			else
			{
				// nonfixed framerate
				_last = getTimer();
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		/** @private Framerate independent game loop. */
		private function onEnterFrame(e:Event):void
		{
			// update timer
			_time = getTimer();
			FP.elapsed = (_time - _last) / 1000;
			_last = _time;
			
			// apply timescale
			if (FP.elapsed > MAX_ELAPSED) FP.elapsed = MAX_ELAPSED;
			FP.elapsed *= FP.rate;
			
			// swap buffers
			FP.screen.swap();
			
			// update loop
			update();
			
			// update entity lists
			FP._world.updateLists();
			
			// update input
			Input.update();
			
			// reset drawing target
			Draw.resetTarget();
			
			// render loop
			render();
			
			// redraw buffers
			FP.screen.redraw();
			
			// switch worlds
			if (FP._goto) switchWorld();
		}
		
		/** @private Fixed framerate game loop. */
		private function onTimer(e:TimerEvent):void
		{
			// update timer
			_time = getTimer();
			_delta += (_time - _last);
			_last = _time;
			
			// quit if a frame hasn't passed
			if (_delta < _rate) return;
			
			// swap buffers
			FP.screen.swap();
			
			// update the game
			if (_delta > _skip) _delta = _skip;
			while (_delta > _rate)
			{
				// update timer
				_delta -= _rate;
				_time = getTimer();
				FP.elapsed = (_time - _prev) / 1000;
				_prev = _time;
				
				// apply timescale
				if (FP.elapsed > MAX_ELAPSED) FP.elapsed = MAX_ELAPSED;
				FP.elapsed *= FP.rate;
				
				// update loop
				update();
				
				// update entity lists
				FP._world.updateLists();
				
				// update input
				Input.update();
			}
			
			// reset drawing target
			Draw.resetTarget();
			
			// render loop
			render();
			
			// redraw buffers
			FP.screen.redraw();
			
			// switch worlds
			if (FP._goto) switchWorld();
		}
		
		/** @private Switch Worlds if they've changed. */
		private function switchWorld():void
		{
			if (!FP._goto) return;
			FP._world.end();
			if (FP._world)
			{
				if (FP._world.autoClear && FP._world._tween) FP._world.clearTweens();
				if (FP._goto._inherit) FP._goto.inherit(FP._world, FP._goto._inheritAll);
			}
			FP._world = FP._goto;
			FP._goto = null;
			FP._world.begin();
			FP.cleanup();
		}
		
		// Timing information.
		/** @private */ private var _delta:Number = 0;
		/** @private */ private var _time:Number;
		/** @private */ private var _last:Number;
		/** @private */ private var _timer:Timer;
		/** @private */ private var	_rate:Number;
		/** @private */ private var	_skip:Number;
		/** @private */ private var _prev:Number;
		
		// Game constants.
		/** @private */ private const MAX_ELAPSED:Number = 0.0333;
		/** @private */ private const MAX_FRAMESKIP:Number = 5;
		/** @private */ private const TICK_RATE:uint = 4;
	}
}