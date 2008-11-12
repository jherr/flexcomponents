package skins.scrawl
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.SpreadMethod;
	
	import mx.skins.Border;
	import mx.utils.ColorUtil;
	
	import util.ScrawlUtil;
	
	
	public class ComboBoxSkin extends Border
	{	
	    override public function get measuredWidth():Number
	    {
	        return 22;
	    }
	       
	    override public function get measuredHeight():Number
	    {
	        return 22;
	    }
	
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
	
			// User-defined styles.
			var borderColor:uint = getStyle("borderColor");
			var dropdownBorderColor:Number = getStyle("dropdownBorderColor");
			
			// The dropdownBorderColor is currently only used
			// when displaying an error state.
			if (!isNaN(dropdownBorderColor))
				borderColor = dropdownBorderColor;
	
			var borderColorDark:uint = ColorUtil.adjustBrightness(borderColor, -50);
			var color:uint;
	
			// If our name doesn't include "editable", we are drawing the non-edit
			// skin which spans the entire control		
			var drawLine:Boolean = (name.indexOf("editable") < 0);
			
			var g:Graphics = graphics;
			
			g.clear();	
			
			// Draw the border and fill.
			switch (name)
			{
				case "upSkin":
				case "editableUpSkin":
				{		
					// border
					color = borderColor;			
					break;
				}
				
				case "overSkin":
				case "editableOverSkin":
				{
					// border
					color = borderColorDark;
					break;
				}
				
				case "downSkin":
				case "editableDownSkin":
				{
					// border
					color = borderColorDark;
				
					// button fill: cross-hatch
					ScrawlUtil.drawCrossHatch(g, w, h, color, 0.3);
					
					break;
				}
				
				case "disabledSkin":
				case "editableDisabledSkin":
				{
					// border
					color = 0x999999;
					break;
				}
			}
	
			// fill with zero alpha (to capture mouse events)
			drawRoundRect(1, 1, w - 2, h - 2, 0, 0x000000, 0.0);	
	
			// draw the border
			var borderThickness:int = getStyle("borderThickness");
			g.lineStyle(borderThickness / 2);
			g.lineGradientStyle(GradientType.LINEAR, [color, color], [1.0, 0.5], [0, 255],
								null, SpreadMethod.REFLECT);
			g.moveTo(Math.random() * borderThickness, Math.random() * borderThickness);
			g.lineTo(w - (Math.random() * borderThickness), Math.random() * borderThickness);
			g.moveTo(w - (Math.random() * borderThickness), Math.random() * borderThickness);
			g.lineTo(w - (Math.random() * borderThickness), h - (Math.random() * borderThickness));
			g.moveTo(w - (Math.random() * borderThickness), h - (Math.random() * borderThickness));
			g.lineTo(Math.random() * borderThickness, h - (Math.random() * borderThickness));
			g.moveTo(Math.random() * borderThickness, h - (Math.random() * borderThickness));
			g.lineTo(Math.random() * borderThickness, Math.random() * borderThickness);
			
			// draw the line (if necessary)
			if (drawLine)
			{
				var bias:int = 2*Math.random();
				g.moveTo(w + bias - 22, 4);
				g.lineTo(w - (bias + 22), h - 8);
			}
					
			// draw the triangle.
			g.lineStyle(2, color);
			g.moveTo(w - 11.5, h / 2 + 3);
			g.lineTo(w - 15, h / 2 - 2);
			g.moveTo(w - 13, h / 2 - 3);
			g.lineTo(w - 8, h / 2 - 2);
			g.lineTo(w - 11.5, h / 2 + 3);
			g.endFill();
		}
	}

}