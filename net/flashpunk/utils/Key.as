package net.flashpunk.utils 
{
	/**
	 * Contains static key constants to be used by Input.
	 */
	public class Key 
	{
		public static const ANY:int = -1;
		
		public static const LEFT:int = 37;
		public static const UP:int = 38;
		public static const RIGHT:int = 39;
		public static const DOWN:int = 40;
		
		public static const ENTER:int = 13;
		public static const CONTROL:int = 17;
		public static const SPACE:int = 32;
		public static const SHIFT:int = 16;
		public static const BACKSPACE:int = 8;
		public static const CAPS_LOCK:int = 20;
		public static const DELETE:int = 46;
		public static const END:int = 35;
		public static const ESCAPE:int = 27;
		public static const HOME:int = 36;
		public static const INSERT:int = 45;
		public static const TAB:int = 9;
		public static const PAGE_DOWN:int = 34;
		public static const PAGE_UP:int = 33;
		
		public static const A:int = 65;
		public static const B:int = 66;
		public static const C:int = 67;
		public static const D:int = 68;
		public static const E:int = 69;
		public static const F:int = 70;
		public static const G:int = 71;
		public static const H:int = 72;
		public static const I:int = 73;
		public static const J:int = 74;
		public static const K:int = 75;
		public static const L:int = 76;
		public static const M:int = 77;
		public static const N:int = 78;
		public static const O:int = 79;
		public static const P:int = 80;
		public static const Q:int = 81;
		public static const R:int = 82;
		public static const S:int = 83;
		public static const T:int = 84;
		public static const U:int = 85;
		public static const V:int = 86;
		public static const W:int = 87;
		public static const X:int = 88;
		public static const Y:int = 89;
		public static const Z:int = 90;
		
		public static const F1:int = 112;
		public static const F2:int = 113;
		public static const F3:int = 114;
		public static const F4:int = 115;
		public static const F5:int = 116;
		public static const F6:int = 117;
		public static const F7:int = 118;
		public static const F8:int = 119;
		public static const F9:int = 120;
		public static const F10:int = 121;
		public static const F11:int = 122;
		public static const F12:int = 123;
		public static const F13:int = 124;
		public static const F14:int = 125;
		public static const F15:int = 126;
		
		public static const DIGIT_0:int = 48;
		public static const DIGIT_1:int = 49;
		public static const DIGIT_2:int = 50;
		public static const DIGIT_3:int = 51;
		public static const DIGIT_4:int = 52;
		public static const DIGIT_5:int = 53;
		public static const DIGIT_6:int = 54;
		public static const DIGIT_7:int = 55;
		public static const DIGIT_8:int = 56;
		public static const DIGIT_9:int = 57;
		
		public static const NUMPAD_0:int = 96;
		public static const NUMPAD_1:int = 97;
		public static const NUMPAD_2:int = 98;
		public static const NUMPAD_3:int = 99;
		public static const NUMPAD_4:int = 100;
		public static const NUMPAD_5:int = 101;
		public static const NUMPAD_6:int = 102;
		public static const NUMPAD_7:int = 103;
		public static const NUMPAD_8:int = 104;
		public static const NUMPAD_9:int = 105;
		public static const NUMPAD_ADD:int = 107;
		public static const NUMPAD_DECIMAL:int = 110;
		public static const NUMPAD_DIVIDE:int = 111;
		public static const NUMPAD_ENTER:int = 108;
		public static const NUMPAD_MULTIPLY:int = 106;
		public static const NUMPAD_SUBTRACT:int = 109;
		
		/**
		 * Returns the name of the key.
		 * @param	char		The key to name.
		 * @return	The name.
		 */
		public static function name(char:int):String
		{
			if (char >= A && char <= Z) return String.fromCharCode(char);
			if (char >= F1 && char <= F15) return "F" + String(char - 111);
			if (char >= 96 && char <= 105) return "NUMPAD " + String(char - 96);
			switch (char)
			{
				case LEFT:
				return "LEFT";
				
				case UP:
				return "UP";
				
				case RIGHT:
				return "RIGHT";
				
				case DOWN:
				return "DOWN";
				
				case ENTER:
				return "ENTER";
				
				case CONTROL:
				return "CONTROL";
				
				case SPACE:
				return "SPACE";
				
				case SHIFT:
				return "SHIFT";
				
				case BACKSPACE:
				return "BACKSPACE";
				
				case CAPS_LOCK:
				return "CAPS LOCK";
				
				case DELETE:
				return "DELETE";
				
				case END:
				return "END";
				
				case ESCAPE: 	
				return "ESCAPE";
				
				case HOME: 		
				return "HOME";
				
				case INSERT: 	
				return "INSERT";
				
				case TAB: 		
				return "TAB";
				
				case PAGE_DOWN:
				return "PAGE DOWN";
				
				case PAGE_UP: 	
				return "PAGE UP";
				
				case NUMPAD_ADD:		
				return "NUMPAD ADD";
				
				case NUMPAD_DECIMAL:	
				return "NUMPAD DECIMAL";
				
				case NUMPAD_DIVIDE:		
				return "NUMPAD DIVIDE";
				
				case NUMPAD_ENTER:		
				return "NUMPAD ENTER";
				
				case NUMPAD_MULTIPLY:	
				return "NUMPAD MULTIPLY";
				
				case NUMPAD_SUBTRACT:	
				return "NUMPAD SUBTRACT";
				
				default:
				return String.fromCharCode(char);
			}
			return String.fromCharCode(char);
		}
	}
}