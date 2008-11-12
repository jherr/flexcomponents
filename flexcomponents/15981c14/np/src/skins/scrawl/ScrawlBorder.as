package skins.scrawl
{
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.SpreadMethod;
import mx.core.EdgeMetrics;
import mx.skins.RectangularBorder;

public class ScrawlBorder extends RectangularBorder
{
	/** Internal object that contains the thickness of each edge of the border */
	private var _borderMetrics:EdgeMetrics;

	/** Return the thickness of the border edges. */
	override public function get borderMetrics():EdgeMetrics
	{		
		if (_borderMetrics)
			return _borderMetrics;
			
		var borderThickness:Number = getStyle("borderThickness");
		if (isNaN(borderThickness))
			borderThickness = 0;

		_borderMetrics = new EdgeMetrics(borderThickness,
										  borderThickness,
										  borderThickness,
										  borderThickness);
			
		var borderSides:String = getStyle("borderSides");
		borderSides = borderSides.toLowerCase();			
		if (borderSides != "left top right bottom")
		{
			// Adjust metrics based on which sides we have				
			if (borderSides.indexOf("left") == -1)
				_borderMetrics.left = 0;
			
			if (borderSides.indexOf("top") == -1)
				_borderMetrics.top = 0;
			
			if (borderSides.indexOf("right") == -1)
				_borderMetrics.right = 0;
			
			if (borderSides.indexOf("bottom") == -1)
				_borderMetrics.bottom = 0;
		}

		return _borderMetrics;
	}

	/** If borderStyle may have changed, clear the cached border metrics. */
	override public function styleChanged(styleProp:String):void
	{
		if (styleProp == null ||
			styleProp == "styleName" ||
			styleProp == "borderStyle" ||
			styleProp == "borderThickness" ||
			styleProp == "borderSides")
		{
			_borderMetrics = null;
		}
		
		invalidateDisplayList();
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{	
		if (isNaN(w) || isNaN(h))
			return;
			
		super.updateDisplayList(w, h);

		var borderStyle:String = getStyle("borderStyle");		

		var borderColor:uint = getStyle("borderColor");
		var borderSides:String = getStyle("borderSides");
		var borderThickness:Number = getStyle("borderThickness");

		var g:Graphics = graphics;
		g.clear();

		if (borderStyle)
		{
			switch (borderStyle)
			{
				case "none":
				{
					break;
				}

				// all other cases
				default:
				{ 		
					g.lineStyle(borderThickness / 2, borderColor);
					g.lineGradientStyle(GradientType.LINEAR, [borderColor, borderColor], [1.0, 0.5], [0, 255],
										null, SpreadMethod.REFLECT);

					borderSides = borderSides.toLowerCase();
										
					if (borderSides.indexOf("top") != -1)
					{
						g.moveTo(Math.random() * borderThickness, Math.random() * borderThickness);
						g.lineTo(w - (Math.random() * borderThickness), Math.random() * borderThickness);
					}
					
					if (borderSides.indexOf("right") != -1)
					{
						g.moveTo(w - (Math.random() * borderThickness), Math.random() * borderThickness);
						g.lineTo(w - (Math.random() * borderThickness), h - (Math.random() * borderThickness));
					}
					
					if (borderSides.indexOf("bottom") != -1)
					{
						g.moveTo(w - (Math.random() * borderThickness), h - (Math.random() * borderThickness));
						g.lineTo(Math.random() * borderThickness, h - (Math.random() * borderThickness));
					}

					if (borderSides.indexOf("left") != -1)
					{
						g.moveTo(Math.random() * borderThickness, h - (Math.random() * borderThickness));
						g.lineTo(Math.random() * borderThickness, Math.random() * borderThickness);
					}
					
					break;				
				}
			} // switch
		}
	}
}

}
