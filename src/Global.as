package {
	import objects.game.Player;
	
	/**
	 * Game specific constants.
	 */
	public class Global {
		
		//classes
		public static var sandbox:Sandbox, player:Player, graphicsEditor:GraphicsEditor;
		
		//primary data types
		
		//graphics
		[Embed(source = '../assets/graphics/player.png')] //used in the canvas to check color of ship
		public static const GRAPHIC_PLAYER:Class;
		
		//[Embed(source = '../assets/graphics/playerOutline.png')] //TODO: used in graphic editor, also could just use the outline of all graphics, don't need a filled color inside
		//public static const GRAPHIC_PLAYER_OUTLINE:Class;
		
		[Embed(source = '../assets/graphics/ghost2.png')]
		public static const GRAPHIC_GHOST:Class;
		
		[Embed(source = '../assets/graphics/homingMissle.png')]
		public static const GRAPHIC_HOMING_MISSLE:Class;
		
		[Embed(source = '../assets/graphics/explosiveMissle.png')]
		public static const GRAPHIC_EXPLOSIVE_MISSLE:Class;
		
		[Embed(source = '../assets/graphics/laserGun.png')]
		public static const GRAPHIC_LASER_GUN:Class;
		
		[Embed(source = '../assets/graphics/smoke.png')]
		public static const GRAPHIC_SMOKE:Class;
		
		//stored high scores here because it's used in two worlds
		public static var challenge1HighScore:int = 0;
		public static var challenge2HighScore:int = 0;
		public static var challenge3HighScore:int = 0;
	}
}