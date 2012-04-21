package {
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.World;
	import objects.game.Enemy;
	import punk.ui.PunkButton
	
	/**
	 * The Game World!
	 * @author Rahil Patel
	 */
	public class Sandbox extends World {
		
		private var currentLevel:int = 0;
		private var timer:Number = 0;
		
		private var _enemyHp:int = 1;
		private var enemyHpText:Text;
		private var _enemySpawnRate:Number = 3;
		private var enemySpawnRateText:Text;
		
		private var challenge1HighScore:Text;
		private var challenge2HighScore:Text;
		private var challenge3HighScore:Text;
		private var challenge4HighScore:Text;
		
		public function Sandbox(){
			super();
			Global.sandbox = this;
			
			//add the interface
			
			//add texts
			enemyHpText = new Text("Enemy HP: 0" + enemyHp.toString());
			enemyHpText.color = 0x000000
			var textHeight:int = enemyHpText.height;
			this.addGraphic(enemyHpText, 1000, 50, FP.screen.height - 25);
			enemyHp = 1;
			
			enemySpawnRateText = new Text("Spawn Rate: 0" + _enemySpawnRate.toString());
			enemySpawnRateText.color = 0x000000
			this.addGraphic(enemySpawnRateText, 1000, 50, FP.screen.height - 50);
			enemySpawnRate = 3;
			
			//add buttons
			var minusEnemyHpButton:PunkButton = new PunkButton(0, FP.screen.height - 25, 25, 25, "-", onMinusEnemyHpButtonReleased);
			this.add(minusEnemyHpButton);
			
			var plusEnemyHpButton:PunkButton = new PunkButton(25, FP.screen.height - 25, 25, 25, "+", onPlusEnemyHpButtonReleased);
			this.add(plusEnemyHpButton);
			
			var upgradeButton:PunkButton = new PunkButton(FP.screen.width - 75, FP.screen.height - 25, 75, 25, "Upgrade", onUpgradeButtonReleased);
			this.add(upgradeButton);
			
			var minusEnemySpawnRateButton:PunkButton = new PunkButton(0, FP.screen.height - 50, 25, 25, "[", onMinusEnemySpawnRateButtonReleased);
			this.add(minusEnemySpawnRateButton);
			
			var plusEnemySpawnRateButton:PunkButton = new PunkButton(25, FP.screen.height - 50, 25, 25, "]", onPlusEnemySpawnRateButtonReleased);
			this.add(plusEnemySpawnRateButton);
			
			//add high scores
			var challengeText:Text = new Text("High Scores");
			challengeText.color = 0x000000;
			this.addGraphic(challengeText, 1000, 0, textHeight * 0);
			
			//need an array of high scores, or just use one Text object with a long string
			challenge1HighScore = new Text("1: " + Global.challenge1HighScore.toString());
			challenge1HighScore.color = 0x000000;
			this.addGraphic(challenge1HighScore, 1000, 0, textHeight * 1);
			
			challenge2HighScore = new Text("2: " + Global.challenge2HighScore.toString());
			challenge2HighScore.color = 0x000000;
			this.addGraphic(challenge2HighScore, 1000, 0, textHeight * 2);
			
			challenge3HighScore = new Text("3: " + Global.challenge3HighScore.toString());
			challenge3HighScore.color = 0x000000;
			this.addGraphic(challenge3HighScore, 1000, 0, textHeight * 3);
		}
		
		override public function begin():void {
			super.begin();
			
			FP.screen.color = 0xF0F0DD; //off-white
			this.add(Global.player);
			
			//get high scores
			challenge1HighScore.text = ("1: " + Global.challenge1HighScore.toString());
			challenge2HighScore.text = ("2: " + Global.challenge2HighScore.toString());
			challenge3HighScore.text = ("3: " + Global.challenge3HighScore.toString());
		}
		
		override public function update():void {
			super.update();
			
			timer += FP.elapsed;
			
			if (Input.released(Key.U))
				onUpgradeButtonReleased();
			
			if (Input.check(Key.PLUS))
				onPlusEnemyHpButtonReleased();
			
			if (Input.check(Key.MINUS))
				onMinusEnemyHpButtonReleased();
			
			if (Input.check(Key.LEFT_SQUARE_BRACKET))
				onMinusEnemySpawnRateButtonReleased();
			
			if (Input.check(Key.RIGHT_SQUARE_BRACKET))
				onPlusEnemySpawnRateButtonReleased();
				
			//procedurally add enemies
			if (timer > enemySpawnRate) {
				this.add(new Enemy(enemyHp));
				timer -= enemySpawnRate;
			}
			
			//start a challenge
			if (Input.released(Key.DIGIT_1))
				FP.world = new Campaign(1); //these get garbage collected (after some time)!
			if (Input.released(Key.DIGIT_2))
				FP.world = new Campaign(2);
			if (Input.released(Key.DIGIT_3))
				FP.world = new Campaign(3);
		}
		
		override public function end():void {
			super.end();
			
			this.remove(Global.player);
			
			//remove all enemies
			var enemyArray:Array = new Array();
			getType("enemy", enemyArray);
			for each (var enemy:Enemy in enemyArray)
				this.remove(enemy);
		
		}
		
		//button events
		private function onUpgradeButtonReleased():void {
			FP.world = Global.graphicsEditor;
		}
		
		private function onMinusEnemyHpButtonReleased():void {
			if (enemyHp > 10)
				enemyHp -= 10
		}
		
		private function onPlusEnemyHpButtonReleased():void {
			enemyHp += 10
		}
		
		private function onMinusEnemySpawnRateButtonReleased():void {
			if (enemySpawnRate > .10)
				enemySpawnRate -= .10
		}
		
		private function onPlusEnemySpawnRateButtonReleased():void {
			enemySpawnRate += .10
		}
		
		//properties
		public function get enemyHp():int {
			return _enemyHp;
		}
		
		public function set enemyHp(value:int):void {
			_enemyHp = value;
			enemyHpText.text = "Enemy HP: " + enemyHp.toString();
		}
		
		public function get enemySpawnRate():Number {
			return _enemySpawnRate;
		}
		
		public function set enemySpawnRate(value:Number):void {
			_enemySpawnRate = value;
			enemySpawnRateText.text = "Spawn: " + enemySpawnRate.toFixed(2);
		}
	}
}