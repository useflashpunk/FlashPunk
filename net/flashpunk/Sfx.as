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
		 * @param	source		The embedded sound class to use or a Sound object.
		 * @param	complete	Optional callback function for when the sound finishes playing.
		 */
		public function Sfx(source:*, complete:Function = null, type:String = null) 
		{
			_type = type;
			if (source is Class)
			{
				_sound = _sounds[source];
				if (!_sound) _sound = _sounds[source] = new source;
			}
			else if (source is Sound) _sound = source;
			else throw new Error("Sfx source needs to be of type Class or Sound");
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
			_pan = FP.clamp(pan, -1, 1);
			_vol = vol < 0 ? 0 : vol;
			_filteredPan = FP.clamp(_pan + getPan(_type), -1, 1);
			_filteredVol = Math.max(0, _vol * getVolume(_type));
			_transform.pan = _filteredPan;
			_transform.volume = _filteredVol;
			_channel = _sound.play(0, 0, _transform);
			if (_channel)
			{
				addPlaying();
				_channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
			}
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
			removePlaying();
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
			if (_channel)
			{
				addPlaying();
				_channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
			}
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
		
		/** @private Add the sound to the global list. */
		private function addPlaying():void
		{
			if (!_typePlaying[_type]) _typePlaying[_type] = new Dictionary()
			_typePlaying[_type][this] = this;
		}
		
		/** @private Remove the sound from the global list. */
		private function removePlaying():void
		{
			if (_typePlaying[_type]) delete _typePlaying[_type][this];
		}
		
		/**
		 * Alter the volume factor (a value from 0 to 1) of the sound during playback.
		 */
		public function get volume():Number { return _vol; }
		public function set volume(value:Number):void
		{
			if (!_channel) return;
			if (value < 0) value = 0;
			var filteredVol:Number = value * getVolume(_type);
			if (filteredVol < 0) filteredVol = 0;
			if (_filteredVol === filteredVol) return;
			_vol = value;
			_filteredVol = _transform.volume = filteredVol;
			_channel.soundTransform = _transform;
		}
		
		/**
		 * Alter the panning factor (a value from -1 to 1) of the sound during playback.
		 */
		public function get pan():Number { return _pan; }
		public function set pan(value:Number):void
		{
			if (!_channel) return;
			value = FP.clamp(value, -1, 1);
			var filteredPan:Number = FP.clamp(value + getPan(_type), -1, 1);
			if (_filteredPan === filteredPan) return;
			_pan = value;
			_filteredPan = _transform.pan = filteredPan;
			_channel.soundTransform = _transform;
		}
		
		/**
		* Change the sound type. This an arbitrary string you can use to group
		* sounds to mute or pan en masse.
		*/
		public function get type():String { return _type; }
		public function set type(value:String):void
		{
			if (_type == value) return;
			if (_channel)
			{
				removePlaying();
				_type = value;
				addPlaying();
				// reset, in case type has different global settings
				pan = pan;
				volume = volume;
			}
			else
			{
				_type = value;
			}
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
		
		/**
		* Return the global pan for a type.
		*/
		static public function getPan(type:String):Number
		{
			var transform:SoundTransform = _typeTransforms[type];
			return transform ? transform.pan : 0;
		}
		
		/**
		* Return the global volume for a type.
		*/
		static public function getVolume(type:String):Number
		{
			var transform:SoundTransform = _typeTransforms[type];
			return transform ? transform.volume : 1;
		}
		
		/**
		* Set the global pan for a type. Sfx instances of this type will add
		* this pan to their own.
		*/
		static public function setPan(type:String, pan:Number):void
		{
			var transform:SoundTransform = _typeTransforms[type];
			if (!transform) transform = _typeTransforms[type] = new SoundTransform();
			transform.pan = FP.clamp(pan, -1, 1);
			for each (var sfx:Sfx in _typePlaying[type])
			{
				sfx.pan = sfx.pan;
			}
		}
		
		/**
		* Set the global volume for a type. Sfx instances of this type will
		* multiply their volume by this value.
		*/
		static public function setVolume(type:String, volume:Number):void
		{
			var transform:SoundTransform = _typeTransforms[type];
			if (!transform) transform = _typeTransforms[type] = new SoundTransform();
			transform.volume = volume < 0 ? 0 : volume;
			for each (var sfx:Sfx in _typePlaying[type])
			{
				sfx.volume = sfx.volume;
			}
		}
		
		// Sound information.
		/** @private */ private var _type:String;
		/** @private */ private var _vol:Number = 1;
		/** @private */ private var _pan:Number = 0;
		/** @private */ private var _filteredVol:Number;
		/** @private */ private var _filteredPan:Number;
		/** @private */ private var _sound:Sound;
		/** @private */ private var _channel:SoundChannel;
		/** @private */ private var _transform:SoundTransform = new SoundTransform;
		/** @private */ private var _position:Number = 0;
		/** @private */ private var _looping:Boolean;
		
		// Stored Sound objects.
		/** @private */ private static var _sounds:Dictionary = new Dictionary;
		/** @private */ private static var _typePlaying:Dictionary = new Dictionary;
		/** @private */ private static var _typeTransforms:Dictionary = new Dictionary;
	}
}
