package skins.scrawl
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	
	import mx.skins.Border;
	import mx.utils.ColorUtil;
	
	public class ScrollThumbSkin extends Border
	{
		override public function get measuredWidth():Number
		{
			return 15;
		}
	
		override public function get measuredHeight():Number
		{
			return 11;
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
	
			// User-defined styles.
			var borderColor:uint = getStyle("borderColor");
			var borderColorDark:uint = ColorUtil.adjustBrightness(borderColor, -50);
			var borderAlphas:Array = [1.0, 0.5];
			var backgroundColor:uint = 0x555555;
			var backgroundAlpha:Number = 0.3;
			var hole:Object = { x: 1, y: 1, w: w - 4, h: h - 1, r: 0};
			
			graphics.clear();   
			
			// draw fill with alpha = 0.0 to capture mouse events
			drawRoundRect(1, 0, w - 3, h, 0, backgroundColor, 0.0);                       
	
			switch (name)
			{
				default:
				case "thumbUpSkin":
				{
					// Draw background with low alpha
					drawCrossHatch(graphics, w - 3, h, backgroundColor, backgroundAlpha);  
	
					// border
					drawRoundRect(1, 0, w - 3, h, 0, [borderColor, borderColor], borderAlphas,
						null, GradientType.LINEAR, null, hole);    
	
					break;
				}
				
				case "thumbOverSkin":
				{
					// Draw background with low alpha
					drawCrossHatch(graphics, w - 3, h, backgroundColor, backgroundAlpha);  
			
					// border
					drawRoundRect(1, 0, w - 3, h, 0, [borderColorDark, borderColorDark], borderAlphas,
						null, GradientType.LINEAR, null, hole);  
					
					break;
				}
				
				case "thumbDownSkin":
				{				
					// Draw background with higher alpha
					drawCrossHatch(graphics, w - 3, h, backgroundColor, 2 * backgroundAlpha);  
	
					// border
					drawRoundRect(1, 0, w - 3, h, 0, [borderColorDark, borderColorDark], borderAlphas,
						null, GradientType.LINEAR, null, hole);  
										
					break;
				}
				
				case "thumbDisabledSkin":
				{
					// positioning placeholder
					drawRoundRect(
						0, 0, w, h, 0,
						0xFFFFFF, 0); 
					
					// border
					drawRoundRect(
						1, 0, w - 3, h, 0,
						0x999999, 0.5);
					
					// fill
					drawRoundRect(
						1, 1, w - 4, h - 2, 0,
						0xFFFFFF, 0.5);
					
					break;
				}
			}
			
			// Draw grip.		
			var gripL:Number = Math.floor(w / 2 - 4);
			var gripR:Number = w - (gripL+1);
			var gripH:Number = Math.floor(h/2);
			
			graphics.lineStyle(1, 0x000000, 0.8);
			graphics.moveTo(gripL, gripH - 3);
			graphics.lineTo(gripR, gripH - 2);
			graphics.moveTo(gripL, gripH);
			graphics.lineTo(gripR, gripH + 1);
			graphics.moveTo(gripL, gripH + 3);
			graphics.lineTo(gripR, gripH + 4);
		}
	
		/** the cross-hatch pattern here is a bit different from ScrawlUtil.drawCrossHatch() */
	    private function drawCrossHatch(g:Graphics, w:int, h:int, color:uint, _alpha:Number):void
	    {
	        // draw cross-hatch fill
	        g.lineStyle(1, color, _alpha);
	        var vdistance:int;
	        var vstart:int;
	        
	         // draw \\\\\\\\
	        for(var i:int = -height; i < w; i += 6)
	        {
	        	vstart = Math.max(-i, 0);
	        	vdistance = Math.min(height, w - i);
	        	g.moveTo(i + vstart + Math.random(), vstart + Math.random());
	        	g.lineTo(i + vdistance - Math.random(), vdistance - Math.random());
	        }
	
			// draw ////////
	        for(var j:int = 0; j < w + height; j += 6)
	        {
	        	vstart = Math.max(j - w, 0);
	        	vdistance = Math.min(height, j);
	        	g.moveTo(j - vstart + Math.random(), vstart + Math.random());
	        	g.lineTo(j - (vdistance + Math.random()), vdistance - Math.random());
	        }
	    }
	}
}
