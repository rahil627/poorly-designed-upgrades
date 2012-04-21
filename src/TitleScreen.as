package {
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.World;
	
	public class TitleScreen extends World {
		
		public function TitleScreen():void {
			super();
			
			var title:Text = new Text("Poorly Designed Upgrades");
			title.centerOO();
			this.addGraphic(title, 0, FP.screen.width / 2, FP.screen.height / 4); //shortcut World.addGraphic creates a new Entity and calls entity.addGraphic
			
			var author:Text = new Text("by Rahil Patel");
			author.centerOO();
			this.addGraphic(author, 0, FP.screen.width * 3 / 4, FP.screen.height /4 + title.height);
			
			var start:Text = new Text("press space to begin");
			start.centerOO();
			this.addGraphic(start, 0, FP.screen.width / 2, FP.screen.height * 3 / 4);
		}
		
		override public function update():void {
			super.update();
			if (Input.check(Key.SPACE)) {
				FP.world = Global.sandbox;
			}
		}
	}
}