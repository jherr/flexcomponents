package com.fxcomponents.controls
{
import com.fxcomponents.controls.fxslider.FXSliderThumb;
import com.fxcomponents.skins.SliderThumbSkin;
import com.fxcomponents.skins.SliderTrackSkin;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.core.IFlexDisplayObject;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.effects.Move;
import mx.events.SliderEvent;
import mx.events.TweenEvent;
import mx.styles.ISimpleStyleClient;
import mx.styles.StyleProxy;

use namespace mx_internal;

[Event(name="change", type="mx.events.SliderEvent")]
[Event(name="thumbDrag", type="mx.events.SliderEvent")]
[Event(name="thumbPress", type="mx.events.SliderEvent")]
[Event(name="thumbRelease", type="mx.events.SliderEvent")]

[Style(name="thumbColor", type="uint", format="Color", inherit="no")]
[Style(name="thumbOutlineColor", type="uint", format="Color", inherit="no")]
[Style(name="thumbSkin", type="Class", inherit="no", states="up, over, down, disabled")]
[Style(name="thumbUpSkin", type="Class", inherit="no")]
[Style(name="thumbOverSkin", type="Class", inherit="no")]
[Style(name="thumbDownSkin", type="Class", inherit="no")]
[Style(name="thumbDisabledSkin", type="Class", inherit="no")]
[Style(name="trackSkin", type="Class", inherit="no")]
[Style(name="trackHighlightSkin", type="Class", inherit="no")]
[Style(name="trackColor", type="uint", format="Color", inherit="no")]

public class FXSlider extends UIComponent
{
	public function FXSlider()
	{
		super();
	}
	
	private var g:Graphics;
	private var e:SliderEvent;
	private var skinClass:Class;
	private var xOffset:Number;
	private var thumbIsPressed:Boolean = false;
	
	private var moveTween:Move;
	
	/** display objects */
	
	protected var track:IFlexDisplayObject;
	protected var highlight:IFlexDisplayObject;
	protected var bound:Sprite;
	protected var thumb:FXSliderThumb;
	
	/** style */
	
	private var thumbSkin:Class;
	private var trackSkin:Class;
	private var trackHighlightSkin:Class;
	private var trackColor:uint;
	
	/** properties */
	
	private var _maximum:Number = 100;
	
    public function get maximum():Number
    {
        return _maximum;
    }
	
    public function set maximum(value:Number):void
    {
        _maximum = value;
        
        invalidateProperties();
        invalidateDisplayList();
    }
	
	private var _value:Number = 0;
	
	private var valueChanged:Boolean = false;
	
	public function set value(value:Number):void
	{
		_value = value;
		
		valueChanged = true;
		
		invalidateProperties();
		invalidateDisplayList();
	}
	
	public function get value():Number
	{
		return (thumb.x - thumb.width/2)/((unscaledWidth - thumb.width)/100)*(maximum/100);
	}
	
	/** */
	
	private function get boundMin():Number
	{
		return thumb.width/2
	}
	
	private function get boundMax():Number
	{
		return Math.max(thumb.width/2, bound.width - thumb.width/2) ;
	}
	
	/**
	 * Creates any child components of the component. For example, the
	 * ComboBox control contains a TextInput control and a Button control
	 * as child components.
	 */
	
	override protected function createChildren():void
	{
		super.createChildren();
		
		thumbSkin = getStyle("thumbSkin");
        if(!thumbSkin)
        	thumbSkin = com.fxcomponents.skins.SliderThumbSkin;
		
		trackSkin = getStyle("trackSkin");
        if(!trackSkin)
        	trackSkin = com.fxcomponents.skins.SliderTrackSkin;
		
		trackHighlightSkin = getStyle("trackHighlightSkin");
        if(!trackHighlightSkin)
        	trackHighlightSkin = com.fxcomponents.skins.SliderHighlightSkin;
		
		if(!getStyle("thumbSkin"))
			setStyle("thumbSkin", SliderThumbSkin);
		
		if(!getStyle("trackColor"))
			setStyle("trackColor", 0xaaaaaa);
			
		if(!getStyle("thumbColor"))
			setStyle("thumbColor", 0xcccccc);
			
		if(!getStyle("thumbOutlineColor"))
			setStyle("thumbOutlineColor", 0x555555);
		
		systemManager.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		
		if (!track)
        {
            skinClass = trackSkin;
			
            track = new skinClass();

            if (track is ISimpleStyleClient)
                ISimpleStyleClient(track).styleName = this;

            addChild(DisplayObject(track)); 
        }
        
        if (!highlight)
        {
            skinClass = trackHighlightSkin;
			
            highlight = new skinClass();

            if (track is ISimpleStyleClient)
                ISimpleStyleClient(highlight).styleName = this;

            addChild(DisplayObject(highlight)); 
        }
		
		bound = new Sprite();
		addChild(bound);
		
		bound.addEventListener(MouseEvent.MOUSE_DOWN, bound_onMouseDown);
		
		thumb = new FXSliderThumb();
		addChild(thumb);
		
		thumb.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		
		moveTween = new Move(thumb);
		
		moveTween.addEventListener(TweenEvent.TWEEN_UPDATE, onTweenUpdate);
		moveTween.addEventListener(TweenEvent.TWEEN_END, onTweenEnd);
		
		moveTween.duration = 300;
	}
	
	/**
	 * Commits any changes to component properties, either to make the 
	 * changes occur at the same time, or to ensure that properties are set in 
	 * a specific order.
	 */
	
	override protected function commitProperties():void
	{
		super.commitProperties();
		
		thumb.styleName = new StyleProxy(this, null);
        thumb.skinName = "thumbSkin";
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
		
		if(valueChanged)
        {
        	thumb.x = thumb.width/2 + Math.round((_value/_maximum)*(unscaledWidth - thumb.width));
        	valueChanged = false;
        }
		
		// draw
		
		var x:int;
        var y:int;
        var w:int;
        var h:int;
		
        w = Math.round(unscaledHeight/2)*2;
        h = unscaledHeight;
        
        thumb.setActualSize(w, h);
        
        g = bound.graphics;
        
        g.clear();
        g.beginFill(0xffaaaa, 0);
        g.drawRect(0, 0, unscaledWidth, unscaledHeight);
        
        // position
		
		thumb.x = Math.max(thumb.width/2, thumb.x);
        
        // size
        
        track.setActualSize(unscaledWidth, unscaledHeight);
		highlight.setActualSize(thumb.x, unscaledHeight);		
    }
    
    override protected function measure():void
	{
		super.measure();
		
		measuredWidth = 200;
		measuredHeight = 13;
	}
	
	/** event handlers */
	
	private function onMouseDown(event:MouseEvent):void
	{
		systemManager.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, true);
		
		xOffset = event.localX;
		
		thumbIsPressed = true;
		
		e = new SliderEvent(SliderEvent.THUMB_PRESS);
        e.value = value;
        dispatchEvent(e);
	}
	
	private function onMouseUp(event:MouseEvent):void
	{
		systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, true);
		
		if(thumbIsPressed)
		{
			e = new SliderEvent(SliderEvent.THUMB_RELEASE);
	        e.value = value;
	        dispatchEvent(e);
	        
	        e = new SliderEvent(SliderEvent.CHANGE);
	        e.value = value;
	        dispatchEvent(e);
	        
	        thumbIsPressed = false;
		}
	}
	
	private function onMouseMove(event:MouseEvent):void
	{
		var pt:Point = new Point(event.stageX, event.stageY);
		pt = globalToLocal(pt);
			
		thumb.x = Math.min(Math.max(pt.x - xOffset, boundMin), boundMax);
		
		e = new SliderEvent(SliderEvent.THUMB_DRAG);
        e.value = value;
        dispatchEvent(e);
        
        invalidateDisplayList();
	}
	
	private function bound_onMouseDown(event:MouseEvent):void
	{
		moveTween.xTo = Math.min(Math.max(event.localX, boundMin), boundMax);
		moveTween.play()
	}
	
	private function onTweenUpdate(event:TweenEvent):void
	{
		invalidateDisplayList();
	}
	
	private function onTweenEnd(event:TweenEvent):void
	{
		e = new SliderEvent(SliderEvent.CHANGE);
        e.value = value;
        dispatchEvent(e);
	}
}
}