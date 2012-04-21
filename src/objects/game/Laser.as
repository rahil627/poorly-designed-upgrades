package objects.game {
	import flash.display.BitmapData;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.masks.Pixelmask;
	import rahil.Flash;
	import rahil.FlashPunk;
	
	/**
	 * A standard laser or bullet
	 * @author Rahil Patel
	 */
	public class Laser extends Entity {
		
		private const movementVelocity:int = 120; //120 pixels / second
		
		private var bitmapData:BitmapData;
		private var maxDamage:Number;
		private var damage:Number;
		private var failureRate:Number;
		private var isFailure:Boolean;
		
		public function Laser(x:Number, y:Number, bitmapData:BitmapData, damage:Number, failureRate:Number) {
			super(x, y, new Image(bitmapData), new Pixelmask(bitmapData));
			this.isFailure = Flash.chance(failureRate);
			
			//to use in the copy constructor
			this.bitmapData = bitmapData;
			this.maxDamage = this.damage = damage;
			this.failureRate = failureRate;
		}
		
		public function copy(x:Number, y:Number):Laser { //no function overloading in ActionScript =/
			return new Laser(x, y, this.bitmapData, this.damage, this.failureRate); //note: passing bitmap by reference
		}
		
		override public function update():void {
			super.update();

			this.y -= movementVelocity * FP.elapsed;
			
			if (this.collide("enemy", this.x, this.y)) {
				var enemy:Enemy = this.collide("enemy", this.x, this.y) as Enemy;
				enemy.takeHit(damage);
				this.world.remove(this);
			}
			
			if (FlashPunk.isOffScreen(this.x, this.y + this.height))
				this.world.remove(this);
			
			//failure
			//it becomes more transparent over time and eventually disappears
			if (isFailure) {
				var image:Image = this.graphic as Image;
				image.alpha -= FP.elapsed / 1; //disappear over x seconds
				damage = maxDamage * image.alpha; //loses damage over time
				
				if (image.alpha == 0)
					this.world.remove(this);
			}
		}
	}
}