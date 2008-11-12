package skins.scrawl
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import mx.controls.scrollClasses.ScrollBar;
	import mx.utils.ColorUtil;
	import mx.skins.Border;
	
	/**
	 *  The skin for all the states of the up or down button in a ScrollBar.
	 */
	public class ScrollArrowSkin extends Border
	{    
	    override public function get measuredWidth():Number
	    {
	        return ScrollBar.THICKNESS;
	    }
	           
	    override public function get measuredHeight():Number
	    {
	        return ScrollBar.THICKNESS;
	    }
	    
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
	
			// User-defined styles.
			var borderColor:uint = getStyle("borderColor");
			var backgroundColor:uint = 0xAAAAAA;
			var borderColorDark:uint = ColorUtil.adjustBrightness(borderColor, -50);
			var arrowColor:uint = 0x444444;
			var arrowColorDark:uint = 0x111111;
	
			//------------------------------
			//  background
			//------------------------------
			
			var g:Graphics = graphics;
			g.clear();
			
			if (isNaN(backgroundColor))
				backgroundColor = 0xFFFFFF;                        
	
			// fill with zero alpha in order to catch mouse events
			drawRoundRect(1, 1, w-2, h-2, 0, backgroundColor, 0.0);	
	
			switch (name)
			{
				case "upArrowUpSkin":
				case "downArrowUpSkin":
				{
					drawBorder(w, h, borderColor);
					drawArrow(g, w, h, arrowColor);
					break;
				}
				
				case "upArrowOverSkin":
				case "downArrowOverSkin":
				{
					drawBorder(w, h, borderColorDark);			
					drawArrow(g, w, h, arrowColor);
					break;
				}
				
				case "upArrowDownSkin":
				case "downArrowDownSkin":
				{
					drawBorder(w, h, borderColorDark);				
					drawArrow(g, w, h, arrowColorDark);
					break;
				}
				
				default:
				{
					drawRoundRect(
						0, 0, w, h, 0,
						0xFFFFFF, 0);
					
					return;
					break;
				}
			}
		}
		
		private function drawBorder(w:int, h:int, borderColor:uint):void
		{
			drawRoundRect(0, 0, w, h, 0, [borderColor, borderColor], [1.0, 0.5],
				null, GradientType.LINEAR, null, 
				{ x: 1, y: 1, w: w - 2, h: h - 2, r: 0 });  
		}
		
		private function drawArrow(g:Graphics, w:int, h:int, arrowColor:uint):void
		{
			// Draw up or down arrow
			var upArrow:Boolean = (name.charAt(0) == 'u');
			g.lineStyle(2, arrowColor);
			if (upArrow)
			{
				g.moveTo(w / 2, 6);
				g.lineTo(w - 5, h - 6);
				g.lineTo(5, h - 6);
				g.lineTo(w / 2 - 1, 8);
			}
			else
			{
				g.moveTo(w / 2, h - 6);
				g.lineTo(w - 5, 4);
				g.lineTo(7, 5);
				g.moveTo(5, 6);
				g.lineTo(w / 2, h - 6);
			}		
		}
	}
}
