package objects.game {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.masks.Pixelmask;
	import rahil.Flash
	import rahil.FlashPunk;
	
	/**
	 * A missle that explodes upon enemy collision
	 * @author Rahil Patel
	 */
	public class ExplosiveMissle extends Entity { //TODO: rename to ExplosiveMissleFactory?
		
		private const movementVelocity:int = 30;
		private var explosionRadius:int;
		private var failureRate:Number;
		private var isFailure:Boolean;
		private var failureType:int = 0; //enum: 1 = dud, 2 = misfire 
		private var scaleFactor:Number;
		private var timer:Number = 0;
		private var damage:Number;
		private var misfireTime:Number;
		private var image:Image;
		
		public function ExplosiveMissle(x:Number = 0, y:Number = 0, explosionRadius:int = 10, failureRate:Number = 0, scaleFactor:Number = 1, damage:Number = 1, angleOffset:Number = 0) {
			super(x, y);
			image = new Image(Global.GRAPHIC_EXPLOSIVE_MISSLE);
			image.scale = scaleFactor; //ensure the bitmap is the smallest possible size, then ensure this is > 1
			this.graphic = image;
			
			var pixelMaskBitmapData:BitmapData = new BitmapData(image.scaledWidth, image.scaledHeight, true, 0);
			image.render(pixelMaskBitmapData, new Point(), new Point());
			this.mask = new Pixelmask(pixelMaskBitmapData, -image.scaledWidth / 2, -image.scaledHeight / 2);
			
			//center the registration point (origin) in order to rotate correctly
			image.centerOrigin();
			
			this.failureRate = failureRate;
			isFailure = Flash.chance(failureRate);
			if (isFailure)
				this.failureType = Flash.randomNumber(1, 2);
				
			misfireTime = 1 + FP.random * 5;
			
			//for the copy constructor
			this.explosionRadius = explosionRadius;
			this.failureRate = failureRate;
			this.scaleFactor = scaleFactor;
			this.damage = damage;
			
			//variables used after defining the missle
			image.angle = 180 + angleOffset;
		}
		
		public function copy(x:Number, y:Number, angleOffset:Number):ExplosiveMissle {
			return new ExplosiveMissle(x, y, this.explosionRadius, this.failureRate, this.scaleFactor, this.damage, angleOffset);
		}
		
		override public function update():void {
			super.update();
			timer += FP.elapsed;
			
			//this.y -= movementVelocity * FP.elapsed;
			
			this.x += movementVelocity * Math.sin(image.angle * Flash.RADIAN) * FP.elapsed;
			this.y += movementVelocity * Math.cos(image.angle * Flash.RADIAN) * FP.elapsed;
			
			if (this.collide("enemy", this.x, this.y)) {
				if (isFailure /*&& failureType == 1*/) { //hmm, also reminds me of Segin
					//add a "clink" dud noise
					this.world.remove(this);
				}
				else
					detonate();
			}
			
			//misfire still damages enemies, so it's not really a bad thing, unless the player dies, but then agian, the homing missle sometimes hits the enemy too
			
			//spin out of control before detonating
			if (isFailure && failureType == 2 && timer > misfireTime * .8)
				image.angle = FP.random * 360;
			
			//misfire/detonate
			if (isFailure && failureType == 2 && timer > misfireTime) 
				detonate();
			
			if (FlashPunk.isOffScreen(this.x, this.y + this.height)) //TODO: dunno how this.height is set
				this.world.remove(this);
		}
		
		private function detonate():void {
			this.world.add(new Explosion(x, y, explosionRadius, damage));
			this.world.remove(this);
		}
	}
}