package components
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import mx.controls.List;
	import mx.controls.listClasses.IListItemRenderer;
	import util.ScrawlUtil;
		
	public class ScrawlComboBoxDropdown extends List
	{		    
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
	}
}