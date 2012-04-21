package objects.graphicsEditor {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.utils.Draw;
	import net.flashpunk.utils.Input;
	import rahil.Outline;
	
	/**
	 * The canvas onto which the player draws upgrades.
	 * @author Rahil Patel
	 */
	public class Canvas extends Entity {
		
		private var _bitmapData:BitmapData; //the bitmap that the canvas draws on //TODO: ended up not even using it
		private var image:Image;
		private var border:BitmapData;
		private var background:BitmapData;
		public var pencilColor:uint;
		private const shipBitmapData:BitmapData = FP.getBitmap(Global.GRAPHIC_PLAYER);
		private var combinedUpgradesWithShipBitmapData:BitmapData;
		
		public function Canvas(x:Number = 0, y:Number = 0) {
			super(x, y);
			bitmapData = new BitmapData(50, 50, true, 0x000000); //should get width and height from player bitmap
			image = new Image(bitmapData);
			//image.scale = 3; //TODO: This one will take some time, have to scale this.graphic every time, the outlines, the and the border. Also have to draw pixel 2x2 or 3x3 squares
			this.graphic = image;
			
			//create a border for the canvas, should be drawn to buffer because it goes out of bounds of this entity
			border = new BitmapData(FP.screen.width, FP.screen.height, true, 0);
			Draw.setTarget(border);
			Draw.rectPlus(x - 1, y - 1, 51, 51, 0x00FF00, 1, false, 1);
			Draw.resetTarget();
			
			//create a background for the canvas
			//background = new BitmapData(FP.screen.width, FP.screen.height, true, 0);
			//Draw.setTarget(border);
			//Draw.rectPlus(x, y, 50, 50, 0xF8F8FF, 1, true);
			//Draw.resetTarget();
			
			//create the current ship and render it - see render function
			combinedUpgradesWithShipBitmapData = new BitmapData(FP.screen.width, FP.screen.height, true, 0);
			
			//normally used for hitbox, but I'm using this as reference for the width and height
			this.width = this.height = 51;
			
			//TODO: able to scale just the canvas?
			
			//TODO: add a pixel grid? Should be sorta transparent
		}
		
		private var point:Point;
		
		override public function update():void {
			super.update();
			
			var point:Point = new Point(Input.mouseX - this.x, Input.mouseY - this.y);
			
			//allow the player to draw, very simple, single pixel drawing
			if (Input.mouseDown
				&& Input.mouseX > this.x && Input.mouseX < this.x + bitmapData.width
				&& Input.mouseY > this.y && Input.mouseY < this.y + bitmapData.height) { //if clicked in the canvas
				
				//if color is ship
				if (FP.buffer.getPixel32(Input.mouseX, Input.mouseY) == uint(0xFFFFFFFF) ||
					FP.buffer.getPixel32(Input.mouseX, Input.mouseY) == uint(0xFF000000)) {
					drawPixel();
					return;
				}
				
				//color must be background color
				if (FP.buffer.getPixel32(Input.mouseX, Input.mouseY) !=  FP.screen.color)
					return;
					
				//if neighboring ship
				//TODO: could have used pixel mask and collide/hittest with current point
				var shipOutline:Outline = new Outline(shipBitmapData);
				for each (var shipOutlinePoint:Point in shipOutline.points) {
					if (Point.distance(point, shipOutlinePoint) < 2) {
						drawPixel();
						return;
					}
				}
				
				//if neighboring bitmap
				var bitmapDataOutline:Outline = new Outline(bitmapData);
				for each (var bitmapDataPoint:Point in bitmapDataOutline.points) {
					if (Point.distance(point, bitmapDataPoint) < 2) {
						drawPixel();
						return;
					}
				}
			}
		}
		
		override public function render():void {
			//FP.buffer.draw(background);
			
			FP.buffer.draw(border); //render the border to the screen
			
			//reload and render the current ship //TODO: load only after a change	
			combinedUpgradesWithShipBitmapData.copyPixels(Global.player.combinedUpgradesWithShipBitmapData, Global.player.combinedUpgradesWithShipBitmapData.rect, new Point(this.x, this.y));
			FP.buffer.draw(combinedUpgradesWithShipBitmapData);
			
			//super.render(); //render this.graphic, TODO: am now drawing directly to the graphic
		}
		
		private function drawPixel():void {
			bitmapData.setPixel32(Input.mouseX - this.x, Input.mouseY - this.y, pencilColor); //can use lock/unlock if having fps problems
			
			image = new Image(_bitmapData);
			image.scale = 3;
			this.graphic = new Image(bitmapData); //not needed until the end, could render, then save
		}
		
		public function clear():void {
			bitmapData.fillRect(bitmapData.rect, 0x00000000);
			this.graphic = new Image(bitmapData);
		}
		
		public function get bitmapData():BitmapData {
			return _bitmapData;
		}
		
		public function set bitmapData(value:BitmapData):void {
			_bitmapData = value;
			this.graphic = new Image(bitmapData);
		}
	}
}