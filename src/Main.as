/* Main TODO list
 *
 * display failure rates? (can at least do it for testing purposes)
 * kill the player? Especially for explosive missle failure, and even homing missle
 * balance by testing each upgrade individually with the secondary damage upgrade out
 *
 * power supply
 * scale the canvas
 * animate everything, enemies move ghostly, the ship and  missles use particle effects to show rocket emissions
 * add sounds, "boom", "clink", "pew"
 * 
 * test isPaused
 * 
 * more guns
 * procedural bomb/special attack
 * particle/spread/bullet/single pixel, gun size affects rate of fire?
 * fractal
 * other effects - see connor ullman's page
 * 
 * more challenges
 * 
 */
package {
	import flash.events.Event;
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	import GraphicsEditor;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import objects.game.Player;
	import rahil.ConnectedComponentLabeling
	
	/**
	 * The Engine.
	 */
	//[SWF(width="960",height="288",frameRate="60")] //didn't do anything for browser embedding!
	public class Main extends Engine {
		
		private var isPaused:Boolean = false;
		
		public function Main():void {
			super(320, 320, 30, false); //was 320/480
			FP.screen.scale = 2;
			
			//for debugging
			//FP.console.enable();
			//FP.volume = 0;
			
			Global.player = new Player(FP.screen.width / 2, FP.screen.height); //player must remain throughout both worlds
			Global.player.y -= Global.player.height;
			Global.sandbox = new Sandbox();
			Global.graphicsEditor = new GraphicsEditor();
			
			FP.world = new TitleScreen(); //TODO: controls screen?
			
			this.addEventListener(Event.ACTIVATE, onActivate)
			this.addEventListener(Event.DEACTIVATE, onDeactivate)
		}
		
		override public function update():void {
			if (Input.pressed(Key.P))
				isPaused = !isPaused;
			
			if (isPaused)
				return;
				
			super.update();
		}
		
		private function onActivate(e:Event):void {
			isPaused = false;
		}
		
		private function onDeactivate(e:Event):void {
			isPaused = true;
		}
	}
}