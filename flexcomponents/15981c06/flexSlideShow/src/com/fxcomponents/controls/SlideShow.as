package com.fxcomponents.controls
{
import com.fxcomponents.controls.slideshow.Arrow;
import com.fxcomponents.controls.slideshow.DetailsButton;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;

import mx.controls.TextArea;
import mx.core.UIComponent;
import mx.effects.Move;
import mx.events.ListEvent;
import mx.utils.GraphicsUtil;

[Style(name="panelColor", type="uint", format="Color")]
[Style(name="panelAlpha", type="Number")]
[Style(name="arrowColor", type="uint", format="Color")]
[Style(name="titleColor", type="uint", format="Color", inherit="yes")]
[Style(name="detailsColor", type="uint", format="Color")]
[Style(name="detailsPanelColor", type="uint", format="Color")]
[Style(name="detailsPanelAlpha", type="Number")]

public class SlideShow extends Reel
{
	public function SlideShow()
	{
		super();
	}
	
	// styles
	
	private var panelColor:uint;
	private var panelAlpha:Number;
	private var arrowColor:uint;
	private var detailsColor:uint;
	private var detailsPanelColor:uint;
	private var detailsPanelAlpha:Number;
	
	// flags
	
	private var defaultAssetsDrawn:Boolean = false;
	
	//
	
	private var arrowsContainer:UIComponent;
	private var lArrow:Arrow; 
	private var rArrow:Arrow;
	private var arrowsMask:Shape;
	private var panel:Sprite;
	private var lButton:Sprite;
	private var rButton:Sprite;
	private var lArrowTween:Move;
	private var rArrowTween:Move;
	private var titleTA:TextArea;
	private var detailsButton:DetailsButton;
	private var detailsPanel:UIComponent;
	private var detailsTA:TextArea;
	
	private var g:Graphics;
	private var p:int; // padding
	
	private var _prefixText:String = "";
	
	public function set prefixText(value:String):void
	{
		_prefixText = value;
	}
	
	private var _captionField:String;
	
	public function set captionField(value:String):void
	{
		_captionField = value;
	}
	
	private var _detailsField:String;
	
	public function set detailsField(value:String):void
	{
		_detailsField = value;
	}
	
	/**
	 * Creates any child components of the component. For example, the
	 * ComboBox control contains a TextInput control and a Button control
	 * as child components.
	 */
	
	override protected function createChildren():void
	{
		addEventListener(ListEvent.CHANGE, onChange);
		
		arrowsContainer = new UIComponent();
		addChild(arrowsContainer);
		
		lArrow = new Arrow();
		lArrow.direction = "left";
		lArrow.addEventListener(MouseEvent.CLICK, onClick);
		arrowsContainer.addChild(lArrow);
		
		rArrow = new Arrow();
		rArrow.direction = "right";
		rArrow.addEventListener(MouseEvent.CLICK, onClick);
		arrowsContainer.addChild(rArrow);
		
		arrowsMask = new Shape();
		addChild(arrowsMask)
		
		arrowsContainer.mask = arrowsMask;
		
		panel = new Sprite();
		addChild(panel);
		
		super.createChildren();
		
		titleTA = new TextArea();
		addChild(titleTA);
		
		detailsPanel = new UIComponent();
		addChild(detailsPanel);
		
		detailsTA = new TextArea();
		addChild(detailsTA);
		
		lButton = new Sprite();
		lButton.name = "lButton";
		addChild(lButton);
		
		lButton.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
		lButton.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		lButton.addEventListener(MouseEvent.CLICK, onClick);
		
		rButton = new Sprite();
		rButton.name = "rButton";
		addChild(rButton);
		
		rButton.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
		rButton.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		rButton.addEventListener(MouseEvent.CLICK, onClick);
		
		detailsButton = new DetailsButton();
		detailsButton.name = "detailsButton";
		addChild(detailsButton);
		
		detailsButton.addEventListener(MouseEvent.CLICK, onClick);
	}
	
	/**
	 * Commits any changes to component properties, either to make the 
	 * changes occur at the same time, or to ensure that properties are set in 
	 * a specific order.
	 */
	
	override protected function commitProperties():void
	{
		super.commitProperties();
		
		if(unscaledWidth < imgW)
			trace("Warning: The specified width is smaller than the images width.");
		
		if(imagesLoaded)
			p = Math.round((unscaledWidth - imgW)/2);
		else
			p = 5;
		
		panelColor = getStyle("panelColor");
		if(!panelColor)
			panelColor = 0;
		
		panelAlpha = getStyle("panelAlpha");
		if(!panelAlpha)
			panelAlpha = .4;
		
		arrowColor = getStyle("arrowColor");
		if(!arrowColor)
			arrowColor = 0xffffff;
		
		detailsColor = getStyle("detailsColor");
		if(!detailsColor)
			detailsColor = 0x666666;
			
		detailsPanelColor = getStyle("detailsPanelColor");
		if(!detailsPanelColor)
			detailsPanelColor = 0xffffff;
			
		detailsPanelAlpha = getStyle("detailsPanelAlpha");
		if(!detailsPanelAlpha)
			detailsPanelAlpha = .8;
		
		detailsButton.labelColor = detailsColor;
		detailsButton.backgroundColor = detailsPanelColor;
		
		detailsPanel.visible = false;
		detailsTA.visible = false;
		
		lArrow.outerColor = panelColor;
		lArrow.innerColor = arrowColor;
		lArrow.panelAlpha = panelAlpha;
		
		rArrow.outerColor = panelColor;
		rArrow.innerColor = arrowColor;
		rArrow.panelAlpha = panelAlpha;
		
		titleTA.selectable = false;
		titleTA.editable = false;
		titleTA.setStyle("backgroundAlpha", 0);
		titleTA.setStyle("borderThickness", 0)
		titleTA.setStyle("color", getStyle("titleColor"));
		titleTA.setStyle("paddingLeft", 5);
		
		detailsTA.selectable = false;
		detailsTA.editable = false;
		detailsTA.setStyle("backgroundAlpha", 0);
		detailsTA.setStyle("borderThickness", 0)
		detailsTA.setStyle("color", detailsColor);
		
		detailsTA.setStyle("paddingLeft", 5);
		detailsTA.setStyle("paddingTop", 5);
		detailsTA.setStyle("paddingRight", 5);
		detailsTA.setStyle("paddingBottom", 5);
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
		
		if(!imagesLoaded)
		{
			g = panel.graphics;
			
			g.clear();
			g.beginFill(panelColor, panelAlpha);
			g.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, 3*p, 3*p);
		}
		
		if(imagesLoaded && !defaultAssetsDrawn)
		{
			// draw
	        
	        g = reelMask.graphics;
			
			g.clear();
			g.beginFill(0xffcccc);
			GraphicsUtil.drawRoundRectComplex(g, 0, 0, imgW, imgH, 0, 0, 0, 0);
			
			g = lButton.graphics;
			
			g.clear();
			g.beginFill(0xff0000, 0);
			g.drawRect(0, 0, imgW/2, imgH);
			
			g = rButton.graphics;
			
			g.clear();
			g.beginFill(0xff0000, 0);
			g.drawRect(0, 0, imgW/2, imgH);
	        
	        g = arrowsMask.graphics;
			
			g.clear();
			g.beginFill(0xff0000, .2);
			g.drawRect(-lArrow.width, 0, 18, imgH);
			g.drawRect(imgW + 2*p, 0, 18, imgH);
	        
	        // position, top to bottom
	        
	        titleTA.setActualSize(imgW, unscaledHeight - imgH - 21 - 3*p);
			titleTA.x = p;
			titleTA.y = p;
	        
	        reelContainer.x = reelMask.x = p;
			reelContainer.y = reelMask.y = titleTA.height + 2*p;
	        
			lArrow.x = 0;
			lArrow.y = Math.round((imgH - lArrow.heightOuter)/2);
			
			rArrow.x = imgW - rArrow.width;
			rArrow.y = lArrow.y;
			
			detailsButton.setActualSize(imgW, 20);
			detailsButton.x = p;
			detailsButton.y = reelContainer.y + imgH + 1;
			
			rButton.x = unscaledWidth/2;
			
			lArrowTween = new Move(lArrow)
			lArrowTween.duration = 100;
			
			rArrowTween = new Move(rArrow)
			rArrowTween.duration = 100;
			
			onChange(new ListEvent(ListEvent.CHANGE));
			defaultAssetsDrawn = true;
		}
		
		if(imagesLoaded)
		{
			g = detailsPanel.graphics;
	        
	        g.clear();
	        g.beginFill(detailsPanelColor, detailsPanelAlpha);
			GraphicsUtil.drawRoundRectComplex(g, 0, 0, imgW, detailsTA.textHeight + 15, 5, 5, 0, 0)
			
			detailsTA.setActualSize(imgW, detailsTA.textHeight +15);
	        
	        detailsTA.x = p;
	        detailsTA.y = reelContainer.y + imgH - detailsTA.height;
	        
	        detailsPanel.x = p;
	        detailsPanel.y = detailsTA.y;
		}
    }
    
    /**
    * Sets the default size and default minimum size of the component.
    */
    
    override protected function measure():void
	{
		super.measure();
		
		measuredMinWidth = measuredWidth += 10
		measuredMinHeight = measuredHeight += 10
	}
    
	private function onRollOver(event:MouseEvent):void
	{
		if(event.currentTarget.name == "lButton")
		{
			lArrowTween.xFrom = Math.round(lArrow.x);
			lArrowTween.xTo = -lArrow.width;
			
			lArrowTween.stop();
			lArrowTween.play();
			
			redraw(lButton, unscaledWidth/2+25, unscaledHeight);
			lButton.x = -25
		}
		
		if(event.currentTarget.name == "rButton")
		{
			rArrowTween.xFrom = Math.round(rArrow.x);
			rArrowTween.xTo = panel.width;;
			
			rArrowTween.stop();
			rArrowTween.play();
			
			redraw(rButton, unscaledWidth/2+25, unscaledHeight);
		}
	}
	
	private function onRollOut(event:MouseEvent):void
	{
		if(event.currentTarget.name == "lButton")
		{
			lArrowTween.xFrom = Math.round(lArrow.x);
			lArrowTween.xTo = 0;
			
			lArrowTween.end();
			lArrowTween.play();
			
			redraw(lButton, unscaledWidth/2, unscaledHeight);
			lButton.x = 0;
		}
		
		if(event.currentTarget.name == "rButton")
		{
			rArrowTween.xFrom = Math.round(rArrow.x);
			rArrowTween.xTo = panel.width - rArrow.width;
			
			rArrowTween.end();
			rArrowTween.play();
			
			redraw(rButton, unscaledWidth/2, unscaledHeight);
		}
	}
	
    private function onClick(event:MouseEvent):void
    {
    	var n:uint = items.length;
    	
    	if(event.currentTarget.name == "lButton")
			selectedIndex = (n + (selectedIndex - 1))%n;
		
		if(event.currentTarget.name == "rButton")
			selectedIndex = (selectedIndex + 1)%n;
			
		if(event.currentTarget.name == "detailsButton")
		{
			detailsPanel.visible = !detailsPanel.visible;
			detailsTA.visible = !detailsTA.visible;
			
			invalidateDisplayList();
		}
    }
    
    private function onChange(event:ListEvent):void
    {
    	var caption:String;
    	var details:String;
    	
    	if (_dataProvider is XML || _dataProvider is XMLList)
    	{
            caption = _dataProvider..@[_captionField][selectedIndex];
            details = _dataProvider..@[_detailsField][selectedIndex];
		}
		
		if (_dataProvider is Array)
		{
            caption = _dataProvider[selectedIndex][_captionField];
            details = _dataProvider[selectedIndex][_detailsField];
		}
		
		titleTA.htmlText = _prefixText + caption;
		detailsTA.htmlText = details;
		
		invalidateDisplayList();
	}
    
    private function redraw(target:Sprite, width:uint, height:uint):void
	{
		target.graphics.clear();
		target.graphics.beginFill(0xff0000, 0);
		target.graphics.drawRect(0, 0, width, height);
	}
}
}