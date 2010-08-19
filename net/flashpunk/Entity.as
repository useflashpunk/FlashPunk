package net.flashpunk
{
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	import net.flashpunk.masks.*;
	import net.flashpunk.graphics.*;
	
	/**
	 * Main game Entity class updated by World.
	 */
	public class Entity extends Tweener
	{
		/**
		 * If the Entity should render.
		 */
		public var visible:Boolean = true;
		
		/**
		 * If the Entity should respond to collision checks.
		 */
		public var collidable:Boolean = true;
		
		/**
		 * X position of the Entity in the World.
		 */
		public var x:Number = 0;
		
		/**
		 * Y position of the Entity in the World.
		 */
		public var y:Number = 0;
		
		/**
		 * Width of the Entity's hitbox.
		 */
		public var width:int;
		
		/**
		 * Height of the Entity's hitbox.
		 */
		public var height:int;
		
		/**
		 * X origin of the Entity's hitbox.
		 */
		public var originX:int;
		
		/**
		 * Y origin of the Entity's hitbox.
		 */
		public var originY:int;
		
		/**
		 * Constructor. Can be usd to place the Entity and assign a graphic and mask.
		 * @param	x			X position to place the Entity.
		 * @param	y			Y position to place the Entity.
		 * @param	graphic		Graphic to assign to the Entity.
		 * @param	mask		Mask to assign to the Entity.
		 */
		public function Entity(x:Number = 0, y:Number = 0, graphic:Graphic = null, mask:Mask = null) 
		{
			this.x = x;
			this.y = y;
			if (graphic) this.graphic = graphic;
			if (mask) this.mask = mask;
			HITBOX.assignTo(this);
			_class = Class(getDefinitionByName(getQualifiedClassName(this)));
		}
		
		/**
		 * Override this, called when the Entity is added to a World.
		 */
		public function added():void
		{
			
		}
		
		/**
		 * Override this, called when the Entity is removed from a World.
		 */
		public function removed():void
		{
			
		}
		
		/**
		 * Updates the Entity's graphic. If you override this for
		 * update logic, remember to call super.update() if you're
		 * using a Graphic type that animates (eg. Spritemap).
		 */
		override public function update():void 
		{
			
		}
		
		/**
		 * Renders the Entity. If you override this for special behaviour,
		 * remember to call super.render() to render the Entity's graphic.
		 */
		public function render():void 
		{
			if (_graphic && _graphic.visible)
			{
				if (_graphic.relative)
				{
					_point.x = x;
					_point.y = y;
				}
				else _point.x = _point.y = 0;
				_camera.x = FP.camera.x;
				_camera.y = FP.camera.y;
				_graphic.render(_point, _camera);
			}
		}
		
		/**
		 * Checks for a collision against an Entity type.
		 * @param	type		The Entity type to check for.
		 * @param	x			Virtual x position to place this Entity.
		 * @param	y			Virtual y position to place this Entity.
		 * @return	The first Entity collided with, or null if none were collided.
		 */
		public function collide(type:String, x:Number, y:Number):Entity
		{
			var e:Entity = FP._world._typeFirst[type];
			if (!collidable || !e) return null;
			
			_x = this.x; _y = this.y;
			this.x = x; this.y = y;
			
			if (!_mask)
			{
				while (e)
				{
					if (x - originX + width > e.x - e.originX
					&& y - originY + height > e.y - e.originY
					&& x - originX < e.x - e.originX + e.width
					&& y - originY < e.y - e.originY + e.height
					&& e.collidable && e !== this)
					{
						if (!e._mask || e._mask.collide(HITBOX))
						{
							this.x = _x; this.y = _y;
							return e;
						}
					}
					e = e._typeNext;
				}
				this.x = _x; this.y = _y;
				return null;
			}
			
			while (e)
			{
				if (x - originX + width > e.x - e.originX
				&& y - originY + height > e.y - e.originY
				&& x - originX < e.x - e.originX + e.width
				&& y - originY < e.y - e.originY + e.height
				&& e.collidable && e !== this)
				{
					if (_mask.collide(e._mask ? e._mask : e.HITBOX))
					{
						this.x = _x; this.y = _y;
						return e;
					}
				}
				e = e._typeNext;
			}
			this.x = _x; this.y = _y;
			return null;
		}
		
		/**
		 * Checks for collision against multiple Entity types.
		 * @param	types		An Array or Vector of Entity types to check for.
		 * @param	x			Virtual x position to place this Entity.
		 * @param	y			Virtual y position to place this Entity.
		 * @return	The first Entity collided with, or null if none were collided.
		 */
		public function collideTypes(types:Object, x:Number, y:Number):Entity
		{
			var e:Entity;
			for each (var type:String in types)
			{
				if ((e = collide(type, x, y))) return e;
			}
			return null;
		}
		
		/**
		 * Checks if this Entity collides with a specific Entity.
		 * @param	e		The Entity to collide against.
		 * @param	x		Virtual x position to place this Entity.
		 * @param	y		Virtual y position to place this Entity.
		 * @return	The Entity if they overlap, or null if they don't.
		 */
		public function collideWith(e:Entity, x:Number, y:Number):Entity
		{
			_x = this.x; _y = this.y;
			this.x = x; this.y = y;
			
			if (x - originX + width > e.x - e.originX
			&& y - originY + height > e.y - e.originY
			&& x - originX < e.x - e.originX + e.width
			&& y - originY < e.y - e.originY + e.height
			&& collidable && e.collidable)
			{
				if (!_mask)
				{
					if (!e._mask || e._mask.collide(HITBOX))
					{
						this.x = _x; this.y = _y;
						return e;
					}
					this.x = _x; this.y = _y;
					return null;
				}
				if (_mask.collide(e._mask ? e._mask : e.HITBOX))
				{
					this.x = _x; this.y = _y;
					return e;
				}
			}
			this.x = _x; this.y = _y;
			return null;
		}
		
		/**
		 * Checks if this Entity overlaps the specified rectangle.
		 * @param	x			Virtual x position to place this Entity.
		 * @param	y			Virtual y position to place this Entity.
		 * @param	rX			X position of the rectangle.
		 * @param	rY			Y position of the rectangle.
		 * @param	rWidth		Width of the rectangle.
		 * @param	rHeight		Height of the rectangle.
		 * @return	If they overlap.
		 */
		public function collideRect(x:Number, y:Number, rX:Number, rY:Number, rWidth:Number, rHeight:Number):Boolean
		{
			if (x - originX + width >= rX && y - originY + height >= rY
			&& x - originX <= rX + rWidth && y - originY <= rY + rHeight)
			{
				if (!_mask) return true;
				_x = this.x; _y = this.y;
				this.x = x; this.y = y;
				FP.entity.x = rX;
				FP.entity.y = rY;
				FP.entity.width = rWidth;
				FP.entity.height = rHeight;
				if (_mask.collide(FP.entity.HITBOX))
				{
					this.x = _x; this.y = _y;
					return true;
				}
				this.x = _x; this.y = _y;
				return false;
			}
			return false;
		}
		
		/**
		 * Checks if this Entity overlaps the specified position.
		 * @param	x			Virtual x position to place this Entity.
		 * @param	y			Virtual y position to place this Entity.
		 * @param	pX			X position.
		 * @param	pY			Y position.
		 * @return	If the Entity intersects with the position.
		 */
		public function collidePoint(x:Number, y:Number, pX:Number, pY:Number):Boolean
		{
			if (pX >= x - originX && pY >= y - originY
			&& pX < x - originX + width && pY < y - originY + height)
			{
				if (!_mask) return true;
				_x = this.x; _y = this.y;
				this.x = x; this.y = y;
				FP.entity.x = pX;
				FP.entity.y = pY;
				FP.entity.width = 1;
				FP.entity.height = 1;
				if (_mask.collide(FP.entity.HITBOX))
				{
					this.x = _x; this.y = _y;
					return true;
				}
				this.x = _x; this.y = _y;
				return false;
			}
			return false;
		}
		
		/**
		 * Populates an array with all collided Entities of a type.
		 * @param	type		The Entity type to check for.
		 * @param	x			Virtual x position to place this Entity.
		 * @param	y			Virtual y position to place this Entity.
		 * @param	array		The Array or Vector object to populate.
		 * @return	The array, populated with all collided Entities.
		 */
		public function collideInto(type:String, x:Number, y:Number, array:Object):void
		{
			var e:Entity = FP._world._typeFirst[type];
			if (!collidable || !e) return;
			
			_x = this.x; _y = this.y;
			this.x = x; this.y = y;
			var n:uint = array.length;
			
			if (!_mask)
			{
				while (e)
				{
					if (x - originX + width > e.x - e.originX
					&& y - originY + height > e.y - e.originY
					&& x - originX < e.x - e.originX + e.width
					&& y - originY < e.y - e.originY + e.height
					&& e.collidable && e !== this)
					{
						if (!e._mask || e._mask.collide(HITBOX)) array[n ++] = e;
					}
					e = e._typeNext;
				}
				this.x = _x; this.y = _y;
				return;
			}
			
			while (e)
			{
				if (x - originX + width > e.x - e.originX
				&& y - originY + height > e.y - e.originY
				&& x - originX < e.x - e.originX + e.width
				&& y - originY < e.y - e.originY + e.height
				&& e.collidable && e !== this)
				{
					if (_mask.collide(e._mask ? e._mask : e.HITBOX)) array[n ++] = e;
				}
				e = e._typeNext;
			}
			this.x = _x; this.y = _y;
			return;
		}
		
		/**
		 * Populates an array with all collided Entities of multiple types.
		 * @param	types		An array of Entity types to check for.
		 * @param	x			Virtual x position to place this Entity.
		 * @param	y			Virtual y position to place this Entity.
		 * @param	array		The Array or Vector object to populate.
		 * @return	The array, populated with all collided Entities.
		 */
		public function collideTypesInto(types:Object, x:Number, y:Number, array:Object):void
		{
			for each (var type:String in types) collideInto(type, x, y, array);
		}
		
		/**
		 * If the Entity collides with the camera rectangle.
		 */
		public function get onCamera():Boolean
		{
			return collideRect(x, y, FP.camera.x, FP.camera.y, FP.width, FP.height);
		}
		
		/**
		 * The World object this Entity has been added to.
		 */
		public function get world():World
		{
			return _world;
		}
		
		/**
		 * The rendering layer of this Entity. Higher layers are rendered first.
		 */
		public function get layer():int { return _layer; }
		public function set layer(value:int):void
		{
			if (_layer == value) return;
			if (!_added)
			{
				_layer = value;
				return;
			}
			_world.removeRender(this);
			_layer = value;
			_world.addRender(this);
		}
		
		/**
		 * The collision type, used for collision checking.
		 */
		public function get type():String { return _type; }
		public function set type(value:String):void
		{
			if (_type == value) return;
			if (!_added)
			{
				_type = value;
				return;
			}
			if (_type) _world.removeType(this);
			_type = value;
			if (value) _world.addType(this);
		}
		
		/**
		 * An optional Mask component, used for specialized collision. If this is
		 * not assigned, collision checks will use the Entity's hitbox by default.
		 */
		public function get mask():Mask { return _mask; }
		public function set mask(value:Mask):void
		{
			if (_mask == value) return;
			if (_mask) _mask.assignTo(null);
			_mask = value;
			if (value) _mask.assignTo(this);
		}
		
		/**
		 * Graphical component to render to the screen.
		 */
		public function get graphic():Graphic { return _graphic; }
		public function set graphic(value:Graphic):void
		{
			if (_graphic == value) return;
			_graphic = value;
			if (value && value._assign != null) value._assign();
		}
		
		/**
		 * Sets the Entity's hitbox properties.
		 * @param	width		Width of the hitbox.
		 * @param	height		Height of the hitbox.
		 * @param	originX		X origin of the hitbox.
		 * @param	originY		Y origin of the hitbox.
		 */
		public function setHitbox(width:int = 0, height:int = 0, originX:int = 0, originY:int = 0):void
		{
			this.width = width;
			this.height = height;
			this.originX = originX;
			this.originY = originY;
		}
		
		/**
		 * Center's the Entity's origin (half width & height).
		 */
		public function centerOrigin():void
		{
			originX = width / 2;
			originY = height / 2;
		}
		
		/**
		 * Calculates the distance from another Entity.
		 * @param	e				The other Entity.
		 * @param	useHitboxes		If hitboxes should be used to determine the distance. If not, the Entities' x/y positions are used.
		 * @return	The distance.
		 */
		public function distanceFrom(e:Entity, useHitboxes:Boolean = false):Number
		{
			if (!useHitboxes) return Math.sqrt((x - e.x) * (x - e.x) + (y - e.y) * (y - e.y));
			return FP.distanceRects(x - originX, y - originY, width, height, e.x - e.originX, e.y - e.originY, e.width, e.height);
		}
		
		/**
		 * Calculates the distance from this Entity to the point.
		 * @param	px				X position.
		 * @param	py				Y position.
		 * @param	useHitboxes		If hitboxes should be used to determine the distance. If not, the Entities' x/y positions are used.
		 * @return	The distance.
		 */
		public function distanceToPoint(px:Number, py:Number, useHitbox:Boolean = false):Number
		{
			if (!useHitbox) return Math.sqrt((x - px) * (x - px) + (y - py) * (y - py));
			return FP.distanceRectPoint(px, py, x - originX, y - originY, width, height);
		}
		
		/**
		 * Calculates the distance from this Entity to the rectangle.
		 * @param	rx			X position of the rectangle.
		 * @param	ry			Y position of the rectangle.
		 * @param	rwidth		Width of the rectangle.
		 * @param	rheight		Height of the rectangle.
		 * @return	The distance.
		 */
		public function distanceToRect(rx:Number, ry:Number, rwidth:Number, rheight:Number):Number
		{
			return FP.distanceRects(rx, ry, rwidth, rheight, x - originX, y - originY, width, height);
		}
		
		/**
		 * Gets the class name as a string.
		 * @return	A string representing the class name.
		 */
		public function toString():String
		{
			var s:String = String(_class);
			return s.substring(7, s.length - 1);
		}
		
		// Entity information.
		/** @private */ internal var _class:Class;
		/** @private */ internal var _world:World;
		/** @private */ internal var _added:Boolean;
		/** @private */ internal var _type:String = "";
		/** @private */ internal var _layer:int;
		/** @private */ internal var _updatePrev:Entity;
		/** @private */ internal var _updateNext:Entity;
		/** @private */ internal var _renderPrev:Entity;
		/** @private */ internal var _renderNext:Entity;
		/** @private */ internal var _typePrev:Entity;
		/** @private */ internal var _typeNext:Entity;
		/** @private */ internal var _recycleNext:Entity;
		
		// Collision information.
		/** @private */ private const HITBOX:Mask = new Mask;
		/** @private */ private var _mask:Mask;
		/** @private */ private var _x:Number;
		/** @private */ private var _y:Number;
		
		// Rendering information.
		/** @private */ internal var _graphic:Graphic;
		/** @private */ private var _point:Point = FP.point;
		/** @private */ private var _camera:Point = FP.point2;
	}
}