package com.fxcomponents.controls.fxvideo
{
public class StopButton extends Button
{
	public function StopButton()
	{
		super();
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		icon.graphics.clear();
		icon.graphics.beginFill(iconColor);
		
		icon.graphics.drawRect(0, 0, 7, 7);
		
		icon.x = (unscaledWidth - icon.width)/2;
		icon.y = (unscaledHeight - icon.height)/2;
	}
}
}