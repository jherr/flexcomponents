package com.fxcomponents.controls.fxvideo
{
import flash.display.Shape;
import flash.events.MouseEvent;

import com.fxcomponents.controls.fxvideo.Button;

public class PlayPauseButton extends Button
{
	public function PlayPauseButton()
	{
		super();
	}
	
	private var _state:String = "pause";
	
	public function set state(value:String):void
	{
		_state = value;
		
		invalidateDisplayList();
	}
	
	public function get state():String
	{
		return _state;
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		icon.graphics.clear();
		icon.graphics.beginFill(iconColor);
		
		if(_state == "play")
		{
			var x:uint = 0;
			var y:uint = 0;
			var w:int = 1;
			var h:int = 9;
			
			for(; h>0; h -= 2)
				icon.graphics.drawRect(x++, y++, w, h);
		}
		
		if(_state == "pause")
		{
			icon.graphics.drawRect(0, 0, 3, 7);
			icon.graphics.drawRect(4, 0, 3, 7);
		}
		
		icon.x = (unscaledHeight - icon.width)/2;
		icon.y = (unscaledHeight - icon.height)/2;
	}
}
}