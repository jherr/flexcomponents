package com.fxcomponents.controls.slideshow
{
import flash.events.MouseEvent;

import mx.controls.TextArea;
import mx.core.UIComponent;
import mx.utils.GraphicsUtil;

public class DetailsButton extends UIComponent
{
	public function DetailsButton()
	{
		super();
	}
	
	private var textArea:TextArea;
	
	private var _backgroundColor:Number = 0xffffff;
	
	public function set backgroundColor(value:Number):void
	{
		_backgroundColor = value;
	}
	
	private var _labelColor:Number = 0x666666;
	
	public function set labelColor(value:Number):void
	{
		_labelColor = value;
	}
	
	private var _alpha:Number = .8;
	
	public function set alpha2(value:Number):void
	{
		_alpha = value;
	}
	
	private var _radius:uint = 5;
	
	public function set radius(value:uint):void
	{
		_radius = value;
	}
	
	override protected function createChildren():void
	{
		super.createChildren();
		
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.ROLL_OVER, onRollOver);
		addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		
		textArea = new TextArea();
		addChild(textArea);
	}
	
	override protected function commitProperties():void
	{
		super.commitProperties();
		
		textArea.selectable = false;
		textArea.editable = false;
		
		textArea.setStyle("backgroundAlpha", 0);
		textArea.setStyle("borderThickness", 0)
		textArea.setStyle("color", _labelColor);
		textArea.setStyle("paddingLeft", 5);
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		graphics.clear();
		graphics.beginFill(_backgroundColor);
		GraphicsUtil.drawRoundRectComplex(graphics, 0, 0, unscaledWidth, unscaledHeight, 0, 0, _radius, _radius);
		
		textArea.text = "Show Details";
		textArea.setActualSize(unscaledWidth, unscaledHeight);
		textArea.wordWrap = false;
		
		var paddingTop:uint  = Math.round((unscaledHeight - textArea.textHeight)/2);
		
		textArea.setStyle("paddingTop", paddingTop);
    }
    
    private function onClick(event:MouseEvent):void
    {
    	(textArea.text == "Show Details") ? textArea.text = "Hide Details" : textArea.text = "Show Details"
    }
    
    private function onRollOver(event:MouseEvent):void
    {
    	alpha = .95;
    }
    
    private function onRollOut(event:MouseEvent):void
    {
    	alpha = 1;
    }
}
}