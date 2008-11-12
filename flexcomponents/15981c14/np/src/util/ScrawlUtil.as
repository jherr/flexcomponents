package util
{
	import flash.display.Graphics;
	
	public class ScrawlUtil
	{				
	    public static function drawCrossHatch(g:Graphics, w:Number, h:Number, color:uint, alpha:Number):void
	    {    	
	    	g.clear();
	    	
	        // draw cross-hatch fill
	        g.lineStyle(1, color, alpha);
	        var vdistance:int;
	        var vstart:int;
	        var vstartOffset:int;
	        var vdistanceOffset:int;
	        var i:int;
	        
	         // draw \\\\\\\\
	        for(i = -h; i < w; i += 6)
	        {
	        	vstart = Math.max(-i, 0);
	        	vdistance = Math.min(h, w - i);
	        	vstartOffset = vstart + 3 - (6 * Math.random());        	
	        	g.moveTo(i + vstartOffset, vstartOffset);
	        	g.lineTo(i + vdistance, vdistance + 2 - (4 * Math.random()));
	        }
	
			// draw ////////
	        for(i = 0; i < w + h; i += 6)
	        {
	        	vstart = Math.max(i - w, 0);
	        	vdistance = Math.min(h, i);
	        	vstartOffset = vstart + 3 - (6 * Math.random());
	        	g.moveTo(i - vstartOffset, vstartOffset);
	        	g.lineTo(i - vdistance, vdistance + 2 - (4 * Math.random()));
	        }
	    }
	}
}