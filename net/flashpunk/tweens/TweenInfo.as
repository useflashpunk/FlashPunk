package net.flashpunk.tweens 
{
	public class TweenInfo
	{
		public var object:Object;
		public var elapsed:Number;
		public var duration:Number;
		public var start:Object = { };
		public var range:Object = { };
		public var complete:Function;
		public var ease:Function;
		
		public function init(object:Object, duration:Number, values:Object, complete:Function, ease:Function):TweenInfo
		{
			elapsed = 0;
			this.object = object;
			this.duration = duration;
			this.complete = complete;
			this.ease = ease;
			for (i in start) delete start[i];
			for (i in range) delete range[i];
			for (var i:String in values)
			{
				start[i] = object[i];
				range[i] = values[i] - start[i];
			}
			return this;
		}
		
		public function destroy():void
		{
			_cache.push(this);
			object = complete = ease = null;
		}
		
		public static function create(object:Object, duration:Number, values:Object, complete:Function, ease:Function):TweenInfo
		{
			var t:TweenInfo = _cache.length ? _cache.pop() : new TweenInfo;
			return t.init(object, duration, values, complete, ease);
		}
		
		private static var _cache:Vector.<TweenInfo> = new Vector.<TweenInfo>;
	}
}