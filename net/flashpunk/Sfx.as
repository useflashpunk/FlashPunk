package net.flashpunk 
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	
	/**
	 * Sound effect object used to play embedded sounds.
	 */
	public class Sfx 
	{
		/**
		 * Optional callback function for when the sound finishes playing.
		 */
		public var complete:Function;
		
		/**
		 * Creates a sound effect from an embedded source. Store a reference to
		 * this object so that you can play the sound using play() or loop().
		 * @param	source		The embedded sound class to use.
		 * @param	complete	Optional callback function for when the sound finishes playing.
		 */
		public function Sfx(source:Class, complete:Function = null) 
		{
			_sound = _sounds[source];
			if (!_sound) _sound = _sounds[source] = new source;
			this.complete = complete;
		}
		
		/**
		 * Plays the sound once.
		 * @param	vol		Volume factor, a value from 0 to 1.
		 * @param	pan		Panning factor, a value from -1 to 1.
		 */
		public function play(vol:Number = 1, pan:Number = 0):void
		{
			if (_channel) stop();
			_vol = _transform.volume = vol < 0 ? 0 : vol;
			_pan = _transform.pan = pan < -1 ? -1 : (pan > 1 ? 1 : pan);
			_channel = _sound.play(0, 0, _transform);
			_channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
			_looping = false;
			_position = 0;
		}
		
		/**
		 * Plays the sound looping. Will loop continuously until you call stop(), play(), or loop() again.
		 * @param	vol		Volume factor, a value from 0 to 1.
		 * @param	pan		Panning factor, a value from -1 to 1.
		 */
		public function loop(vol:Number = 1, pan:Number = 0):void
		{
			play(vol, pan);
			_looping = true;
		}
		
		/**
		 * Stops the sound if it is currently playing.
		 * @return
		 */
		public function stop():Boolean
		{
			if (!_channel) return false;
			_position = _channel.position;
			_channel.removeEventListener(Event.SOUND_COMPLETE, onComplete);
			_channel.stop();
			_channel = null;
			return true;
		}
		
		/**
		 * Resumes the sound from the position stop() was called on it.
		 */
		public function resume():void
		{
			_channel = _sound.play(_position, 0, _transform);
			_channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
			_position = 0;
		}
		
		/** @private Event handler for sound completion. */
		private function onComplete(e:Event = null):void
		{
			if (_looping) loop(_vol, _pan);
			else stop();
			_position = 0;
			if (complete != null) complete();
		}
		
		/**
		 * Alter the volume factor (a value from 0 to 1) of the sound during playback.
		 */
		public function get volume():Number { return _vol; }
		public function set volume(value:Number):void
		{
			if (value < 0) value = 0;
			if (!_channel || _vol == value) return;
			_vol = _transform.volume = value;
			_channel.soundTransform = _transform;
		}
		
		/**
		 * Alter the panning factor (a value from -1 to 1) of the sound during playback.
		 */
		public function get pan():Number { return _pan; }
		public function set pan(value:Number):void
		{
			if (value < -1) value = -1;
			if (value > 1) value = 1;
			if (!_channel || _pan == value) return;
			_pan = _transform.pan = value;
			_channel.soundTransform = _transform;
		}
		
		/**
		 * If the sound is currently playing.
		 */
		public function get playing():Boolean { return _channel != null; }
		
		/**
		 * Position of the currently playing sound, in seconds.
		 */
		public function get position():Number { return (_channel ? _channel.position : _position) / 1000; }
		
		/**
		 * Length of the sound, in seconds.
		 */
		public function get length():Number { return _sound.length / 1000; }
		
		// Sound infromation.
		/** @private */ private var _vol:Number = 1;
		/** @private */ private var _pan:Number = 0;
		/** @private */ private var _sound:Sound;
		/** @private */ private var _channel:SoundChannel;
		/** @private */ private var _transform:SoundTransform = new SoundTransform;
		/** @private */ private var _position:Number = 0;
		/** @private */ private var _looping:Boolean;
		
		// Stored Sound objects.
		/** @private */ private static var _sounds:Dictionary = new Dictionary;
	}
}