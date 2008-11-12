package com.fxcomponents.controls
{
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;

import mx.controls.Image;
import mx.core.UIComponent;
import mx.effects.Blur;
import mx.effects.Move;
import mx.effects.easing.Quartic;
import mx.events.ListEvent;

[Event(name="change", type="mx.events.ListEvent")]

public class Reel extends UIComponent
{
	public function Reel()
	{
		super();
	}
	
	// flags
	
	protected var imagesLoaded:Boolean = false;
	
	private var index:int;
	private var nImages:uint;
	private var nLoadadImages:uint = 0;
	
	protected var reelContainer:UIComponent;
	protected var reel:UIComponent;
	protected var reelMask:Sprite;
	
	private var tween:Move;
	private var images:Array;
	private var blur:Blur;
	private var request:URLRequest;
	
	protected var imgW:Number = 0;
	protected var imgH:Number = 0;
	
	protected var items:Object;
	
	protected var _dataProvider:Object;
	
	public function set dataProvider(value:Object):void
    {     
		if(!value)
			return;
		
		_dataProvider = value;
		
		/*
		if(value is Array)
			trace("Reel -> dp is Array");
		
		if(value is XML)
			trace("Reel -> dp is XML");
		
		if(value is XMLList)
			trace("Reel -> dp is XMLList");
		
		if(value is XMLListCollection)
			trace("Reel -> dp is XMLListCollection");
		
		if(value is ArrayCollection)
			trace("Reel -> dp is ArrayCollection");
		*/
		
		invalidateProperties();
		invalidateDisplayList();
    }
	
	private var _tweenDuration:int = 800;
	
	public function set tweenDuration(value:int):void
	{
		_tweenDuration = value;
	}
	
	private var _imageField:String = "image";
	
	public function set imageField(value:String):void
	{
		_imageField = value;
	}
	
	private var _imagePath:String;
	
	public function set imagePath(value:String):void
	{
		_imagePath = value;
	}
	
	private var _offset:uint = 0;
	
	public function set offset(value:uint):void
	{
		_offset = value;
	}
	
	private var _selectedIndex:int = 0;
	
	private var position:int = 0;
	
    [Bindable("change")]
    [Bindable("valueCommit")]
    
    public function get selectedIndex():int
    {
        return _selectedIndex;
    }
    
    public function set selectedIndex(value:int):void
    {
		value = Math.min(value, items.length - 1);
		
		// distance is measured in positions
		
		var distance:int = (nImages + value - _selectedIndex)%nImages
		
		var i:int = _selectedIndex;;
		var counter:int = 0;
		
		if(distance < nImages/2)
		{
			while(i !== value)
		    {
		    	counter++
		    	i++
		    	if(i == nImages)
		    		i = 0;
		    	
		    	reel.addChild(images[i]);
		    	images[i].x = -position*imgW + counter*imgW;
		    }
		    
		    position -= distance;
		}
		else
		{
			while(i !== value)
		    {
		    	counter++
		    	i--
		    	if(i < 0)
		    		i = nImages - 1;
		    	
		    	reel.addChild(images[i]);
		    	images[i].x = -position*imgW - counter*imgW;
		    }
		    
		    position += nImages - distance;
		}
		
		tween.xTo = position*imgW + _offset;
		
		tween.stop();
		tween.play();
		
		_selectedIndex = value;
		
		dispatchEvent(new ListEvent(ListEvent.CHANGE));
    }
	
	public function get selectedItem():Object
	{
		return images[_selectedIndex];
	}
	
	override protected function createChildren():void
	{
		super.createChildren();
		
		reelContainer = new UIComponent();
		addChild(reelContainer);
		
		reel = new UIComponent();
		reelContainer.addChild(reel);
		
		reelMask = new Sprite();
		addChild(reelMask);
		
		reelContainer.mask = reelMask;
		
		tween = new Move(reel);
		tween.duration = _tweenDuration;
		tween.easingFunction = Quartic.easeInOut;
		
		images = new Array();
		
		blur = new Blur(reel);
		blur.duration = _tweenDuration;
		
		request = new URLRequest();
	}
	
	override protected function commitProperties():void
	{
		super.commitProperties();
		
		if(_dataProvider)
		{
			var i:uint;
			var n:uint;
			
			if (_dataProvider is XML)
	        {
	            //trace("set dp is XML");
	            	            
	            items = new Array();
	            
				n = _dataProvider..@[_imageField].length();
				
	            for(i = 0; i<n; i++)
	            {
	            	items[i] = [];
	            	items[i][_imageField] = _dataProvider..@[_imageField][i];
	            }
	        }
			
			if(_dataProvider is XMLList)
			{
				//trace("set dp is XMLList");
				
				items = new Array();
	            
				n = _dataProvider.length();
				
	            for(i = 0; i<n; i++)
	            {
	            	items[i] = [];
	            	items[i][_imageField] = _dataProvider[i]..@[_imageField];
	            }
			}
			
			if (_dataProvider is Array)
	        {
	            //trace("set dp is Array");
	            
	            items = _dataProvider as Array;
	        }
	        
	        nImages = items.length;
	        
	        for(i = 0; i<items.length; i++)
			{
				var url:String = _imagePath + items[i][_imageField];
				images[i] = new Image();
				images[i].load(url);
				images[i].name = url;
				images[i].addEventListener(Event.INIT, onInit);
				images[i].addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			}
			
			reel.addChild(images[0]);
			index = 0;
		}
	}
	
	override protected function measure():void
	{
		super.measure();
		
		measuredMinWidth = measuredWidth = imgW;
		measuredMinHeight = measuredHeight = imgH;
	}
	
	protected function onInit(event:Event):void
	{
		if(event.currentTarget.contentWidth !== imgW && imgW !== 0)
			trace("Warning: Your images are not in the same size.");
		
		imgW = event.currentTarget.contentWidth;
		imgH = event.currentTarget.contentHeight;
		
		event.currentTarget.setActualSize(imgW, imgH);
		
		nLoadadImages++;
		
		if(nLoadadImages == images.length)
		{
			imagesLoaded = true;
			//trace("All Images Loaded");
			invalidateProperties();
			invalidateDisplayList();
			invalidateSize();
		}
	}
	
	private function onIOError(event:IOErrorEvent):void
	{
		trace("Error: "+event.currentTarget.name+" could not be loaded.")
	}
}
}