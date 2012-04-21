package {
	import flash.geom.Rectangle;
	import flash.globalization.DateTimeFormatter;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.World;
	import objects.game.Enemy;
	import punk.ui.PunkButton;
	import rahil.Flash;
	
	/**
	 * A world full of challenges!
	 * @author Rahil Patel
	 */
	public class Campaign extends World {
		
		private var challengeNumber:int;
		private var challengeText:Text;
		private var _timer:Number = 0;
		private var timerText:Text;
		
		private var enemyTimer:Number = 15; //ugly, to start the first wave immediately
		private var enemyVelocity:Number = 10;
		private var enemySpawnRate:Number = .30;
		private var numberOfEnemies:int = 5;
		private var maxXOffset:Number = 10;
		private var maxYOffset:Number = -10;
		private var enemyHp:Number = 1;
		
		public function Campaign(challengeNumber:int) {
			super();
			//Global.campaign = this;
			
			this.challengeNumber = challengeNumber;
			
			challengeText = new Text("challengeText");
			challengeText.color = 0x000000;
			this.addGraphic(challengeText, 0, 0, FP.screen.height - 20);
			
			timerText = new Text("timerText");
			timerText.color = 0x000000;
			this.addGraphic(timerText, 0, 0, FP.screen.height - 40);
		
			//could init vars here
		}
		
		override public function begin():void {
			super.begin();
			
			FP.screen.color = 0xF8F8FF;//ghost white
			this.add(Global.player);
		}
		
		override public function update():void {
			super.update();
			
			timer = timer + FP.elapsed;
			enemyTimer += FP.elapsed;
			
			if (Input.released(Key.ESCAPE))
				FP.world = Global.sandbox;
			
			//display timer, highest time for each challenge!
			
			switch (challengeNumber){
				case 1: 
					updateChallenge1();
					break;
				case 2: 
					updateChallenge2();
					break;
				case 3: 
					updateChallenge3();
					break;
			}
		
			//if an enemy passes by, you lose, added the code to Enemy
		
			//if you fail or succeed, go to sandbox world
		}
		
		override public function end():void {
			super.end();
			this.removeAll();
			
			//save high scores
			switch (challengeNumber) {
				case 1: Global.challenge1HighScore = timer; break;
				case 2: Global.challenge2HighScore = timer; break;
				case 3: Global.challenge3HighScore = timer; break;
			}
		}
		
		private function updateChallenge1():void {
			challengeText.text = "fast"; //nice! reference works
			//incrementally increase velocity
			
			if (enemyTimer >= 2) {
				enemyVelocity *= 1.1;
				this.add(new Enemy(1, enemyVelocity));
				enemyTimer = 0;
			}
		}
		
		private function updateChallenge2():void {
			challengeText.text = "multiple"; //"groups"
			//spawn groups of enemies, incrementally increase in size
			//should be grouped together, not separate, x and y
			
			//only for 4 seconds out of every 10 seconds
			//if (timer % 10 >= 2)
				//return;
				
			var enemies:Array = new Array();
			this.getType("enemy", enemies);
			if (enemies.length != 0) {
				return;
			}
			
			//old method, spawning only at the top of the screen
			//if (enemyTimer >= enemySpawnRate) {
				//this.add(new Enemy(1, 15));
				//enemyTimer = 0;
				//enemySpawnRate *= .90;
			//}
			
			//new method, spawn beyond the top of the screen, within a rectangular area
			//should have used a rectangle
			
			var random:Number = FP.random;
			for (var i:int = 0; i < numberOfEnemies; i++)
				this.add(new Enemy(1, 15, maxXOffset, FP.random * maxYOffset, random));
			
			//increase spawn area size
			maxXOffset *= 1.5;
			maxYOffset *= 1.5;
			//increase number of enemies spawned
			numberOfEnemies *= 1.5; //hopefully it rounds
		}
		
		private function updateChallenge3():void {
			challengeText.text = "high HP";
			
			var enemies:Array = new Array();
			this.getType("enemy", enemies);
			if (enemies.length != 0) { //TODO: add a wait time between waves?
				return;
			}
			
			this.add(new Enemy(enemyHp, 15));
			enemyHp *= 5;
		}
		
		//TODO: challenge 5, run all of the challenges seperately, triatholon!, 5 seconds of each one, rotating?
		
		//TODO: challenge 6, combine all challenges, enemies increase in speed, hp, and groups?
		
		public function get timer():Number {
			return _timer;
		}
		
		public function set timer(value:Number):void {
			_timer = value;
			timerText.text = "Time: " + timer.toFixed();
		}
	}
}