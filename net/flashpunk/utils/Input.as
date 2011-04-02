package net.flashpunk.utils
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import net.flashpunk.*;
	
	/**
	 * Static class updated by Engine. Use for defining and checking keyboard/mouse input.
	 */
	public class Input
	{
		/**
		 * An updated string containing the last 100 characters pressed on the keyboard.
		 * Useful for creating text input fields, such as highscore entries, etc.
		 */
		public static var keyString:String = "";
		
		/**
		 * The last key pressed.
		 */
		public static var lastKey:int;
		
		/**
		 * The mouse cursor. Set to "hide" to hide the cursor.
		 */
		public static var mouseCursor:String;
		
		/**
		 * If the mouse button is down.
		 */
		public static var mouseDown:Boolean = false;
		
		/**
		 * If the mouse button is up.
		 */
		public static var mouseUp:Boolean = true;
		
		/**
		 * If the mouse button was pressed this frame.
		 */
		public static var mousePressed:Boolean = false;
		
		/**
		 * If the mouse button was released this frame.
		 */
		public static var mouseReleased:Boolean = false;
		
		/**
		 * If the mouse wheel was moved this frame.
		 */
		public static var mouseWheel:Boolean = false; 
		
		/**
		 * If the mouse wheel was moved this frame, this was the delta.
		 */
		public static function get mouseWheelDelta():int
		{
			if (mouseWheel)
			{
				mouseWheel = false;
				return _mouseWheelDelta;
			}
			return 0;
		}  
		
		/**
		 * X position of the mouse on the screen.
		 */
		public static function get mouseX():int
		{
			return FP.screen.mouseX;
		}
		
		/**
		 * Y position of the mouse on the screen.
		 */
		public static function get mouseY():int
		{
			return FP.screen.mouseY;
		}
		
		/**
		 * The absolute mouse x position on the screen (unscaled).
		 */
		public static function get mouseFlashX():int
		{
			return FP.stage.mouseX;
		}
		
		/**
		 * The absolute mouse y position on the screen (unscaled).
		 */
		public static function get mouseFlashY():int
		{
			return FP.stage.mouseY;
		}
		
		/**
		 * Defines a new input.
		 * @param	name		String to map the input to.
		 * @param	...keys		The keys to use for the Input.
		 */
		public static function define(name:String, ...keys):void
		{
			_control[name] = Vector.<int>(keys);
		}
		
		/**
		 * If the input or key is held down.
		 * @param	input		An input name or key to check for.
		 * @return	True or false.
		 */
		public static function check(input:*):Boolean
		{
			if (input is String)
			{
				var v:Vector.<int> = _control[input],
					i:int = v.length;
				while (i --)
				{
					if (v[i] < 0)
					{
						if (_keyNum > 0) return true;
						continue;
					}
					if (_key[v[i]]) return true;
				}
				return false;
			}
			return input < 0 ? _keyNum > 0 : _key[input];
		}
		
		/**
		 * If the input or key was pressed this frame.
		 * @param	input		An input name or key to check for.
		 * @return	True or false.
		 */
		public static function pressed(input:*):Boolean
		{
			if (input is String)
			{
				var v:Vector.<int> = _control[input],
					i:int = v.length;
				while (i --)
				{
					if ((v[i] < 0) ? _pressNum : _press.indexOf(v[i]) >= 0) return true;
				}
				return false;
			}
			return (input < 0) ? _pressNum : _press.indexOf(input) >= 0;
		}
		
		/**
		 * If the input or key was released this frame.
		 * @param	input		An input name or key to check for.
		 * @return	True or false.
		 */
		public static function released(input:*):Boolean
		{
			if (input is String)
			{
				var v:Vector.<int> = _control[input],
					i:int = v.length;
				while (i --)
				{
					if ((v[i] < 0) ? _releaseNum : _release.indexOf(v[i]) >= 0) return true;
				}
				return false;
			}
			return (input < 0) ? _releaseNum : _release.indexOf(input) >= 0;
		}
		
		/**
		 * Returns the keys mapped to the input name.
		 * @param	name		The input name.
		 * @return	A Vector of keys.
		 */
		public static function keys(name:String):Vector.<int>
		{
			return _control[name] as Vector.<int>;
		}
		
		/** @private Called by Engine to enable keyboard input on the stage. */
		public static function enable():void
		{
			if (!_enabled && FP.stage)
			{
				FP.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				FP.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				FP.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				FP.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				FP.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
				_enabled = true;
			}
		}
		
		/** @private Called by Engine to update the input. */
		public static function update():void
		{
			while (_pressNum --) _press[_pressNum] = -1;
			_pressNum = 0;
			while (_releaseNum --) _release[_releaseNum] = -1;
			_releaseNum = 0;
			if (mousePressed) mousePressed = false;
			if (mouseReleased) mouseReleased = false;
			
			if (mouseCursor) {
				if (mouseCursor == "hide") {
					Mouse.hide();
					Mouse.cursor = "auto";
				} else {
					Mouse.show();
					Mouse.cursor = mouseCursor;
				}
			}
		}
		
		/**
		 * Clears all input states.
		 */
		public static function clear():void
		{
			_press.length = _pressNum = 0;
			_release.length = _releaseNum = 0;
			var i:int = _key.length;
			while (i --) _key[i] = false;
			_keyNum = 0;
		}
		
		/** @private Event handler for key press. */
		private static function onKeyDown(e:KeyboardEvent = null):void
		{
			// get the keycode
			var code:int = lastKey = e.keyCode;
			
			// update the keystring
			if (code == Key.BACKSPACE) keyString = keyString.substring(0, keyString.length - 1);
			else if (e.charCode > 31 && e.charCode != 127) // 127 is delete
			{
				if (keyString.length > KEYSTRING_MAX) keyString = keyString.substring(1);
				keyString += String.fromCharCode(e.charCode);
			}
			
			if (code < 0 || code > 255) return;
			
			// update the keystate
			if (!_key[code])
			{
				_key[code] = true;
				_keyNum ++;
				_press[_pressNum ++] = code;
			}
		}
		
		/** @private Event handler for key release. */
		private static function onKeyUp(e:KeyboardEvent):void
		{
			// get the keycode and update the keystate
			var code:int = e.keyCode;
			
			if (code < 0 || code > 255) return;
			
			if (_key[code])
			{
				_key[code] = false;
				_keyNum --;
				_release[_releaseNum ++] = code;
			}
		}
		
		/** @private Event handler for mouse press. */
		private static function onMouseDown(e:MouseEvent):void
		{
			if (!mouseDown)
			{
				mouseDown = true;
				mouseUp = false;
				mousePressed = true;
			}
		}
		
		/** @private Event handler for mouse release. */
		private static function onMouseUp(e:MouseEvent):void
		{
			mouseDown = false;
			mouseUp = true;
			mouseReleased = true;
		}
		
		/** @private Event handler for mouse wheel events */
		private static function onMouseWheel(e:MouseEvent):void
		{
		    mouseWheel = true;
		    _mouseWheelDelta = e.delta;
		}
		
		// Max amount of characters stored by the keystring.
		/** @private */ private static const KEYSTRING_MAX:uint = 100;
		
		// Input information.
		/** @private */ private static var _enabled:Boolean = false;
		/** @private */ private static var _key:Vector.<Boolean> = new Vector.<Boolean>(256);
		/** @private */ private static var _keyNum:int = 0;
		/** @private */ private static var _press:Vector.<int> = new Vector.<int>(256);
		/** @private */ private static var _release:Vector.<int> = new Vector.<int>(256);
		/** @private */ private static var _pressNum:int = 0;
		/** @private */ private static var _releaseNum:int = 0;
		/** @private */ private static var _control:Object = {};
		/** @private */ private static var _mouseWheelDelta:int = 0;
	}
}
