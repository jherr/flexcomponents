package views{

	import mx.containers.Panel;
	import flash.events.MouseEvent;
	import mx.controls.Menu;
	import mx.collections.XMLListCollection;
	import mx.controls.Alert;
	import mx.events.MenuEvent;
	import mx.controls.Button;
	import mx.controls.MenuBar;
	import flash.events.Event;
	import events.PanelMenuEvent;
	

	public class PanelMenu extends Panel{
		
		public static const PANEL_MENU_CHANGE:String = 'panelMenuChange';
		[Event(name="panelMenuChange",type="events.PanelMenuEvent")]
		
		public var mnu:MenuBar;
		
		private var menubarXML:XMLList =
		<>
		<menuitem label="Menu">
		<menuitem label="Playlist" data="0"/>
		<menuitem label="Now Playing" data="1"/>
		</menuitem>
		</>;
		
		private var menuBarCollection:XMLListCollection;
		
		public function PanelMenu(){
			super();
			menuBarCollection = new XMLListCollection(menubarXML); 
		}
		protected override function createChildren():void{
			super.createChildren();
			mnu = new MenuBar();
			mnu.addEventListener("itemClick",menuHandler);
			mnu.dataProvider = menuBarCollection;
			mnu.height = 20;
			mnu.width = 15;
			mnu.labelField="@label";
			mnu.setStyle("cornerRadius",9);
			mnu.setStyle("fontSize", 10);
			mnu.setStyle("backgroundColor",0x000000);
			
			rawChildren.addChild(mnu);
		}
		private function menuHandler(event:MenuEvent):void {
			var i:Number = Number(event.item.@data);
			this.dispatchEvent( new PanelMenuEvent(i,PanelMenu.PANEL_MENU_CHANGE) );
			//Alert.show("Label: " + event.item.@label + "\n" + "Data: " + event.item.@data + "\n", "Clicked menu item");
		}
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			mnu.setActualSize(80,12);
			var pixelsFromTop:int = 5;
			var pixelsFromRight:int = 50;
			var buttonWidth:int = mnu.width;
			var x:Number = unscaledWidth - buttonWidth - pixelsFromRight;
			var y:Number = pixelsFromTop
			mnu.move(x,y);

		}
		
		
	}
}
