package com.fxcomponents.controls.slideshow
{
import flash.display.Shape;

import mx.core.UIComponent;

public class Arrow extends UIComponent
{
	public function Arrow()
	{
		super();
	}
	
	private var shape:Shape;
	
	private var _heightOuter:int = 35;
	
	public function set heightOuter(value:int):void
	{
		_heightOuter = value;
	}
	
	public function get heightOuter():int
	{
		return _heightOuter;
	}
	
	private var _heightInner:int = 13;
	
	public function set heightInner(value:int):void
	{
		_heightInner = value;
	}
	
	private var _direction:String;
	
	public function set direction(value:String):void
	{
		_direction = value;
	}
	
	public function get direction():String
	{
		return _direction;
	}
	
	private var _outerColor:Number = 0;
	
	public function set outerColor(value:Number):void
	{
		_outerColor = value;
	}
	
	private var _innerColor:Number = 0xffffff;
	
	public function set innerColor(value:Number):void
	{
		_innerColor = value;
	}
	
	private var _panelAlpha:Number = .2;
	
	public function set panelAlpha(value:Number):void
	{
		_panelAlpha = value;
	}
	
	/**
	 * Sets the default size and default minimum size of the component.
	 */
	override protected function createChildren():void
	{
		super.createChildren();
		
		shape = new Shape();
		
		addChild(shape);
	}
	
	/**
	 * Sizes and positions the children of the component on the screen based on 
	 * all previous property and style settings, and draws any skins or graphic 
	 * elements used by the component. The parent container for the component 
	 * determines the size of the component itself.
	 */
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        shape.graphics.clear();
		shape.graphics.beginFill(_outerColor, _panelAlpha);
		
		var wOuter:uint = _heightOuter/2 + .5;
		var hOuter:uint = _heightOuter;
		
		var hInner:uint = _heightInner;
		
		var wSpine:uint = 3;
		var hSpine:uint = 7;
		
		var x:uint;
		var y:uint;
		var w:int;
		var h:int;
		
		if(_direction == "left")
		{
			x = wOuter - 1;
			y = 0;
			
			for(h = hOuter; h>0; h -= 2)
				shape.graphics.drawRect(x--, y++, 1, h);
		}
		
		if(_direction == "right")
		{
			x = 0;
			y = 0;
			
			for(h = hOuter; h>0; h -= 2)
				shape.graphics.drawRect(x++, y++, 1, h);
		}
		
		shape.graphics.beginFill(_innerColor);
		
		if(_direction == "left")
		{
			x = wOuter - wSpine;
			y = (hOuter - hSpine)/2
			w = wSpine;
			h = hSpine;
			
			shape.graphics.drawRect(x, y, w, h);
			
			x--;
			y = (hOuter - _heightInner)/2;
			w = 1;
			
			for(h = _heightInner; h>0; h -= 2)
				shape.graphics.drawRect(x--, y++, w, h);
		}
		
		if(_direction == "right")
		{
			x = 0;
			y = (hOuter - hSpine)/2
			w = wSpine;
			h = hSpine;
			
			shape.graphics.drawRect(x, y, w, h);
			
			x = wSpine;
			y = (hOuter - hInner)/2;
			w = 1;
			
			for(h = hInner; h>0; h -= 2)
				shape.graphics.drawRect(x++, y++, w, h);
		}
		
		setActualSize(shape.width, shape.height);
    }
}
}