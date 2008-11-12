package components
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.EdgeMetrics;
	import mx.core.FlexSprite;
	import mx.core.UIComponent;
	import util.ScrawlUtil;
	
	public class ScrawlGrid extends DataGrid
	{	
	    override protected function drawVerticalLine(s:Sprite, colIndex:int, color:uint, x:Number):void
	    {
	        //draw our vertical lines
	        var g:Graphics = s.graphics;
			var borderColor:uint = getStyle("borderColor");
	        if (lockedColumnCount > 0 && colIndex == lockedColumnCount - 1)
	            g.lineStyle(1, 0, 100);
	        else
	        {
	            g.lineStyle(1, borderColor, 100);
        		g.lineGradientStyle(GradientType.LINEAR, [color, color], [1.0, 0.5], [0, 255],
					null, SpreadMethod.REFLECT);
	        }
	        var bias:int = 5 - (10 * Math.random());
	        g.moveTo(x + bias, 3 * Math.random());
	        g.lineTo(x - bias, listContent.height - (3 * Math.random()));
	    }

	    override protected function drawHeaderBackground(headerBG:UIComponent):void
	    {
	        var g:Graphics = headerBG.graphics;
	        g.clear();
	
            var bm:EdgeMetrics = borderMetrics;
            var adjustedWidth:Number = unscaledWidth - (bm.left + bm.right);
            // Need to extend mask too.
            maskShape.width = adjustedWidth;
	
	        var hh:Number = rowInfo.length ? rowInfo[0].height : headerHeight;
	        
	        // draw diagonal line fill
	        g.lineStyle(1, 0x555555, 0.25);
	        var vdistance:int;
	        var vstart:int;
	        var vstartOffset:int;
	        var vdistanceOffset:int;
	        
	        for(var i:int = -hh; i < adjustedWidth; i += 5)
	        {
	        	vstart = Math.max(-i, 0);
	        	vdistance = Math.min(hh, adjustedWidth - i);
	        	vstartOffset = vstart + (3 * Math.random());	  
	        	g.moveTo(i + vstartOffset, vstartOffset);
	        	g.lineTo(i + vdistance, vdistance + 2 - (4 * Math.random()));
	        }
	        
	        g.lineStyle(0, 0x000000, 0);
	        g.moveTo(0, 0);
	        g.lineTo(adjustedWidth, 0);
	        g.lineTo(adjustedWidth, hh - 0.5);
	        g.lineStyle(0, getStyle("borderColor"), 100);
	        g.lineTo(0, hh - 0.5);
	        g.lineStyle(0, 0x000000, 0);
	    }
	    
	    override protected function drawHighlightIndicator(
                                indicator:Sprite, xx:Number, yy:Number,
                                ignoredWidth:Number, h:Number, color:uint,
                                ignoredRenderer:IListItemRenderer):void
	    {
	    	var w:int = unscaledWidth - viewMetrics.left - viewMetrics.right;
	        ScrawlUtil.drawCrossHatch(Sprite(indicator).graphics, w, h, color, 1.0);
	        indicator.x = xx;
	        indicator.y = yy;
	    }
	   
        override protected function drawSelectionIndicator(
                                indicator:Sprite, xx:Number, yy:Number,
                                ignoredWidth:Number, h:Number, color:uint,
                                ignoredRenderer:IListItemRenderer):void
	    {
	    	var w:int = unscaledWidth - viewMetrics.left - viewMetrics.right;
	        ScrawlUtil.drawCrossHatch(Sprite(indicator).graphics, w, h, color, 1.0);
	        indicator.x = xx;
	        indicator.y = yy;
	    }
	    
	    	
		// this is the clunky part: changing header rollover and selection
    	override protected function mouseOverHandler(event:MouseEvent):void
    	{
    		super.mouseOverHandler(event);
    		headerRendererHack(event, getStyle("rollOverColor"));
    	}

    	override protected function mouseDownHandler(event:MouseEvent):void
    	{
    		super.mouseDownHandler(event);
    		headerRendererHack(event, getStyle("selectionColor"));
    	}
    	    	
    	private function headerRendererHack(event:MouseEvent, color:uint):void
		{            
            var s:Sprite = Sprite(selectionLayer.getChildByName("headerSelection"));
            if(!s)
            {
                s = new FlexSprite();
                s.name = "headerSelection";
                selectionLayer.addChild(s);
            }

			var r:IListItemRenderer = getColumnHeaderRenderer(event); 
			if(r)
			{
				var n:int = listItems[0].length;
				for(var i:int; i < n; i++)
				{
					if(r == listItems[0][i])
					{
						ScrawlUtil.drawCrossHatch(s.graphics, columns[i].width, r.height, color, 1.0);			            
			            s.x = r.x;
			            s.y = r.y;
			  		}
			  	}
	  		}
    	}
    	
    	private function getColumnHeaderRenderer(event:MouseEvent):IListItemRenderer
    	{
    		var arrow:Sprite = Sprite(listContent.getChildByName("sortArrowHitArea"));
            if (event.target != arrow)
            {
            	return mouseEventToItemRenderer(event);   		
            } 
            else
            {
            	// the event target is the sort arrow, but we want a renderer for the corresponding header
            	// loop over the column header renderers and find the one next to the arrow
            	var n:int = listItems[0].length;
    			var r:IListItemRenderer;
    			var temp:IListItemRenderer;
            	for(var i:int = 0; i < n; i++)
            	{
            		temp = IListItemRenderer(listItems[0][i]);
            		if(temp.x > arrow.x)
            		{
            			// we've overshot the correct renderer
            			return r;
            		}
            		else
            		{
            			r = temp;
            		}
            	}  
            	return r;   	
            }    
    	}
    	
    	// end clunky part
	}
}