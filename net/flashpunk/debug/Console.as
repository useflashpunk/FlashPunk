package net.flashpunk.debug
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;

	/**
	 * FlashPunk debug console; can use to log information or pause the game and view/move Entities and step the frame.
	 */
	public class Console
	{
		/**
		 * The key used to toggle the Console on/off. Tilde (~) by default.
		 */
		public var toggleKey:uint = 192;
		
		/**
		 * Constructor.
		 */
		public function Console() 
		{
			Input.define("_ARROWS", Key.RIGHT, Key.LEFT, Key.DOWN, Key.UP);
		}
		
		/**
		 * Logs data to the console.
		 * @param	data		The data parameters to log, can be variables, objects, etc. Parameters will be separated by a space (" ").
		 */
		public function log(...data):void
		{
			var s:String;
			if (data.length > 1)
			{
				s = "";
				var i:int = 0;
				while (i < data.length)
				{
					if (i > 0) s += " ";
					s += data[i ++].toString();
				}
			}
			else s = data[0].toString();
			if (s.indexOf("\n") >= 0)
			{
				var a:Array = s.split("\n");
				for each (s in a) LOG.push(s);
			}
			else LOG.push(s);
			if (_enabled && _sprite.visible) updateLog();
		}
		
		/**
		 * Adds properties to watch in the console's debug panel.
		 * @param	properties		The properties (strings) to watch.
		 */
		public function watch(...properties):void
		{
			var i:String;
			if (properties.length > 1)
			{
				for each (i in properties) WATCH_LIST.push(i);
			}
			else if (properties[0] is Array || properties[0] is Vector.<*>)
			{
				for each (i in properties[0]) WATCH_LIST.push(i);
			}
			else WATCH_LIST.push(properties[0]);
		}
		
		/**
		 * Enables the console.
		 */
		public function enable():void
		{
			// Quit if the console is already enabled.
			if (_enabled) return;
			
			// Enable it and add the Sprite to the stage.
			_enabled = true;
			FP.engine.addChild(_sprite);
			
			// Used to determine some text sizing.
			var big:Boolean = width >= 480;
			
			// The transparent FlashPunk logo overlay bitmap.
			_sprite.addChild(_back);
			_back.bitmapData = new BitmapData(width, height, true, 0xFFFFFFFF);
			var b:BitmapData = (new CONSOLE_LOGO).bitmapData;
			FP.matrix.identity();
			FP.matrix.tx = Math.max((_back.bitmapData.width - b.width) / 2, 0);
			FP.matrix.ty = Math.max((_back.bitmapData.height - b.height) / 2, 0);
			FP.matrix.scale(Math.min(width / _back.bitmapData.width, 1), Math.min(height / _back.bitmapData.height, 1));
			_back.bitmapData.draw(b, FP.matrix, null, BlendMode.MULTIPLY);
			_back.bitmapData.draw(_back.bitmapData, null, null, BlendMode.INVERT);
			_back.bitmapData.colorTransform(_back.bitmapData.rect, new ColorTransform(1, 1, 1, 0.5));
			
			// The entity and selection sprites.
			_sprite.addChild(_entScreen);
			_entScreen.addChild(_entSelect);
			
			// The entity count text.
			_sprite.addChild(_entRead);
			_entRead.addChild(_entReadText);
			_entReadText.defaultTextFormat = format(16, 0xFFFFFF, "right");
			_entReadText.embedFonts = true;
			_entReadText.width = 100;
			_entReadText.height = 20;
			_entRead.x = width - _entReadText.width;
			
			// The entity count panel.
			_entRead.graphics.clear();
			_entRead.graphics.beginFill(0, .5);
			_entRead.graphics.drawRoundRectComplex(0, 0, _entReadText.width, 20, 0, 0, 20, 0);
			
			// The FPS text.
			_sprite.addChild(_fpsRead);
			_fpsRead.addChild(_fpsReadText);
			_fpsReadText.defaultTextFormat = format(16);
			_fpsReadText.embedFonts = true;
			_fpsReadText.width = 70;
			_fpsReadText.height = 20;
			_fpsReadText.x = 2;
			_fpsReadText.y = 1;
			
			// The FPS and frame timing panel.
			_fpsRead.graphics.clear();
			_fpsRead.graphics.beginFill(0, .75);
			_fpsRead.graphics.drawRoundRectComplex(0, 0, big ? 320 : 160, 20, 0, 0, 0, 20);
			
			// The frame timing text.
			if (big) _sprite.addChild(_fpsInfo);
			_fpsInfo.addChild(_fpsInfoText0);
			_fpsInfo.addChild(_fpsInfoText1);
			_fpsInfoText0.defaultTextFormat = format(8, 0xAAAAAA);
			_fpsInfoText1.defaultTextFormat = format(8, 0xAAAAAA);
			_fpsInfoText0.embedFonts = true;
			_fpsInfoText1.embedFonts = true;
			_fpsInfoText0.width = _fpsInfoText1.width = 60;
			_fpsInfoText0.height = _fpsInfoText1.height = 20;
			_fpsInfo.x = 75;
			_fpsInfoText1.x = 60;
			
			// The memory usage
			_fpsRead.addChild(_memReadText);
			_memReadText.defaultTextFormat = format(16);
			_memReadText.embedFonts = true;
			_memReadText.width = 110;
			_memReadText.height = 20;
			_memReadText.x = _fpsInfo.x + _fpsInfo.width + 5;
			_memReadText.y = 1;
			
			// The output log text.
			_sprite.addChild(_logRead);
			_logRead.addChild(_logReadText0);
			_logRead.addChild(_logReadText1);
			_logReadText0.defaultTextFormat = format(16, 0xFFFFFF);
			_logReadText1.defaultTextFormat = format(big ? 16 : 8, 0xFFFFFF);
			_logReadText0.embedFonts = true;
			_logReadText1.embedFonts = true;
			_logReadText0.selectable = false;
			_logReadText0.width = 80;
			_logReadText0.height = 20;
			_logReadText1.width = width;
			_logReadText0.x = 2;
			_logReadText0.y = 3;
			_logReadText0.text = "OUTPUT:";
			_logHeight = height - 60;
			_logBar = new Rectangle(8, 24, 16, _logHeight - 8);
			_logBarGlobal = _logBar.clone();
			_logBarGlobal.y += 40;
			_logLines = _logHeight / (big ? 16.5 : 8.5);
			
			// The debug text.
			_sprite.addChild(_debRead);
			_debRead.addChild(_debReadText0);
			_debRead.addChild(_debReadText1);
			_debReadText0.defaultTextFormat = format(16, 0xFFFFFF);
			_debReadText1.defaultTextFormat = format(8, 0xFFFFFF);
			_debReadText0.embedFonts = true;
			_debReadText1.embedFonts = true;
			_debReadText0.selectable = false;
			_debReadText0.width = 80;
			_debReadText0.height = 20;
			_debReadText1.width = 160;
			_debReadText1.height = int(height / 4);
			_debReadText0.x = 2;
			_debReadText0.y = 3;
			_debReadText1.x = 2;
			_debReadText1.y = 24;
			_debReadText0.text = "DEBUG:";
			_debRead.y = height - (_debReadText1.y + _debReadText1.height);
			
			// The button panel buttons.
			_sprite.addChild(_butRead);
			_butRead.addChild(_butDebug = new CONSOLE_DEBUG);
			_butRead.addChild(_butOutput = new CONSOLE_OUTPUT);
			_butRead.addChild(_butPlay = new CONSOLE_PLAY).x = 20;
			_butRead.addChild(_butPause = new CONSOLE_PAUSE).x = 20;
			_butRead.addChild(_butStep = new CONSOLE_STEP).x = 40;
			updateButtons();
			
			// The button panel.
			_butRead.graphics.clear();
			_butRead.graphics.beginFill(0, .75);
			_butRead.graphics.drawRoundRectComplex(-20, 0, 100, 20, 0, 0, 20, 20);
			
			// Default the display to debug view
			debug = true;
			
			// Set the state to unpaused.
			paused = false;
		}
		
		/**
		 * If the console should be visible.
		 */
		public function get visible():Boolean { return _sprite.visible; }
		public function set visible(value:Boolean):void
		{
			_sprite.visible = value;
			if (_enabled && value) updateLog();
		}
		
		/**
		 * Console update, called by game loop.
		 */
		public function update():void
		{
			// Quit if the console isn't enabled.
			if (!_enabled) return;
			
			// If the console is paused.
			if (_paused)
			{
				// Update buttons.
				updateButtons();
				
				// While in debug mode.
				if (_debug)
				{
					// While the game is paused.
					if (FP.engine.paused)
					{
						// When the mouse is pressed.
						if (Input.mousePressed)
						{
							// Mouse is within clickable area.
							if (Input.mouseFlashY > 20 && (Input.mouseFlashX > _debReadText1.width || Input.mouseFlashY < _debRead.y))
							{
								if (Input.check(Key.SHIFT))
								{
									if (SELECT_LIST.length) startDragging();
									else startPanning();
								}
								else startSelection();
							}
						}
						else
						{
							// Update mouse movement functions.
							if (_selecting) updateSelection();
							if (_dragging) updateDragging();
							if (_panning) updatePanning();
						}
						
						// Select all Entities
						if (Input.pressed(Key.A)) selectAll();
						
						// If the shift key is held.
						if (Input.check(Key.SHIFT))
						{
							// If Entities are selected.
							if (SELECT_LIST.length)
							{
								// Move Entities with the arrow keys.
								if (Input.pressed("_ARROWS")) updateKeyMoving();
							}
							else
							{
								// Pan the camera with the arrow keys.
								if (Input.check("_ARROWS")) updateKeyPanning();
							}
						}
					}
					else
					{
						// Update info while the game runs.
						updateEntityLists(FP.world.count != ENTITY_LIST.length);
						renderEntities();
						updateFPSRead();
						updateEntityCount();
					}
					
					// Update debug panel.
					updateDebugRead();
				}
				else
				{
					// log scrollbar
					if (_scrolling) updateScrolling();
					else if (Input.mousePressed) startScrolling();
				}
			}
			else
			{
				// Update info while the game runs.
				updateFPSRead();
				updateEntityCount();
			}
			
			// Console toggle.
			if (Input.pressed(toggleKey)) paused = !_paused;
		}
		
		/**
		 * If the Console is currently in paused mode.
		 */
		public function get paused():Boolean { return _paused; }
		public function set paused(value:Boolean):void
		{
			// Quit if the console isn't enabled.
			if (!_enabled) return;
			
			// Set the console to paused.
			_paused = value;
			FP.engine.paused = value;
			
			// Panel visibility.
			_back.visible = value;
			_entScreen.visible = value;
			_butRead.visible = value;
			
			// If the console is paused.
			if (value)
			{
				// Set the console to paused mode.
				if (_debug) debug = true;
				else updateLog();
			}
			else
			{
				// Set the console to running mode.
				_debRead.visible = false;
				_logRead.visible = true;
				updateLog();
				ENTITY_LIST.length = 0;
				SCREEN_LIST.length = 0;
				SELECT_LIST.length = 0;
			}
		}
		
		/**
		 * If the Console is currently in debug mode.
		 */
		public function get debug():Boolean { return _debug; }
		public function set debug(value:Boolean):void
		{
			// Quit if the console isn't enabled.
			if (!_enabled) return;
			
			// Set the console to debug mode.
			_debug = value;
			_debRead.visible = value;
			_logRead.visible = !value;
			
			// Update console state.
			if (value) updateEntityLists();
			else updateLog();
			renderEntities();
		}
		
		/** @private Steps the frame ahead. */
		private function stepFrame():void
		{
			FP.engine.update();
			FP.engine.render();
			updateEntityCount();
			updateEntityLists();
			renderEntities();
		}
		
		/** @private Starts Entity dragging. */
		private function startDragging():void
		{
			_dragging = true;
			_entRect.x = Input.mouseX;
			_entRect.y = Input.mouseY;
		}
		
		/** @private Updates Entity dragging. */
		private function updateDragging():void
		{
			moveSelected(Input.mouseX - _entRect.x, Input.mouseY - _entRect.y);
			_entRect.x = Input.mouseX;
			_entRect.y = Input.mouseY;
			if (Input.mouseReleased) _dragging = false;
		}
		
		/** @private Move the selected Entities by the amount. */
		private function moveSelected(xDelta:int, yDelta:int):void
		{
			for each (var e:Entity in SELECT_LIST)
			{
				e.x += xDelta;
				e.y += yDelta;
			}
			FP.engine.render();
			renderEntities();
			updateEntityLists(true);
		}
		
		/** @private Starts camera panning. */
		private function startPanning():void
		{
			_panning = true;
			_entRect.x = Input.mouseX;
			_entRect.y = Input.mouseY;
		}
		
		/** @private Updates camera panning. */
		private function updatePanning():void
		{
			if (Input.mouseReleased) _panning = false;
			panCamera(_entRect.x - Input.mouseX, _entRect.y - Input.mouseY);
			_entRect.x = Input.mouseX;
			_entRect.y = Input.mouseY;
		}
		
		/** @private Pans the camera. */
		private function panCamera(xDelta:int, yDelta:int):void
		{
			FP.camera.x += xDelta;
			FP.camera.y += yDelta;
			FP.engine.render();
			updateEntityLists(true);
			renderEntities();
		}
		
		/** @private Sets the camera position. */
		private function setCamera(x:int, y:int):void
		{
			FP.camera.x = x;
			FP.camera.y = y;
			FP.engine.render();
			updateEntityLists(true);
			renderEntities();
		}
		
		/** @private Starts Entity selection. */
		private function startSelection():void
		{
			_selecting = true;
			_entRect.x = Input.mouseFlashX;
			_entRect.y = Input.mouseFlashY;
			_entRect.width = 0;
			_entRect.height = 0;
		}
		
		/** @private Updates Entity selection. */
		private function updateSelection():void
		{
			_entRect.width = Input.mouseFlashX - _entRect.x;
			_entRect.height = Input.mouseFlashY - _entRect.y;
			if (Input.mouseReleased)
			{
				selectEntities(_entRect);
				renderEntities();
				_selecting = false;
				_entSelect.graphics.clear();
			}
			else
			{
				_entSelect.graphics.clear();
				_entSelect.graphics.lineStyle(1, 0xFFFFFF);
				_entSelect.graphics.drawRect(_entRect.x, _entRect.y, _entRect.width, _entRect.height);
			}
		}
		
		/** @private Selects the Entities in the rectangle. */
		private function selectEntities(rect:Rectangle):void
		{
			if (rect.width < 0) rect.x -= (rect.width = -rect.width);
			else if (!rect.width) rect.width = 1;
			if (rect.height < 0) rect.y -= (rect.height = -rect.height);
			else if (!rect.height) rect.height = 1;
			
			FP.rect.width = FP.rect.height = 6;
			var sx:Number = FP.screen.scaleX * FP.screen.scale,
				sy:Number = FP.screen.scaleY * FP.screen.scale,
				e:Entity;
				
			if (Input.check(Key.CONTROL))
			{
				// Append selected Entities with new selections.
				for each (e in SCREEN_LIST)
				{
					if (SELECT_LIST.indexOf(e) < 0)
					{
						FP.rect.x = (e.x - FP.camera.x) * sx - 3;
						FP.rect.y = (e.y - FP.camera.y) * sy - 3;
						if (rect.intersects(FP.rect)) SELECT_LIST.push(e);
					}
				}
			}
			else
			{
				// Replace selections with new selections.
				SELECT_LIST.length = 0;
				for each (e in SCREEN_LIST)
				{
					FP.rect.x = (e.x - FP.camera.x) * sx - 3;
					FP.rect.y = (e.y - FP.camera.y) * sy - 3;
					if (rect.intersects(FP.rect)) SELECT_LIST.push(e);
				}
			}
		}
		
		/** @private Selects all entities on screen. */
		private function selectAll():void
		{
			SELECT_LIST.length = 0;
			for each (var e:Entity in SCREEN_LIST) SELECT_LIST.push(e);
			renderEntities();
		}
		
		/** @private Starts log text scrolling. */
		private function startScrolling():void
		{
			if (LOG.length > _logLines) _scrolling = _logBarGlobal.contains(Input.mouseFlashX, Input.mouseFlashY);
		}
		
		/** @private Updates log text scrolling. */
		private function updateScrolling():void
		{
			_scrolling = Input.mouseDown;
			_logScroll = FP.scaleClamp(Input.mouseFlashY, _logBarGlobal.y, _logBarGlobal.bottom, 0, 1);
			updateLog();
		}
		
		/** @private Moves Entities with the arrow keys. */
		private function updateKeyMoving():void
		{
			FP.point.x = (Input.pressed(Key.RIGHT) ? 1 : 0) - (Input.pressed(Key.LEFT) ? 1 : 0);
			FP.point.y = (Input.pressed(Key.DOWN) ? 1 : 0) - (Input.pressed(Key.UP) ? 1 : 0);
			if (FP.point.x != 0 || FP.point.y != 0) moveSelected(FP.point.x, FP.point.y);
		}
		
		/** @private Pans the camera with the arrow keys. */
		private function updateKeyPanning():void
		{
			FP.point.x = (Input.check(Key.RIGHT) ? 1 : 0) - (Input.check(Key.LEFT) ? 1 : 0);
			FP.point.y = (Input.check(Key.DOWN) ? 1 : 0) - (Input.check(Key.UP) ? 1 : 0);
			if (FP.point.x != 0 || FP.point.y != 0) panCamera(FP.point.x, FP.point.y);
		}
		
		/** @private Update the Entity list information. */
		private function updateEntityLists(fetchList:Boolean = true):void
		{
			// If the list should be re-populated.
			if (fetchList)
			{
				ENTITY_LIST.length = 0;
				FP.world.getAll(ENTITY_LIST);
			}
			
			// Update the list of Entities on screen.
			SCREEN_LIST.length = 0;
			for each (var e:Entity in ENTITY_LIST)
			{
				if (e.collideRect(e.x, e.y, FP.camera.x, FP.camera.y, FP.width, FP.height))
					SCREEN_LIST.push(e);
			}
		}
		
		/** @private Renders the Entities positions and hitboxes. */
		private function renderEntities():void
		{
			// If debug mode is on.
			_entScreen.visible = _debug;
			if (_debug)
			{
				var g:Graphics = _entScreen.graphics,
					sx:Number = FP.screen.scaleX * FP.screen.scale,
					sy:Number = FP.screen.scaleY * FP.screen.scale;
				g.clear();
				for each (var e:Entity in SCREEN_LIST)
				{
					// If the Entity is not selected.
					if (SELECT_LIST.indexOf(e) < 0)
					{
						// Draw the normal hitbox and position.
						if (e.width && e.height)
						{
							g.lineStyle(1, 0xFF0000);
							g.drawRect((e.x - e.originX - FP.camera.x) * sx, (e.y - e.originY - FP.camera.y) * sy, e.width * sx, e.height * sy);
							if (e.mask) e.mask.renderDebug(g);
						}
						g.lineStyle(1, 0x00FF00);
						g.drawRect((e.x - FP.camera.x) * sx - 3, (e.y - FP.camera.y) * sy - 3, 6, 6);
					}
					else
					{
						// Draw the selected hitbox and position.
						if (e.width && e.height)
						{
							g.lineStyle(1, 0xFFFFFF);
							g.drawRect((e.x - e.originX - FP.camera.x) * sx, (e.y - e.originY - FP.camera.y) * sy, e.width * sx, e.height * sy);
							if (e.mask) e.mask.renderDebug(g);
						}
						g.lineStyle(1, 0xFFFFFF);
						g.drawRect((e.x - FP.camera.x) * sx - 3, (e.y - FP.camera.y) * sy - 3, 6, 6);
					}
				}
			}
		}
		
		/** @private Updates the log window. */
		private function updateLog():void
		{
			// If the console is paused.
			if (_paused)
			{
				// Draw the log panel.
				_logRead.y = 40;
				_logRead.graphics.clear();
				_logRead.graphics.beginFill(0, .75);
				_logRead.graphics.drawRoundRectComplex(0, 0, _logReadText0.width, 20, 0, 20, 0, 0);
				_logRead.graphics.drawRect(0, 20, width, _logHeight);
				
				// Draw the log scrollbar.
				_logRead.graphics.beginFill(0x202020, 1);
				_logRead.graphics.drawRoundRectComplex(_logBar.x, _logBar.y, _logBar.width, _logBar.height, 8, 8, 8, 8);
				
				// If the log has more lines than the display limit.
				if (LOG.length > _logLines)
				{
					// Draw the log scrollbar handle.
					_logRead.graphics.beginFill(0xFFFFFF, 1);
					var y:uint = _logBar.y + 2 + (_logBar.height - 16) * _logScroll;
					_logRead.graphics.drawRoundRectComplex(_logBar.x + 2, y, 12, 12, 6, 6, 6, 6);
				}
				
				// Display the log text lines.
				if (LOG.length)
				{
					var i:int = LOG.length > _logLines ? Math.round((LOG.length - _logLines) * _logScroll) : 0,
						n:int = i + Math.min(_logLines, LOG.length),
						s:String = "";
					while (i < n) s += LOG[i ++] + "\n";
					_logReadText1.text = s;
				}
				else _logReadText1.text = "";
				
				// Indent the text for the scrollbar and size it to the log panel.
				_logReadText1.height = _logHeight;
				_logReadText1.x = 32;
				_logReadText1.y = 24;
				
				// Make text selectable in paused mode.
				_fpsReadText.selectable = true;
				_fpsInfoText0.selectable = true;
				_fpsInfoText1.selectable = true;
				_memReadText.selectable = true;
				_entReadText.selectable = true;
				_debReadText1.selectable = true;
			}
			else
			{
				// Draw the single-line log panel.
				_logRead.y = height - 40;
				_logReadText1.height = 20;
				_logRead.graphics.clear();
				_logRead.graphics.beginFill(0, .75);
				_logRead.graphics.drawRoundRectComplex(0, 0, _logReadText0.width, 20, 0, 20, 0, 0);
				_logRead.graphics.drawRect(0, 20, width, 20);
				
				// Draw the single-line log text with the latests logged text.
				_logReadText1.text = LOG.length ? LOG[LOG.length - 1] : "";
				_logReadText1.x = 2;
				_logReadText1.y = 21;
				
				// Make text non-selectable while running.
				_logReadText1.selectable = false;
				_fpsReadText.selectable = false;
				_fpsInfoText0.selectable = false;
				_fpsInfoText1.selectable = false;
				_memReadText.selectable = false;
				_entReadText.selectable = false;
				_debReadText0.selectable = false;
				_debReadText1.selectable = false;
			}
		}
		
		/** @private Update the FPS/frame timing panel text. */
		private function updateFPSRead():void
		{
			_fpsReadText.text = "FPS: " + FP.frameRate.toFixed();
			_fpsInfoText0.text =
				"Update: " + String(FP._updateTime) + "ms\n" + 
				"Render: " + String(FP._renderTime) + "ms";
			_fpsInfoText1.text =
				"Game: " + String(FP._gameTime) + "ms\n" + 
				"Flash: " + String(FP._flashTime) + "ms";
			_memReadText.text = "MEM: " + Number(System.totalMemory/1024/1024).toFixed(2) + "MB";
		}
		
		/** @private Update the debug panel text. */
		private function updateDebugRead():void
		{
			// Find out the screen size and set the text.
			var big:Boolean = width >= 480;
			
			// Update the Debug read text.
			var s:String =
				"Mouse: " + String(FP.world.mouseX) + ", " + String(FP.world.mouseY) +
				"\nCamera: " + String(FP.camera.x) + ", " + String(FP.camera.y);
			if (SELECT_LIST.length)
			{
				if (SELECT_LIST.length > 1)
				{
					s += "\n\nSelected: " + String(SELECT_LIST.length);
				}
				else
				{
					var e:Entity = SELECT_LIST[0];
					s += "\n\n- " + String(e) + " -\n";
					for each (var i:String in WATCH_LIST)
					{
						if (e.hasOwnProperty(i)) s += "\n" + i + ": " + e[i];
					}
				}
			}
			
			// Set the text and format.
			_debReadText1.text = s;
			_debReadText1.setTextFormat(format(big ? 16 : 8));
			_debReadText1.width = Math.max(_debReadText1.textWidth + 4, _debReadText0.width);
			_debReadText1.height = _debReadText1.y + _debReadText1.textHeight + 4;
			
			// The debug panel.
			_debRead.y = int(height - _debReadText1.height);
			_debRead.graphics.clear();
			_debRead.graphics.beginFill(0, .75);
			_debRead.graphics.drawRoundRectComplex(0, 0, _debReadText0.width, 20, 0, 20, 0, 0);
			_debRead.graphics.drawRoundRectComplex(0, 20, _debReadText1.width + 20, height - _debRead.y - 20, 0, 20, 0, 0);
		}
		
		/** @private Updates the Entity count text. */
		private function updateEntityCount():void
		{
			_entReadText.text = String(FP.world.count) + " Entities";
		}
		
		/** @private Updates the Button panel. */
		private function updateButtons():void
		{
			// Button visibility.
			_butRead.x = _fpsInfo.x + _fpsInfo.width + int((_entRead.x - (_fpsInfo.x + _fpsInfo.width)) / 2) - 30;
			_butDebug.visible = !_debug;
			_butOutput.visible = _debug;
			_butPlay.visible = FP.engine.paused;
			_butPause.visible = !FP.engine.paused;
			
			// Debug/Output button.
			if (_butDebug.bitmapData.rect.contains(_butDebug.mouseX, _butDebug.mouseY))
			{
				_butDebug.alpha = _butOutput.alpha = 1;
				if (Input.mousePressed) debug = !_debug;
			}
			else _butDebug.alpha = _butOutput.alpha = .5;
			
			// Play/Pause button.
			if (_butPlay.bitmapData.rect.contains(_butPlay.mouseX, _butPlay.mouseY))
			{
				_butPlay.alpha = _butPause.alpha = 1;
				if (Input.mousePressed)
				{
					FP.engine.paused = !FP.engine.paused;
					renderEntities();
				}
			}
			else _butPlay.alpha = _butPause.alpha = .5;
			
			// Frame step button.
			if (_butStep.bitmapData.rect.contains(_butStep.mouseX, _butStep.mouseY))
			{
				_butStep.alpha = 1;
				if (Input.mousePressed) stepFrame();
			}
			else _butStep.alpha = .5;
		}
		
		/** @private Gets a TextFormat object with the formatting. */
		private function format(size:uint = 16, color:uint = 0xFFFFFF, align:String = "left"):TextFormat
		{
			_format.size = size;
			_format.color = color;
			_format.align = align;
			return _format;
		}
		
		/**
		 * Get the unscaled screen size for the Console.
		 */
		private function get width():uint { return FP.width * FP.screen.scaleX * FP.screen.scale; }
		private function get height():uint { return FP.height * FP.screen.scaleY * FP.screen.scale; }
		
		// Console state information.
		/** @private */ private var _enabled:Boolean;
		/** @private */ private var _paused:Boolean;
		/** @private */ private var _debug:Boolean;
		/** @private */ private var _scrolling:Boolean;
		/** @private */ private var _selecting:Boolean;
		/** @private */ private var _dragging:Boolean;
		/** @private */ private var _panning:Boolean;
		
		// Console display objects.
		/** @private */ private var _sprite:Sprite = new Sprite;
		/** @private */ private var _format:TextFormat = new TextFormat("default");
		/** @private */ private var _back:Bitmap = new Bitmap;
		
		// FPS panel information.
		/** @private */ private var _fpsRead:Sprite = new Sprite;
		/** @private */ private var _fpsReadText:TextField = new TextField;
		/** @private */ private var _fpsInfo:Sprite = new Sprite;
		/** @private */ private var _fpsInfoText0:TextField = new TextField;
		/** @private */ private var _fpsInfoText1:TextField = new TextField;
		/** @private */ private var _memReadText:TextField = new TextField;
		
		// Output panel information.
		/** @private */ private var _logRead:Sprite = new Sprite;
		/** @private */ private var _logReadText0:TextField = new TextField;
		/** @private */ private var _logReadText1:TextField = new TextField;
		/** @private */ private var _logHeight:uint;
		/** @private */ private var _logBar:Rectangle;
		/** @private */ private var _logBarGlobal:Rectangle;
		/** @private */ private var _logScroll:Number = 0;
		
		// Entity count panel information.
		/** @private */ private var _entRead:Sprite = new Sprite;
		/** @private */ private var _entReadText:TextField = new TextField;
		
		// Debug panel information.
		/** @private */ private var _debRead:Sprite = new Sprite;
		/** @private */ private var _debReadText0:TextField = new TextField;
		/** @private */ private var _debReadText1:TextField = new TextField;

		// Button panel information
		/** @private */ private var _butRead:Sprite = new Sprite;
		/** @private */ private var _butDebug:Bitmap;
		/** @private */ private var _butOutput:Bitmap;
		/** @private */ private var _butPlay:Bitmap;
		/** @private */ private var _butPause:Bitmap;
		/** @private */ private var _butStep:Bitmap;
		
		// Entity selection information.
		/** @private */ private var _entScreen:Sprite = new Sprite;
		/** @private */ private var _entSelect:Sprite = new Sprite;
		/** @private */ private var _entRect:Rectangle = new Rectangle;
		
		// Log information.
		/** @private */ private var _logLines:uint = 33;
		/** @private */ private const LOG:Vector.<String> = new Vector.<String>;
		
		// Entity lists.
		/** @private */ private const ENTITY_LIST:Vector.<Entity> = new Vector.<Entity>;
		/** @private */ private const SCREEN_LIST:Vector.<Entity> = new Vector.<Entity>;
		/** @private */ private const SELECT_LIST:Vector.<Entity> = new Vector.<Entity>;
		
		// Watch information.
		/** @private */ private const WATCH_LIST:Vector.<String> = Vector.<String>(["x", "y"]);
		
		// Embedded assets.
		[Embed(source = 'console_logo.png')] private const CONSOLE_LOGO:Class;
		[Embed(source = 'console_debug.png')] private const CONSOLE_DEBUG:Class;
		[Embed(source = 'console_output.png')] private const CONSOLE_OUTPUT:Class;
		[Embed(source = 'console_play.png')] private const CONSOLE_PLAY:Class;
		[Embed(source = 'console_pause.png')] private const CONSOLE_PAUSE:Class;
		[Embed(source = 'console_step.png')] private const CONSOLE_STEP:Class;
		
		// Reference the Text class so we can access its embedded font
		private static var textRef:Text;
	}
}
