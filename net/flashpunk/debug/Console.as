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
		 * @param	data The data parameters to log, can be variables, objects, etc. Parameters will be separated by a space (" ").
		 */
		public function log(...data):void
		{
			var s:String = "";
			
			// Iterate through data to build a string.
			for (var i:uint = 0; i < data.length; i++)
			{
				if (i > 0) s += " ";
				s += (data[i] != null) ? data[i].toString() : "null";
			}
			
			// Replace newlines with multiple log statements.
			if (s.indexOf("\n") >= 0)
			{
				var a:Array = s.split("\n");
				for each (s in a) LOG.push(s);
			}
			else
			{
				LOG.push(s);
			}
			
			// If the log is running, update it.
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

			// Draw the background.
			_sprite.addChild(_back);
			_back.graphics.clear();
			_back.graphics.beginFill(0x000000, 0.25);
			_back.graphics.drawRect(0, 0, width, height);
			
			// The entity and selection sprites.
			_sprite.addChild(_entScreen);
			_entScreen.addChild(_entSelect);
			
			// The top tray.
			_sprite.addChild(_topTray);
			_topTray.graphics.clear();
			_topTray.graphics.beginFill(0x000000, 0.6);
			_topTray.graphics.drawRect(0, 0, width, 20);
			_topTray.graphics.beginFill(0x000000, 0.7);
			_topTray.graphics.drawRect(0, 20, width, 1);

			// The entity count text.
			_topTray.addChild(_entReadText);
			_entReadText.defaultTextFormat = format(12, 0xffffff, "right", true);
			_entReadText.embedFonts = true;
			_entReadText.width = 100;
			_entReadText.height = 20;
			_entReadText.x = width - _entReadText.width;
			
			// The FPS text.
			_topTray.addChild(_fpsReadText);
			_fpsReadText.defaultTextFormat = format(12, 0xffffff, "left", true);
			_fpsReadText.embedFonts = true;
			_fpsReadText.width = 70;
			_fpsReadText.height = 20;
			_fpsReadText.x = 2;
			_fpsReadText.y = 1;

			_systemTimelineGraphs[0] = new TimelineGraph(GRAPH_WIDTH, GRAPH_HEIGHT, "Update", "ms", 0xff7ab2ff);
			_systemTimelineGraphs[1] = new TimelineGraph(GRAPH_WIDTH, GRAPH_HEIGHT, "Render", "ms", 0xff7aff8c);
			_systemTimelineGraphs[2] = new TimelineGraph(GRAPH_WIDTH, GRAPH_HEIGHT, "Game", "ms", 0xfffff47a);
			_systemTimelineGraphs[3] = new TimelineGraph(GRAPH_WIDTH, GRAPH_HEIGHT, "Flash", "ms", 0xffffa27a);
			
			// The frame timing graphs.
			_sprite.addChild(_systemTimelineGraphSprite);
			_systemTimelineGraphSprite.visible = false;

			// Add graphs.
			for (var i:uint = 0; i < _systemTimelineGraphs.length; i++)
			{
				_systemTimelineGraphs[i].x = (GRAPH_WIDTH + 6) * i;
				_systemTimelineGraphs[i].y = 0;
				_systemTimelineGraphSprite.addChild(_systemTimelineGraphs[i]);
			}

			_systemTimelineGraphSprite.x = 2;
			_systemTimelineGraphSprite.y = 23;
			
			// The memory usage
			_topTray.addChild(_memReadText);
			_memReadText.defaultTextFormat = format(12, 0xffffff, "left", true);
			_memReadText.embedFonts = true;
			_memReadText.width = 110;
			_memReadText.height = 20;
			_memReadText.x = _fpsReadText.x + _fpsReadText.width + 5;
			_memReadText.y = 1;

			// The bottom tray.
			_sprite.addChild(_bottomTray);
			_bottomTray.graphics.clear();
			_bottomTray.graphics.beginFill(0x000000, 0.6);
			_bottomTray.graphics.drawRect(0, 1, width, 20);
			_bottomTray.graphics.beginFill(0x000000, 0.7);
			_bottomTray.graphics.drawRect(0, 0, width, 1);
			_bottomTray.y = height - 21;
			
			// The output log text.
			_bottomTray.addChild(_logRead);
			_logRead.addChild(_logReadText);
			_logReadText.defaultTextFormat = format(12, 0xFFFFFF, "left", false, "Source Code Pro");
			_logReadText.embedFonts = true;
			_logReadText.width = width;
			_logHeight = height - 51 - GRAPH_HEIGHT;
			_logBar = new Rectangle(4, 4, 16, _logHeight - 8);
			_logBarGlobal = _logBar.clone();
			_logBarGlobal.y += 60;
			_logLines = _logHeight / 15.7;
			
			// The debug text.
			_sprite.addChild(_debRead);
			_debRead.addChild(_debReadText);
			_debReadText.defaultTextFormat = format(16, 0xFFFFFF);
			_debReadText.embedFonts = true;
			_debReadText.width = 160;
			_debReadText.height = int(height / 4);
			_debReadText.x = 2;
			_debReadText.y = 0;
			_debRead.y = height - (_debReadText.y + _debReadText.height);
			
			// The button panel buttons.
			_topTray.addChild(_butRead);
			_butRead.addChild(_butDebug = new CONSOLE_DEBUG);
			_butRead.addChild(_butOutput = new CONSOLE_OUTPUT);
			_butRead.addChild(_butPlay = new CONSOLE_PLAY).x = 20;
			_butRead.addChild(_butPause = new CONSOLE_PAUSE).x = 20;
			_butRead.addChild(_butStep = new CONSOLE_STEP).x = 40;
			updateButtons();

			_butRead.x = _memReadText.x + _memReadText.width + 5;
			
			// The button panel.
			
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
							if (Input.mouseFlashY > 20 && (Input.mouseFlashX > _debReadText.width || Input.mouseFlashY < _debRead.y))
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


			// Clicked the FPS text.
			if (_fpsReadText.mouseX < 75 && _fpsReadText.mouseY < 20)
			{
				_fpsReadText.alpha = 0.5;
				if (Input.mousePressed)
				{
					_systemTimelineGraphSprite.visible = !_systemTimelineGraphSprite.visible;
				}
			}
			else
			{
				_fpsReadText.alpha = 1.0;
			}
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
				if (_debug)
				{
					// Draw the single-line log text with the latests logged text.
					_bottomTray.graphics.clear();
					_bottomTray.graphics.beginFill(0x000000, 0.6);
					_bottomTray.graphics.drawRect(0, 1, width, 20);
					_bottomTray.graphics.beginFill(0x000000, 0.7);
					_bottomTray.graphics.drawRect(0, 0, width, 1);
					_bottomTray.y = height - 21;

					_logReadText.text = LOG.length ? LOG[LOG.length - 1] : "";
					_logReadText.x = 2;
					_logReadText.y = 1;
				}
				else
				{
					// Draw the full log panel.
					_bottomTray.y = 51 + GRAPH_HEIGHT;
					_bottomTray.graphics.clear();
					_bottomTray.graphics.beginFill(0, .7);
					_bottomTray.graphics.drawRect(0, 1, width, _logHeight);
					_bottomTray.graphics.beginFill(0, .8);
					_bottomTray.graphics.drawRect(0, 0, width, 1);
					_bottomTray.graphics.beginFill(0, 0.5);
					_bottomTray.graphics.drawRoundRectComplex(_logBar.x, _logBar.y, _logBar.width, _logBar.height, 5, 5, 5, 5);
					
					// If the log has more lines than the display limit.
					if (LOG.length > _logLines)
					{
						// Draw the log scrollbar handle.
						var y:uint = _logBar.y + 2 + (_logBar.height - 16) * _logScroll;
						_bottomTray.graphics.beginFill(0xFFFFFF, 1);
						_bottomTray.graphics.drawRoundRectComplex(_logBar.x + 2, y, 12, 12, 4, 4, 4, 4);
					}
					
					// Display the log text lines.
					if (LOG.length)
					{
						var i:int = 0,
							n:int = 0,
							s:String = "";
						
						if (LOG.length > _logLines) {
							i = Math.round((LOG.length - _logLines) * _logScroll);
						}
						
						n = i + Math.min(_logLines, LOG.length);
							
						while (i < n) s += LOG[i ++] + "\n";
						_logReadText.text = s;
					}
					else _logReadText.text = "";
					
					// Indent the text for the scrollbar and size it to the log panel.
					_logReadText.height = _logHeight;
					_logReadText.x = _logBar.right + 4;
					_logReadText.y = 4;
				}
			}
			else
			{	
				// Draw the single-line log text with the latests logged text.
				_bottomTray.graphics.clear();
				_bottomTray.graphics.beginFill(0x000000, 0.6);
				_bottomTray.graphics.drawRect(0, 1, width, 20);
				_bottomTray.graphics.beginFill(0x000000, 0.7);
				_bottomTray.graphics.drawRect(0, 0, width, 1);
				_bottomTray.y = height - 21;

				_logReadText.text = LOG.length ? LOG[LOG.length - 1] : "";
				_logReadText.x = 2;
				_logReadText.y = 1;
			}

			// Update selectability of TextFields.
			_logReadText.selectable = _paused;
			_fpsReadText.selectable = _paused;
			for each (var graph:TimelineGraph in _systemTimelineGraphs)
			{
				graph.textField.selectable = _paused;
			}
			_memReadText.selectable = _paused;
			_entReadText.selectable = _paused;
			_debReadText.selectable = _paused;
		}
		
		/** @private Update the FPS/frame timing panel text. */
		private function updateFPSRead():void
		{
			_fpsReadText.text = String(_systemTimelineGraphSprite.visible ? "–" : "+") + " FPS: " + FP.frameRate.toFixed();
			_fpsReadText.textColor = FP.frameRate > 30 ? FP.frameRate > 45 ? 0x91ff00 : 0xffe500 : 0xff4d00;
			_systemTimelineGraphs[0].addData(FP._updateTime);
			_systemTimelineGraphs[1].addData(FP._renderTime);
			_systemTimelineGraphs[2].addData(FP._gameTime);
			_systemTimelineGraphs[3].addData(FP._flashTime);
			_memReadText.text = "Memory: " + Number(System.totalMemory/1024/1024).toFixed(2) + "MB";
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
			_debReadText.text = s;
			_debReadText.width = _debReadText.textWidth + 4;
			_debReadText.height = _debReadText.y + _debReadText.textHeight + 4;
			
			// The debug panel.
			_debRead.y = int(height - 23 - _debReadText.height);
			_debRead.x = 2;
			_debRead.graphics.clear();
			_debRead.graphics.beginFill(0, .8);
			_debRead.graphics.drawRect(0, 0, _debReadText.width + 4, _debReadText.height);
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
			_butDebug.visible = !_debug;
			_butOutput.visible = _debug;
			_butPlay.visible = FP.engine.paused;
			_butPause.visible = !FP.engine.paused;
			
			// Debug/Output button.
			if (_butDebug.bitmapData.rect.contains(_butDebug.mouseX, _butDebug.mouseY))
			{
				_butDebug.alpha = _butOutput.alpha = 1;
				if (Input.mousePressed)
				{
					debug = !_debug;
					updateLog();
				}
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
		private function format(size:uint = 12, color:uint = 0xFFFFFF, align:String = "left", isBold:Boolean = false, fontFamily:String = "Source Sans Pro"):TextFormat
		{
			_format.size = size;
			_format.color = color;
			_format.align = align;
			_format.bold = isBold;
			_format.font = fontFamily;
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
		/** @private */ private var _format:TextFormat = new TextFormat();
		/** @private */ private var _back:Sprite = new Sprite;
		/** @private */ private var _topTray:Sprite = new Sprite;
		/** @private */ private var _bottomTray:Sprite = new Sprite;
		
		// FPS panel information.
		/** @private */ private var _fpsRead:Sprite = new Sprite;
		/** @private */ private var _fpsReadText:TextField = new TextField;
		/** @private */ private var _memReadText:TextField = new TextField;

		// FPS time graphs.
		/** @private */ private var _fpsInfo:Sprite = new Sprite;
		/** @private */ private var _systemTimelineGraphs:Vector.<TimelineGraph> = new Vector.<TimelineGraph>(4);
		/** @private */ private var _systemTimelineGraphSprite:Sprite = new Sprite;
		/** @private */ private const GRAPH_WIDTH:uint = 120;
		/** @private */ private const GRAPH_HEIGHT:uint = 40;
		
		// Output panel information.
		/** @private */ private var _logRead:Sprite = new Sprite;
		/** @private */ private var _logReadText:TextField = new TextField;
		/** @private */ private var _logHeight:uint;
		/** @private */ private var _logBar:Rectangle;
		/** @private */ private var _logBarGlobal:Rectangle;
		/** @private */ private var _logScroll:Number = 0;
		
		// Entity count panel information.
		/** @private */ private var _entRead:Sprite = new Sprite;
		/** @private */ private var _entReadText:TextField = new TextField;
		
		// Debug panel information.
		/** @private */ private var _debRead:Sprite = new Sprite;
		/** @private */ private var _debReadText:TextField = new TextField;

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
		[Embed(source = 'console_debug.png')]
		/** @private */ private const CONSOLE_DEBUG:Class;
		[Embed(source = 'console_output.png')]
		/** @private */ private const CONSOLE_OUTPUT:Class;
		[Embed(source = 'console_play.png')]
		/** @private */ private const CONSOLE_PLAY:Class;
		[Embed(source = 'console_pause.png')]
		/** @private */ private const CONSOLE_PAUSE:Class;
		[Embed(source = 'console_step.png')]
		/** @private */ private const CONSOLE_STEP:Class;
		
		// Reference the Text class so we can access its embedded font
		private static var textRef:Text;
	}
}
