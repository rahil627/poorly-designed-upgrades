package objects.game {
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.tweens.motion.LinearMotion;
	
	/**
	 * A puff of smoke that appears when the player's ship stalls
	 * @author Rahil Patel
	 */
	public class Smoke extends Entity {
		private var tween:LinearMotion;
		
		public function Smoke(x:Number, y:Number) {
			super(x, y, new Image(Global.GRAPHIC_SMOKE));
			
			tween = new LinearMotion(onComplete)
			tween.setMotion(x, y, x, y + 25, 1);
			this.addTween(tween);
		}
		
		override public function update():void {
			super.update();
			
			this.y = tween.y;
		}
		
		private function onComplete():void {
			this.world.remove(this);
		}
	}
}