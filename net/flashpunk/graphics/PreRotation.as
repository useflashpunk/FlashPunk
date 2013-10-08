package net.flashpunk.graphics 
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import net.flashpunk.FP;

	/**
	 * Creates a pre-rotated Image strip to increase runtime performance for rotating graphics.
	 */
	public class PreRotation extends Image
	{
		/**
		 * Current angle to fetch the pre-rotated frame from.
		 */
		public var frameAngle:Number = 0;
		
		/**
		 * Constructor.
		 * @param	source			The source image to be rotated.
		 * @param	frameCount		How many frames to use. More frames result in smoother rotations.
		 * @param	smooth			Make the rotated graphic appear less pixelly.
		 */
		public function PreRotation(source:*, frameCount:uint = 36, smooth:Boolean = false) 
		{
			var r:BitmapData = _rotated[source];
			_frame = new Rectangle(0, 0, _size[source], _size[source]);
			if (!r)
			{
				// produce a rotated bitmap strip
				var temp:BitmapData = (source is BitmapData) ? source : (new source).bitmapData,
					size:uint = _size[source] = Math.ceil(FP.distance(0, 0, temp.width, temp.height));
				_frame.width = _frame.height = size;
				var width:uint = _frame.width * frameCount,
					height:uint = _frame.height;
				if (width > _MAX_WIDTH)
				{
					width = _MAX_WIDTH - (_MAX_WIDTH % _frame.width);
					height = Math.ceil(frameCount / (width / _frame.width)) * _frame.height;
				}
				_rotated[source] = r = new BitmapData(width, height, true, 0);
				var m:Matrix = FP.matrix,
					a:Number = 0,
					aa:Number = (Math.PI * 2) / -frameCount,
					ox:uint = temp.width / 2,
					oy:uint = temp.height / 2,
					o:uint = _frame.width / 2,
					x:uint = 0,
					y:uint = 0;
				_sourceWidth = temp.width;
				_sourceHeight = temp.height;
				while (y < height)
				{
					while (x < width)
					{
						m.identity();
						m.translate(-ox, -oy);
						m.rotate(a);
						m.translate(o + x, o + y);
						r.draw(temp, m, null, null, null, smooth);
						x += _frame.width;
						a += aa;
					}
					x = 0;
					y += _frame.height;
				}
			}
			_source = r;
			_width = r.width;
			_frameCount = frameCount;
			super(_source, _frame);
		}
		
		/** @private Renders the PreRotated graphic. */
		override public function render(target:BitmapData, point:Point, camera:Point):void 
		{
			frameAngle %= 360;
			if (frameAngle < 0) frameAngle += 360;
			_current = uint(_frameCount * (frameAngle / 360));
			if (_last != _current)
			{
				_last = _current;
				_frame.x = _frame.width * _last;
				_frame.y = uint(_frame.x / _width) * _frame.height;
				_frame.x %= _width;
				updateBuffer();
			}
			
			// If the origin has changed then we need to recalculate
			if (_prevOriginX !== originX || _prevOriginY !== originY) {
				_prevOriginX = originX; _prevOriginY = originY;
				recalcOriginOffsets();
			}
			
			// Set the origins for the `Image` to use
			originX = _frameOrigins[_current].x;
			originY = _frameOrigins[_current].y;
			
			// Render
			super.render(target, point, camera);
			
			// Change them back
			originX = _prevOriginX;
			originY = _prevOriginY;
		}
		
		/** @private Recalculates the offsets for each frame. */
		private function recalcOriginOffsets():void
		{
			var i:int;
			if (_frameOrigins === null) {
				_frameOrigins = new Vector.<Point>();
				for (i = 0; i < _frameCount; i++) {
					_frameOrigins.push(null);
				}
			}
			var angle:Number = 0, deltaAngle:Number = (Math.PI * 2) / -_frameCount;
			var m:Matrix = FP.matrix, p:Point = FP.point;
			p.x = _frame.width * 0.5 - _sourceWidth * 0.5 + originX - _frame.width * 0.5;
			p.y = _frame.height * 0.5 - _sourceHeight * 0.5 + originY - _frame.height * 0.5;
			for (i = 0; i < _frameCount; i++) {
				m.identity();
				m.rotate(angle);
				m.translate(_frame.width * 0.5, _frame.height * 0.5);
				
				_frameOrigins[i] = m.transformPoint(p);
				angle += deltaAngle;
			}
		}
		
		override public function centerOrigin():void {
			originX = _sourceWidth * 0.5;
			originY = _sourceHeight * 0.5;
		}
		
		// Rotation information.
		/** @private */ private var _width:uint;
		/** @private */ private var _frame:Rectangle;
		/** @private */ private var _frameCount:uint;
		/** @private */ private var _last:int = -1;
		/** @private */ private var _current:int = -1;
		/** @private */ private var _sourceWidth:Number, _sourceHeight:Number;
		/** @private */ private var _prevOriginX:Number = Number.POSITIVE_INFINITY, _prevOriginY:Number = Number.POSITIVE_INFINITY;
		/** @private */ private var _frameOrigins:Vector.<Point> = null;
		
		// Global information.
		/** @private */ private static var _rotated:Dictionary = new Dictionary;
		/** @private */ private static var _size:Dictionary = new Dictionary;
		/** @private */ private static const _MAX_WIDTH:uint = 4000;

	}
}
