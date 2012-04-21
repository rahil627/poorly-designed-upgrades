package {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.World;
	import objects.graphicsEditor.Canvas;
	import punk.ui.PunkButton;
	import punk.ui.PunkRadioButton;
	import punk.ui.PunkRadioButtonGroup;
	import rahil.Outline;
	
	/**
	 * A graphics editor like Paint, but even more simple.
	 * @author Rahil Patel
	 */
	public class GraphicsEditor extends World {
		
		private var canvas:Canvas;
		private var boosterButton:PunkRadioButton;
		private var selectedPlayerUpgradeBitmapData:BitmapData;
		
		public function GraphicsEditor() {			
			var buttonWidth:int = 75;
			var buttonHeight:int = 25;
			
			var chooseText:Text = new Text("select your upgrade")
			this.addGraphic(chooseText, 0, FP.screen.width / 2 - chooseText.width / 2, 25);
			
			var upgradeRadioButtonGroup:PunkRadioButtonGroup = new PunkRadioButtonGroup(onUpgradeRadioButtonGroupChange);
			
			boosterButton = new PunkRadioButton(upgradeRadioButtonGroup, "booster", 0, 50, buttonWidth, buttonHeight, false, "Booster");
			this.add(boosterButton);
			
			var laserButton:PunkRadioButton = new PunkRadioButton(upgradeRadioButtonGroup, "laser", 0, 75, buttonWidth, buttonHeight, false, "Laser");
			this.add(laserButton);
			
			var homingMissleButton:PunkRadioButton = new PunkRadioButton(upgradeRadioButtonGroup, "homing missle", 100, 50, buttonWidth, buttonHeight, false, "Homing Missle");
			this.add(homingMissleButton);
			
			var explosiveMissleButton:PunkRadioButton = new PunkRadioButton(upgradeRadioButtonGroup, "explosive missle", 100, 75, buttonWidth, buttonHeight, false, "Explosive Missle");
			this.add(explosiveMissleButton);
			
			//var powerSupplyButton:PunkRadioButton = new PunkRadioButton(upgradeRadioButtonGroup, "power supply", 0, 75, buttonWidth, buttonHeight, false, "Power Supply");
			//this.add(powerSupplyButton);
			
			var drawText:Text = new Text("draw your upgrade")
			this.addGraphic(drawText, 0, FP.screen.width / 2 - drawText.width / 2, FP.screen.height / 2 - drawText.height - 35);
			
			canvas = new Canvas(FP.screen.width / 2 - 25, FP.screen.height / 2 - 25);
			this.add(canvas);
			
			//TODO: add a show outline button, or just draw it to screen
			
			var doneButton:PunkButton = new PunkButton(canvas.x + canvas.width + 25, canvas.y + 25, buttonWidth, buttonHeight, "Done", onDoneButtonReleased); //holy shit punk.ui is amazing
			this.add(doneButton); //Exit?
			
			var clearButton:PunkButton = new PunkButton(canvas.x + canvas.width + 25, canvas.y, buttonWidth, buttonHeight, "Clear", onClearButtonReleased);
			this.add(clearButton);
		
			//add some kind of color chooser later (swatches, alpha slider, ARGB textboxes)
			//TODO: can turn the other upgrades to black (or some other color), to get a better view of the current upgrade
			
			//press the default radio button and manually call the onChanged event
			boosterButton.on = true;
			onUpgradeRadioButtonGroupChange(boosterButton.id);
		}
		
		override public function begin():void {
			super.begin();
			FP.screen.color = 0xFF202020; //FlashPunk's default background color
		}
		
		private function onUpgradeRadioButtonGroupChange(radioButtonId:String):void {
			//update the currentBitmap on the canvas
			//used dull, easy to read crayola colors - http://en.wikipedia.org/wiki/List_of_Crayola_crayon_colors
			
			switch (radioButtonId) {
				case "booster":
					canvas.pencilColor = 0xFFFDDB6D/*dandelion*/;
					canvas.bitmapData = Global.player.boosterBitmapData;
					break;
				case "laser":
					canvas.pencilColor = 0xFF1CAC78/*green*/;
					canvas.bitmapData = Global.player.laserGunBitmapData;
					break;
				case "explosive missle":
					canvas.pencilColor = 0xFFCB4154/*brick red*/;
					canvas.bitmapData = Global.player.explosiveMissleGunBitmapData;
					break;
				case "homing missle":
					canvas.pencilColor = 0xFF1F75FE/*blue*/;
					canvas.bitmapData =  Global.player.homingMissleGunBitmapData;
					break;
				case "power supply":
					canvas.pencilColor = 0xFFFFCF48/*sunglow*/;
					canvas.bitmapData = Global.player.powerSupplyBitmapData;
					break;
				default:
					trace("switch error!");
					canvas.bitmapData = null;
			}
		}
		
		override public function update():void {
			super.update();
			
			if (Input.released(Key.U) || Input.released(Key.ESCAPE))
				onDoneButtonReleased();
		}
		
		private function onClearButtonReleased():void {
			canvas.clear();
		}
		
		private function onDoneButtonReleased():void {
			FP.world = Global.sandbox;
		}
		
		override public function end():void {
			super.end();
		}
	}
}