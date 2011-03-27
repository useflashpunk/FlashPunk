package net.flashpunk.graphics 
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.SpreadMethod;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.flashpunk.FP;
	
	/**
	 * Performance-optimized animated Image. Can have multiple animations,
	 * which draw frames from the provided source image to the screen.
	 */
	public class Spritemap extends Image
	{
		/**
		 * If the animation has stopped.
		 */
		public var complete:Boolean = true;
		
		/**
		 * Optional callback function for animation end.
		 */
		public var callback:Function;
		
		/**
		 * Animation speed factor, alter this to speed up/slow down all animations.
		 */
		public var rate:Number = 1;
		
		/**
		 * Constructor.
		 * @param	source			Source image.
		 * @param	frameWidth		Frame width.
		 * @param	frameHeight		Frame height.
		 * @param	callback		Optional callback function for animation end.
		 */
		public function Spritemap(source:*, frameWidth:uint = 0, frameHeight:uint = 0, callback:Function = null) 
		{
			_rect = new Rectangle(0, 0, frameWidth, frameHeight);
			super(source, _rect);
			if (!frameWidth) _rect.width = this.source.width;
			if (!frameHeight) _rect.height = this.source.height;
			_width = this.source.width;
			_height = this.source.height;
			_columns = _width / _rect.width;
			_rows = _height / _rect.height;
			_frameCount = _columns * _rows;
			this.callback = callback;
			updateBuffer();
			active = true;
		}
		
		/**
		 * Updates the spritemap's buffer.
		 */
		override public function updateBuffer(clearBefore:Boolean = false):void 
		{
			// get position of the current frame
			_rect.x = _rect.width * _frame;
			_rect.y = uint(_rect.x / _width) * _rect.height;
			_rect.x %= _width;
			if (_flipped) _rect.x = (_width - _rect.width) - _rect.x;
			
			// update the buffer
			super.updateBuffer(clearBefore);
		}
		
		/** @private Updates the animation. */
		override public function update():void 
		{
			if (_anim && !complete)
			{
				_timer += (FP.fixed ? _anim._frameRate : _anim._frameRate * FP.elapsed) * rate;
				if (_timer >= 1)
				{
					while (_timer >= 1)
					{
						_timer --;
						_index ++;
						if (_index == _anim._frameCount)
						{
							if (_anim._loop)
							{
								_index = 0;
								if (callback != null) callback();
							}
							else
							{
								_index = _anim._frameCount - 1;
								complete = true;
								if (callback != null) callback();
								break;
							}
						}
					}
					if (_anim) _frame = uint(_anim._frames[_index]);
					updateBuffer();
				}
			}
		}
		
		/**
		 * Add an Animation.
		 * @param	name		Name of the animation.
		 * @param	frames		Array of frame indices to animate through.
		 * @param	frameRate	Animation speed.
		 * @param	loop		If the animation should loop.
		 * @return	A new Anim object for the animation.
		 */
		public function add(name:String, frames:Array, frameRate:Number = 0, loop:Boolean = true):Anim
		{
			if (_anims[name]) throw new Error("Cannot have multiple animations with the same name");
			(_anims[name] = new Anim(name, frames, frameRate, loop))._parent = this;
			return _anims[name];
		}
		
		/**
		 * Plays an animation.
		 * @param	name		Name of the animation to play.
		 * @param	reset		If the animation should force-restart if it is already playing.
		 * @return	Anim object representing the played animation.
		 */
		public function play(name:String = "", reset:Boolean = false):Anim
		{
			if (!reset && _anim && _anim._name == name) return _anim;
			_anim = _anims[name];
			if (!_anim)
			{
				_frame = _index = 0;
				complete = true;
				updateBuffer();
				return null;
			}
			_index = 0;
			_timer = 0;
			_frame = uint(_anim._frames[0]);
			complete = false;
			updateBuffer();
			return _anim;
		}
		
		/**
		 * Gets the frame index based on the column and row of the source image.
		 * @param	column		Frame column.
		 * @param	row			Frame row.
		 * @return	Frame index.
		 */
		public function getFrame(column:uint = 0, row:uint = 0):uint
		{
			return (row % _rows) * _columns + (column % _columns);
		}
		
		/**
		 * Sets the current display frame based on the column and row of the source image.
		 * When you set the frame, any animations playing will be stopped to force the frame.
		 * @param	column		Frame column.
		 * @param	row			Frame row.
		 */
		public function setFrame(column:uint = 0, row:uint = 0):void
		{
			_anim = null;
			var frame:uint = (row % _rows) * _columns + (column % _columns);
			if (_frame == frame) return;
			_frame = frame;
			updateBuffer();
		}
		
		/**
		 * Assigns the Spritemap to a random frame.
		 */
		public function randFrame():void
		{
			frame = FP.rand(_frameCount);
		}
		
		/**
		 * Sets the frame to the frame index of an animation.
		 * @param	name	Animation to draw the frame frame.
		 * @param	index	Index of the frame of the animation to set to.
		 */
		public function setAnimFrame(name:String, index:int):void
		{
			var frames:Array = _anims[name]._frames;
			index %= frames.length;
			if (index < 0) index += frames.length;
			frame = frames[index];
		}
		
		/**
		 * Sets the current frame index. When you set this, any
		 * animations playing will be stopped to force the frame.
		 */
		public function get frame():int { return _frame; }
		public function set frame(value:int):void
		{
			_anim = null;
			value %= _frameCount;
			if (value < 0) value = _frameCount + value;
			if (_frame == value) return;
			_frame = value;
			updateBuffer();
		}
		
		/**
		 * Current index of the playing animation.
		 */
		public function get index():uint { return _anim ? _index : 0; }
		public function set index(value:uint):void
		{
			if (!_anim) return;
			value %= _anim._frameCount;
			if (_index == value) return;
			_index = value;
			_frame = uint(_anim._frames[_index]);
			updateBuffer();
		}
		
		/**
		 * The amount of frames in the Spritemap.
		 */
		public function get frameCount():uint { return _frameCount; }
		
		/**
		 * Columns in the Spritemap.
		 */
		public function get columns():uint { return _columns; }
		
		/**
		 * Rows in the Spritemap.
		 */
		public function get rows():uint { return _rows; }
		
		/**
		 * The currently playing animation.
		 */
		public function get currentAnim():String { return _anim ? _anim._name : ""; }
		
		// Spritemap information.
		/** @private */ protected var _rect:Rectangle;
		/** @private */ protected var _width:uint;
		/** @private */ protected var _height:uint;
		/** @private */ private var _columns:uint;
		/** @private */ private var _rows:uint;
		/** @private */ private var _frameCount:uint;
		/** @private */ private var _anims:Object = { };
		/** @private */ private var _anim:Anim;
		/** @private */ private var _index:uint;
		/** @private */ protected var _frame:uint;
		/** @private */ private var _timer:Number = 0;
	}
}