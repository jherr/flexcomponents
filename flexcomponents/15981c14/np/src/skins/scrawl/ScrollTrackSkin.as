package skins.scrawl
{
	import flash.display.GradientType;
	import mx.skins.Border;

	public class ScrollTrackSkin extends Border
	{	
	    override public function get measuredWidth():Number
	    {
	        return 16;
	    }
	           
	    override public function get measuredHeight():Number
	    {
	        return 1;
	    }
	    
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			var borderColor:uint = getStyle("borderColor");
			
			graphics.clear();
					
			// fill with zero alpha: if no fill, mouse events are not recognized
			drawRoundRect(1, 1, w-2, h-2, 0, 0x000000, 0.0);	
			
			// border
			drawRoundRect(
				0, 0, w, h, 0,
				[ borderColor, borderColor ], [1.0, 0.5],
				null, GradientType.LINEAR, null,
				{ x: 1, y: 1, w: w - 2, h: h - 2, r: 0 }); 
		}
	}
}
