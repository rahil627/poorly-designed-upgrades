package objects.game {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.masks.Pixelmask;
	import rahil.Flash;
	import rahil.FlashPunk;
	
	/**
	 * A homing/guided missle
	 * @author Matt McFarland and Rahil Patel
	 */
	public class HomingMissile extends Entity {
		private const TURN_SPEED:Number = 150; //100 pixels per second
		private const SPEED:Number = 200; //velocity, 200 pixels per second?
		private const LIFE:Number = 2;
		private var lifeTimer:Number = 0;
		private var vx:Number;
		private var vy:Number;
		private var angle:Number = 180;
		private var target:Entity;
		private var image:Image;
		
		private var failureRate:Number;
		private var isFailure:Boolean
		private var scaleFactor:Number;
		private var damage:Number;
		private var timer:Number = 0;
		private var misfireTime:Number;
		private var offScreenTimer:Number = 0;
		private var randomAngle:Number;
		private var isTurning:Boolean = false;
		
		public function HomingMissile(x:Number, y:Number, failureRate:Number, scaleFactor:Number, damage:Number, angleOffset:Number = 0) {
			super(x, y);
			image = new Image(Global.GRAPHIC_HOMING_MISSLE);
			image.scale = scaleFactor; //make the bitmap is the smallest possible size, then ensure this is > 1
			this.graphic = image;
			
			var pixelMaskBitmapData:BitmapData = new BitmapData(image.scaledWidth, image.scaledHeight, true, 0);
			image.render(pixelMaskBitmapData, new Point(), new Point());
			this.mask = new Pixelmask(pixelMaskBitmapData);
			
			this.isFailure = Flash.chance(failureRate);
			misfireTime = .1 + FP.random * .3;
			randomAngle = FP.random * 360;
			
			//to use in the copy constructor
			this.failureRate = failureRate;
			this.scaleFactor = scaleFactor;
			this.damage = damage;
			
			//variables used after defining the missle
			angle = 180 + angleOffset;
		}
		
		public function copy(x:Number, y:Number, angleOffset:Number):HomingMissile {
			return new HomingMissile(x, y, this.failureRate, this.scaleFactor, this.damage, angleOffset);
		}
		
		override public function update():void {
			super.update();
			timer += FP.elapsed;
			
			//get new target
			if (!target)
				getNewTarget();
			if (target)
				turnTowardsTarget();
				
			//move at an angle
			vx = SPEED * Math.sin(image.angle * Flash.RADIAN) * FP.elapsed;
			vy = SPEED * Math.cos(image.angle * Flash.RADIAN) * FP.elapsed;
			x += vx;
			y += vy;
			
			//This code rotates the images angle to the angle property of the missile
			//image.angle = angle; //moved below
			
			//If the missile is 30 pixels away from any enemy, detonate
			//var e:Entity = world.nearestToEntity("enemy", this);
			//if (e){
				//if (distanceFrom(e) < 30)
					//detonate();
			//}
			
			if (this.collide("enemy", this.x, this.y)) {
				var enemy:Enemy = this.collide("enemy", this.x, this.y) as Enemy;
				enemy.takeHit(damage);
				detonate();
			}
				
			//failure
			//AI failure
			//at some point in time, choose a random angle and go straight in that direction
			if (isFailure && timer >= misfireTime) {
				image.angle = randomAngle; //TODO: ghetto, would be better to set to a random target off screen
			}
			else {
				image.angle = angle;
			}
			
			//remove if off screen for 5 seconds
			if (FlashPunk.isOffScreen(this.x, this.y) && isFailure)
				offScreenTimer += FP.elapsed;
			
			if (offScreenTimer >= 5)
				this.world.remove(this);
				
			//TODO: might be CPU/GPU intensive
			//recreate the PixelMask
			var pixelMaskBitmapData:BitmapData = new BitmapData(image.scaledWidth, image.scaledHeight, true, 0);
			image.render(pixelMaskBitmapData, new Point(image.scaledWidth / 2, image.scaledHeight / 2), FP.camera);
			this.mask = new Pixelmask(pixelMaskBitmapData, -image.scaledWidth / 2, -image.scaledHeight / 2);
		}
		
		private function getNewTarget():void {
			target = world.nearestToEntity("enemy", this);
		}
		
		//The turnTowardsTarget method tells the missile to turn either left or right at its turnspeed.
		private function turnTowardsTarget():void {
			
			//vector of homing missle's current direction
			var xa:Number = Math.sin(image.angle * Flash.RADIAN);
			var ya:Number = Math.cos(image.angle * Flash.RADIAN);
			
			//vector pointing from missile to target
			var xb:Number = (target.x + target.originX - x);
			var yb:Number = (target.y + target.originY - y);
			
			//from http://www.helixsoft.nl/articles/circle/sincos.htm
			//cos (angle) = (xa * xb + ya * yb) / (length (a) * length (b))
			//rotate by 90 degrees
			//(ya * xb - xa * yb)
			
			//algorithm:
			//turn toward target
			//once the angle is within some threshold, do not turn until the angle is off by some threshold
			
			var z:Number = (ya * xb - xa * yb);// % 360;
			//trace("z: " + z);
			
			if (z > -2.5 && z < 2.5)
				isTurning = false;
				
			if (z < -20 || z > 20)
				isTurning = true;
				
			if (z > 0 && isTurning)
				angle += TURN_SPEED * FP.elapsed;
			else if (z < 0 && isTurning)
				angle -= TURN_SPEED * FP.elapsed;
		}
		
		private function detonate():void {
			this.world.add(new Explosion(x, y, 5, 0)); //no damage from explosion
			this.world.remove(this);
		}
	}
}