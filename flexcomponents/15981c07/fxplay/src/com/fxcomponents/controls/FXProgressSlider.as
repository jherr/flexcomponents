package com.fxcomponents.controls
{
import com.fxcomponents.skins.SliderProgressSkin;

import flash.display.DisplayObject;
import flash.display.Graphics;

import mx.core.IFlexDisplayObject;
import mx.styles.ISimpleStyleClient;

[Style(name="progressColor", type="uint", format="Color", inherit="no")]
[Style(name="progressSkin", type="Class", inherit="no")]

public class FXProgressSlider extends FXSlider
{
	public function FXProgressSlider()
	{
		super();
		
	}
	
	private var skinClass:Class;
	private var progressBar:IFlexDisplayObject;
	
	private var _progress:Number = 20;
	
	public function set progress(value:Number):void
	{
		_progress = value;
		
		invalidateDisplayList();
	}
	
	override protected function createChildren():void
	{
		super.createChildren();
		
		if(!getStyle("progressColor"))
			setStyle("progressColor", 0x999999);
			
		if(!getStyle("progressSkin"))
			setStyle("progressSkin", SliderProgressSkin);
		
		if (!progressBar)
        {
            skinClass = getStyle("progressSkin");
			
            progressBar = new skinClass();
            
            if (progressBar is ISimpleStyleClient)
                ISimpleStyleClient(progressBar).styleName = this;

            addChildAt(DisplayObject(progressBar), 1);
        }
	}
	
	override protected function commitProperties():void
	{
		super.commitProperties();
		
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		var w:Number;
		var buggyArea:Number = unscaledWidth / maximum * 10;
		
		progressBar.setActualSize(Math.round(_progress*unscaledWidth/100), unscaledHeight);
		
		var g:Graphics = bound.graphics;
        
        g.clear();
        g.beginFill(0xffaaaa, 0);
        
        (_progress == 100) ? w = unscaledWidth : w = Math.max(_progress*unscaledWidth/100 - buggyArea, 0)
        
        g.drawRect(0, 0, w, unscaledHeight);
	}
}
}