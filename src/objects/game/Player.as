package objects.game {
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.masks.Pixelmask;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import rahil.ConnectedComponent;
	import rahil.ConnectedComponentLabeling;
	import rahil.Flash;
	import rahil.FlashPunk;
	
	/**
	 * The player's controllable entity.
	 * @author Rahil Patel
	 */
	public class Player extends Entity {
		
		private var image:Image;
		
		private var movementVelocity:Number;
		private var horizontalImbalanceVelocity:Number; //offsetVx
		private var verticalImbalanceVelocity:Number;
		
		public var boosterBitmapData:BitmapData;
		public var laserGunBitmapData:BitmapData;
		public var explosiveMissleGunBitmapData:BitmapData;
		public var homingMissleGunBitmapData:BitmapData;
		public var powerSupplyBitmapData:BitmapData;
		private var _combinedUpgradesBitmapData:BitmapData;
		private var _combinedUpgradesWithShipBitmapData:BitmapData;
		
		private var generatedLasers:Array
		private var generatedExplosiveMissles:Array;
		private var generatedHomingMissles:Array;
		
		private var power:Number;
		private var numberOfPixelsInAllUpgrades:uint;
		
		public function Player(x:Number = 0, y:Number = 0) {
			super(x, y, image = new Image(Global.GRAPHIC_PLAYER), new Pixelmask(Global.GRAPHIC_PLAYER));
			this.type = "player";
			
			//init the upgrade bitmaps
			boosterBitmapData = new BitmapData(50, 50, true, 0);
			laserGunBitmapData = FP.getBitmap(Global.GRAPHIC_LASER_GUN); //default laser gun, TODO: source.bitmapData? How does that work
			homingMissleGunBitmapData = new BitmapData(50, 50, true, 0);
			explosiveMissleGunBitmapData = new BitmapData(50, 50, true, 0);
			powerSupplyBitmapData = new BitmapData(50, 50, true, 0);
			
			_combinedUpgradesBitmapData = new BitmapData(50, 50, true, 0);
			_combinedUpgradesWithShipBitmapData = new BitmapData(50, 50, true, 0);
		}
		
		override public function added():void {
			super.added();
			
			//fetch the upgrade graphics, combine the ship with all of the upgrades, and create a pixel mask
			this.graphic = new Image(combinedUpgradesWithShipBitmapData);
			this.mask = new Pixelmask(combinedUpgradesWithShipBitmapData);
			
			//make adjustments according to the upgrades
			adjustWeight(combinedUpgradesBitmapData); //does this run the get function?
			setPower(combinedUpgradesBitmapData);
			adjustShipAccordingToBoosterGraphic();
			generateLaser();
			generateExplosiveMissles();
			generateHomingMissles();
			//adjustShipAccordingToPowerSupplyGraphic(); //TODO: don't implement power supply yet...
		}
		
		private function adjustWeight(bitmapData:BitmapData):void {
			//adjust horizontalVelocity based on the difference of the number of pixels in the right half and left half
			//-4/+4 to ignore the center area
			var numberOfPixelsInLeftHalf:uint = Flash.numberOfPixelsInVector(bitmapData.getVector(new Rectangle(0, 0, bitmapData.width / 2 - 4, bitmapData.height)));
			var numberOfPixelsInRightHalf:uint = Flash.numberOfPixelsInVector(bitmapData.getVector(new Rectangle(bitmapData.width / 2 + 4, 0, bitmapData.width / 2 - 4, bitmapData.height)));
			
			var difference:Number = numberOfPixelsInRightHalf - numberOfPixelsInLeftHalf;
			var sign:int = Flash.sign(difference);
			
			horizontalImbalanceVelocity = 0;
			if (Math.abs(difference) > 10) //threshold
				horizontalImbalanceVelocity = (Math.abs(difference) - 10) / 20 * sign;
			
			//adjust verticalVelocity based on the difference of the number of pixels in the top half and bottom half
			var numberOfPixelsInTopHalf:uint = Flash.numberOfPixelsInVector(bitmapData.getVector(new Rectangle(0, 0, bitmapData.width, bitmapData.height / 2 - 3)));
			var numberOfPixelsInBottomHalf:uint = Flash.numberOfPixelsInVector(bitmapData.getVector(new Rectangle(0, bitmapData.height / 2 + 3, bitmapData.width, bitmapData.height / 2 - 3)));
			
			difference = numberOfPixelsInBottomHalf - numberOfPixelsInTopHalf;
			sign = Flash.sign(difference);
			
			verticalImbalanceVelocity = 0;
			if (Math.abs(difference) > 10) //threshold
				verticalImbalanceVelocity = (Math.abs(difference) - 10) /*/ 20*/ * sign;
		}
		
		private function setPower(combinedUpgradesBitmapData:BitmapData):void {
			//power directly affects the failure rate of all upgrades
			//the more pixels used for upgrades, the higher the failure rate
			//should have enough for half full upgrades (near 0% failure rate) half of everything
			
			//get the total number of pixels of all upgrades
			numberOfPixelsInAllUpgrades = Flash.numberOfPixelsInBitmapData(combinedUpgradesBitmapData);
			trace("number of pixels in all upgrades: " + numberOfPixelsInAllUpgrades);
			
			//set power
			
			//using a limit function, (x-c)/x
			
			//special case
			if (numberOfPixelsInAllUpgrades < 24) //play with the constant to balance, see http://rechneronline.de/function-graphs/
				power = 1;
			else
				power = 1 - ((numberOfPixelsInAllUpgrades - 24)/numberOfPixelsInAllUpgrades)
			trace("Power: " + power);
		}
		
		private function calculateFailureRateForUpgrade(numberOfPixelsInUpgrade:int):Number { //TODO: should have used SucessRate
			//special cases
			
			//if no upgrades or no penalty
			if (numberOfPixelsInUpgrade == 0 || power == 1)
				return 0;
			
			//if one upgrade
			if (numberOfPixelsInUpgrade == numberOfPixelsInAllUpgrades)
				return 1 - power;
				
			trace("number of pixels in this upgrade: " + numberOfPixelsInUpgrade);
			
			//very important to have the largest upgrade to have the lowest failure rate
			return (1 - numberOfPixelsInUpgrade / numberOfPixelsInAllUpgrades) * (1 - power);
			
			//1 - 1/10 = 9/10
			//1 - 2/10 = 8/10
			//1 - 7/10 = 3/10
			
			//1 - 4/10 = 6/10
			//1 - 6/10 = 4/10
		}
		
		private function adjustShipAccordingToBoosterGraphic():void {
			//increase velocity depending on the number of pixels
			var numberOfPixelsInUpgrade:uint = Flash.numberOfPixelsInBitmapData(boosterBitmapData);
			
			movementVelocity = 60 /*default velocity*/ + numberOfPixelsInUpgrade * 5;
			//TODO:*** add and adjust acceleration? Would be cool!
			
			if (numberOfPixelsInUpgrade == 0) {
				boosterFailureRate = 0;
				return;
			}
			
			var failureRate:Number = calculateFailureRateForUpgrade(numberOfPixelsInUpgrade);
			
			boosterFailureRate = failureRate;
			trace("booster FR: " + failureRate);

			//all of the above code works for zero case
			
			//failure
			//the ship stalls
			//a puff shoots out of the back of the ship
			//there is a chance, that while moving the ship stalls
			//over some interval the player is moving the ship, roll the dice
			//ship stalls for a fixed amount of time (for now)
			//currently in the upate function
		}
		
		private function generateLaser():void {
			//if gun does not exist, do not fire
			if (Flash.numberOfPixelsInBitmapData(laserGunBitmapData) == 0) {
				generatedLasers = null;
				return;
			}
			
			generatedLasers = new Array();
			laserFireRates = new Array(); //could store in Laser
			laserFireTimers = new Array();
			
			//get number of pixel groups
			var c:ConnectedComponentLabeling = new ConnectedComponentLabeling(laserGunBitmapData);
			var guns:Vector.<ConnectedComponent> = c.connectedComponents;
			
			trace("laser gun sizes: " + guns);
			
			for each (var gun:ConnectedComponent in guns) {
				
				trace ("laser gun size: " + gun.size);
				
				//generate the laser graphic based on the laser gun
				var laserBitmapData:BitmapData = gun.bitmapData;
				
				//paint it black
				laserBitmapData.colorTransform(laserBitmapData.rect, new ColorTransform(0, 0, 0, 1));
				
				//secondary damage, more damage increase, rate of fire, and comment the above line out
				var fireRate:Number = laserFireRate / gun.size; //laserFireRate is the base, TODO: temp expression
				laserFireRates.push(fireRate); //sloppy, but could not put it in generatedLasers/Laser class. The index matches generated lasers
				
				//use a limit function again?
				
				//gun size affects damage
				var damage:Number = gun.size * fireRate;
				//trace("dps: " + damage * fireRate);
				
				var laserFiretimer:Number = .5;
				laserFireTimers.push(laserFiretimer);
				
				var failureRate:Number = calculateFailureRateForUpgrade(gun.size);
				trace("laser FR: " + failureRate);
				
				generatedLasers.push(new Laser(0, 0, laserBitmapData, damage, failureRate));
			}
			
			//TODO: should each pixel count as a laser? Each one taking 1 hp? Rename it to particle beam
			//for each pixel in laserGun bitmap, add a laser (might need to use particle class)
			//need to loop through each pixel location and set that as the x and y coordinate of the laser
		}
		
		private function generateExplosiveMissles():void {
			//if gun does not exist, do not fire
			if (Flash.numberOfPixelsInBitmapData(explosiveMissleGunBitmapData) == 0) {
				generatedExplosiveMissles = null;
				return;
			}
			
			generatedExplosiveMissles = new Array();
			
			//get number of pixel groups
			var c:ConnectedComponentLabeling = new ConnectedComponentLabeling(explosiveMissleGunBitmapData);
			var guns:Vector.<ConnectedComponent> = c.connectedComponents;
			
			trace("explosive missle gun sizes: " + guns);
			
			//add an explosiveMissleFactory for each gun, should use factory/definition like Box2D
			for each (var gun:ConnectedComponent in guns) {
				//size of gun affects damage of missle
				var damage:int = gun.size;
				
				//size of gun affects size of missle
				var scaleFactor:Number = 1 + gun.size / 15;
				
				//secondary damage increase, size of gun affects size of explosion, do this after base balancing
				var explosionRadius:Number = 5 + gun.size * 2;
				
				//size of gun affects length of explosion?
				
				//size of gun affects the failureRate
				var failureRate:Number = calculateFailureRateForUpgrade(gun.size); //failure can be dud or early detonation
				trace("explosive FR: " + failureRate);
				
				generatedExplosiveMissles.push(new ExplosiveMissle(0, 0, explosionRadius, failureRate, scaleFactor, damage));
			}
			
			//generatedExplosiveMissle = new ExplosiveMissle(0, 0, explosionRadius, failureRate, scaleFactor, damage);
		}
		
		private function generateHomingMissles():void {			
			
			//if the gun size is < 10, the failure rate is going to be very high
			
			//if gun does not exist, do not fire
			if (Flash.numberOfPixelsInBitmapData(homingMissleGunBitmapData) == 0) {
				generatedHomingMissles = null;
				return;
			}
			
			generatedHomingMissles = new Array();
			
			//get number of pixel groups
			var c:ConnectedComponentLabeling = new ConnectedComponentLabeling(homingMissleGunBitmapData);
			var guns:Vector.<ConnectedComponent> = c.connectedComponents;
			
			trace("homing missle gun sizes: " + guns);
			
			//add a homingMissleFactory for each gun
			for each (var gun:ConnectedComponent in guns) {
				var failureRate:Number = calculateFailureRateForUpgrade(gun.size);
				trace("homing FR: " + failureRate);
				
				//gun size affects missle damage
				var damage:Number = gun.size;
				
				//size of gun affects size of missle
				var scaleFactor:Number = 1 + gun.size / 15;
				
				//might not need a secondary damage since homing missles do not disappear if not used
					
				generatedHomingMissles.push(new HomingMissile(0, 0, failureRate, scaleFactor, damage));
			}
		}
		
		private function adjustShipAccordingToPowerSupplyGraphic():void {
			//depending on the size of the power supply, decrease speed, decrease failure rate?
			//should be a failure rate for the power supply itself! All of the guns stall.
		}
		
		private var timer:Number = 0;
		
		//to shoot weapons at different times
		//private var laserFireTimer:Number = .5;
		private var laserFireTimers:Array;
		private var explosiveMissleFireTimer:Number = 0;
		private var homingMissleFireTimer:Number = 2.5;
		
		private const laserFireRate:Number = 5;
		private var laserFireRates:Array;
		private const explosiveMissleFireRate:Number = 5;
		private const homingMissleFireRate:Number = 5;
		
		private var autofire:Boolean = true;

		private var boosterFailureRate:Number;
		private var stalled:Boolean = false;
		private var stallTimer:Number = 0;
		private var moveTimer:Number = 0;
		
		override public function update():void {
			super.update()
			timer += FP.elapsed;
			for (var i:int = 0; i < laserFireTimers.length; i++) {
				laserFireTimers[i] = (laserFireTimers[i] as Number) + FP.elapsed; //did it this way because Number is being passed by value
			}
			homingMissleFireTimer += FP.elapsed;
			explosiveMissleFireTimer += FP.elapsed;
			
			this.x += horizontalImbalanceVelocity * FP.elapsed;
			this.y += verticalImbalanceVelocity * FP.elapsed;
			
			if (Input.check(Key.SPACE)) {
				fireAllGuns();
			}
			
			if (Input.released(Key.F)) {
				autofire = !autofire;
			}
			
			if (autofire){
				fireAllGuns();
			}
			
			FlashPunk.stayOnScreen(this);
			
			//stall
			if (moveTimer > 1.5) {
				moveTimer = 0;
				
				if (Flash.chance(boosterFailureRate)) { //rolls every half second of movement
					stalled = true;
					stallTimer = 0;
					this.world.add(new Smoke(this.x, this.y));
				}
			}
			
			if (stalled) {
				stallTimer += FP.elapsed;
				if (stallTimer > 1) {
					stalled = false;
				}
				return;
			}
			
			//move
			if (Input.check(Key.A) || Input.check(Key.LEFT)) {
				this.x -= movementVelocity * FP.elapsed;
				moveTimer += FP.elapsed;
			}
			if (Input.check(Key.D) || Input.check(Key.RIGHT)) {
				this.x += movementVelocity * FP.elapsed;
				moveTimer += FP.elapsed;
			}
			if (Input.check(Key.W) || Input.check(Key.UP)) {
				this.y -= movementVelocity * FP.elapsed;
				moveTimer += FP.elapsed;
			}
			if (Input.check(Key.S) || Input.check(Key.DOWN)) {
				this.y += movementVelocity * FP.elapsed;
				moveTimer += FP.elapsed;
			}
		}
		
		private function fireAllGuns():void {
			fireLaser();
			fireExplosiveMissle();
			fireHomingMissle();
		}
		
		private function fireLaser():void {
			if (!generatedLasers)
				return;
			
			//laserFireTimer = 0;
			
			for (var i:int = 0; i < generatedLasers.length; i++) {
				if (laserFireTimers[i] >= laserFireRates[i]) {
					laserFireTimers[i] = 0;
					this.world.add(generatedLasers[i].copy(this.x, this.y));
				}
			}
		}
		
		private function fireExplosiveMissle():void {
			if (explosiveMissleFireTimer < explosiveMissleFireRate || !generatedExplosiveMissles) //checking null reminds me of working at Segin
				return;
			
			explosiveMissleFireTimer = 0;
			
			//shoot missles in a cone pattern
			var angleOffset:Number = 0;
			var counter:int = 0;
			var yOffset:Number = 0;
			for each (var generatedExplosiveMissle:ExplosiveMissle in generatedExplosiveMissles) {
				this.world.add(generatedExplosiveMissle.copy(this.x + image.width / 2, this.y + yOffset, angleOffset));
				if (counter % 2 == 0)
					angleOffset = Math.abs(angleOffset) + 2.5; //TODO: the offset should depend on the size of the missle
				else
					angleOffset *= -1;
				counter++;
				yOffset++;
			}
		}
		
		private function fireHomingMissle():void {
			if (homingMissleFireTimer < homingMissleFireRate || !generatedHomingMissles)
				return;
			
			homingMissleFireTimer = 0;
			
			var angleOffset:Number = 0;
			var counter:int = 0;
			var yOffset:Number = 0; //was an attempt to fix the problem in which multiple missles collide with a single enemy. I'm not sure if it fixed it completely but it did make a pretty wave pattern!
			for each (var generatedHomingMissle:HomingMissile in generatedHomingMissles) {
				this.world.add(generatedHomingMissle.copy(this.x + image.width / 2, this.y + yOffset, angleOffset));
				if (counter % 2 == 0)
					angleOffset = Math.abs(angleOffset) + 2.5;
				else
					angleOffset *= -1;
				counter++;
				yOffset++;
			}
		}
		
		public function get combinedUpgradesBitmapData():BitmapData { //TODO: seperate to rebuild, get, rebuildAndGet?
			//clears and rebuilds the bitmap
			_combinedUpgradesBitmapData.fillRect(_combinedUpgradesBitmapData.rect, 0x00000000);
			_combinedUpgradesBitmapData.draw(boosterBitmapData);
			_combinedUpgradesBitmapData.draw(laserGunBitmapData);
			_combinedUpgradesBitmapData.draw(homingMissleGunBitmapData);
			_combinedUpgradesBitmapData.draw(explosiveMissleGunBitmapData);
			_combinedUpgradesBitmapData.draw(powerSupplyBitmapData);
			return _combinedUpgradesBitmapData;
		}
		
		public function get combinedUpgradesWithShipBitmapData():BitmapData { //see above todo
			_combinedUpgradesWithShipBitmapData.fillRect(_combinedUpgradesWithShipBitmapData.rect, 0x00000000);
			_combinedUpgradesWithShipBitmapData.draw(FP.getBitmap(Global.GRAPHIC_PLAYER));
			_combinedUpgradesWithShipBitmapData.draw(combinedUpgradesBitmapData);
			return _combinedUpgradesWithShipBitmapData;
		}
	}
}