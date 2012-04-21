package objects.game {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.masks.Pixelmask;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	
	/**
	 * An enemy ship!
	 * @author Rahil Patel
	 */
	public class Enemy extends Entity {
		public var centerX2:Number;
		public var centerY2:Number;

		protected var velocity:Number;
		private var hp:Number;
		private var maxHp:int;
		private var image:Image;
		//private var bitmapData:BitmapData;
		
		/**
		 * Zee constructor!
		 * @param	maxHp
		 * @param	velocity, use 0 for random (default)
		 * @param	x, use 0 for random (default)
		 * @param	y, use 0 for random (default)
		 */
		public function Enemy(maxHp:int = 1, velocity:Number = 0, maxXOffset:Number = 0, yOffset:Number = 0, random:Number = 0) {
			
			image = new Image(Global.GRAPHIC_GHOST);
			//image.angle = 180; //TODO: was causing a problem with the pixel mask, so i just rotated the source image
			image.scale = 1 + maxHp / 400;
			
			super();
			
			if (maxXOffset >= (FP.screen.width - image.scaledWidth)) //prevent multiple challenge spawning off screen
				maxXOffset = FP.screen.width - image.scaledWidth;
			
			this.x = (maxXOffset == 0) ? FP.random * (FP.screen.width - image.scaledWidth) : random * (FP.screen.width - maxXOffset - image.scaledWidth) + FP.random * maxXOffset; //UGLY
			this.y = (yOffset == 0) ? -image.scaledHeight : -image.scaledHeight + yOffset; //or half off screen?
				
			this.graphic = image;
			
			var pixelMaskBitmapData:BitmapData = new BitmapData(image.scaledWidth, image.scaledHeight, true, 0);
			image.render(pixelMaskBitmapData, new Point(), new Point());
			this.mask = new Pixelmask(pixelMaskBitmapData, -image.scaledWidth / 2, -image.scaledHeight / 2);
			
			//center the registration point (origin) to give homing missles an accurate target
			image.centerOrigin();
			
			this.type = "enemy";
			this.velocity = velocity == 0 ? FP.random * 60 : velocity;
			this.hp = this.maxHp = maxHp;
		}
		
		override public function update():void {
			super.update();
			
			this.y += velocity * FP.elapsed;
			
			if (this.y >= FP.screen.height + this.height) {
				if (this.world is Campaign) //TODO: ugly or awesome? How does this.world return Campaign?
					FP.world = Global.sandbox;
				this.world.remove(this);
			}
				
			//bullet/enemy collisions are checked in the bullet classes and use takeHit
			
			if (hp <= 0)
				this.world.remove(this);
				
			//TODO: change color as it dies, would be cool to fill the sprite up with black, radially inverted
		}
		
		public function takeHit(damage:Number = 1):void {
			hp -= damage;
			updateSpriteColor(); //maybe not every hit...max, once per frame
		}
		
		private function updateSpriteColor():void {
			//do later
			
			//ideally would like to fill the sprite with an ocean of black with the elevation indicating hp
			
			//can update the bitmap or just draw to screen
			//for each line of pixels, look for the first black pixel and the last black pixel
			//then set the pixels inbetween to black
			
			//do this according to the percentage of hp
			
			//TODO: better health indicator
			
			//just fade out for now
			Image(this.graphic).alpha = ((20 + hp) / maxHp) * .8; //minimum 20% alpha
			
			//try fade to black instead, I didn't try too hard...
			//var n:Number = hp / maxHp;
			//bitmapData.colorTransform(bitmapData.rect, new ColorTransform(1, 1, 1, 1, n * 255, n * 255, n * 255, 0));
			//var image2:Image = new Image(bitmapData);
			//image2.scale = image.scale;
			//image2.alpha = 1 - (((20 + hp) / maxHp) * .8);
			//this.graphic = image2;
		}
	}
}