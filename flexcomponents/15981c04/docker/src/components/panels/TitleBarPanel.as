////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2007 Teoti Graphix http://www.teotigraphix.com/eula
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package components.panels
{

import com.teotiGraphix.barControls.ITitleBarControl;
import com.teotiGraphix.controls.TitleBarFX;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;

import mx.containers.Panel;
import mx.core.ClassFactory;
import mx.core.IFactory;
import mx.core.mx_internal;
import mx.styles.ISimpleStyleClient;

use namespace mx_internal;

[Style(name="titleBarStyleName", type="String", inherit="no")]

/**
 * @exclude
 */
public class TitleBarPanel extends Panel
{
	//--------------------------------------------------------------------------
	//
	//  Protected Fields :: Properties
	//
	//--------------------------------------------------------------------------
	
	protected var titleBarInstance:ITitleBarControl;
	
	protected var regX:Number;
	protected var regY:Number;	
	
	//--------------------------------------------------------------------------
	//
	//  Public Get-Set :: Properties
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  title
    //----------------------------------
	
	protected var titleChanged:Boolean = false;
	override public function set title(value:String):void
	{
		super.title = value;
		titleChanged = true;
	}

    //----------------------------------
    //  titleIcon
    //----------------------------------
	
	protected var titleIconChanged:Boolean = false;
	override public function set titleIcon(value:Class):void
	{
		super.titleIcon = value;
		titleIconChanged = true;
	}

    //----------------------------------
    //  status
    //----------------------------------
	
	protected var statusChanged:Boolean = false;
	override public function set status(value:String):void
	{
		super.status = value;
		statusChanged = true;
	}

    //----------------------------------
    //  titleBarControl
    //----------------------------------
	
	public function get titleBarControl():ITitleBarControl
	{
		return titleBarInstance;
	}
	
	//----------------------------------
	//  titleBarRenderer
	//----------------------------------
	
	[Bindable("titleBarRendererChanged")]
	
	private var _titleBarRenderer:IFactory;
	protected var titleBarRendererChanged:Boolean = false;
	public function get titleBarRenderer():IFactory
	{
		return _titleBarRenderer;
	}
	public function set titleBarRenderer(value:IFactory):void
	{
		if (_titleBarRenderer != value)
		{
			_titleBarRenderer = value;
			titleBarRendererChanged = true;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
			dispatchEvent(new Event("titleBarRendererChanged"));
		}
	}
	
	//--------------------------------------------------------------------------
	//
	// Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor.
	 */
	public function TitleBarPanel()
	{
		super();
		
		_titleBarRenderer = new ClassFactory(TitleBarFX);
	}
	
	//--------------------------------------------------------------------------
	//
	// Overriden Protected :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	override protected function commitProperties():void
	{
		super.commitProperties();
		
		if (titleBarRendererChanged)
		{
			commitTitleBarRenderer();	
			titleBarRendererChanged = false;
		}
		
		if (titleIconChanged)
		{
			commitTitleIcon();
			titleIconChanged = false;
		}
		
		if (titleChanged)
		{
			commitTitle();
			titleChanged = false;
		}
	}
	
	/**
	 * @private
	 */
	override protected function createChildren():void
	{
		super.createChildren();
		
		if (titleBar)
		{
			rawChildren.removeChild(titleBar);
		}
		
		createTitleBar();
	}
	
	/**
	 * @private
	 */
	override protected function layoutChrome(unscaledWidth:Number, 
											 unscaledHeight:Number):void
	{
		super.layoutChrome(unscaledWidth, unscaledHeight);
		
		if (titleBarInstance)
		{
			titleBarInstance.move(0, 0);
			titleBarInstance.setActualSize(
				unscaledWidth, 
				getHeaderHeight());
		}
	}

	/**
	 * @private
	 */
	override protected function getHeaderHeight():Number
	{
		var headerHeight:Number = getStyle("headerHeight");
		
		if (isNaN(headerHeight) && titleBarInstance)
			headerHeight = titleBarInstance.getExplicitOrMeasuredHeight();
			
		return headerHeight;
	}
	
	//--------------------------------------------------------------------------
	//
	// Overriden Public :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	override public function styleChanged(styleProp:String):void
	{
		super.styleChanged(styleProp);
		
		var allStyles:Boolean = !styleProp || styleProp == "styleName";
		
		if (allStyles || styleProp == "titleStyleName")
		{
			var titleStyleName:String = getStyle("titleStyleName");
			if (titleBarInstance)
			{
				titleBarInstance.setStyle("labelStyleName", titleStyleName);
			}
		}
	}
	
	//--------------------------------------------------------------------------
	//
	// Protected Commit :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	protected function commitTitleBarRenderer():void
	{
		createTitleBar();
	}

	/**
	 * @private
	 */
	protected function commitTitleIcon():void
	{
		if (titleBarInstance)
		{
			titleBarInstance.titleIcon = titleIcon;
		}
	}

	/**
	 * @private
	 */
	protected function commitTitle():void
	{
		if (titleBarInstance)
		{
			titleBarInstance.title = title;
		}
	}
	
	//--------------------------------------------------------------------------
	//
	// Protected Create :: Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	protected function createTitleBar():void
	{
		if (titleBarInstance)
		{
			rawChildren.removeChild(DisplayObject(titleBarInstance));
		}
		
		if (titleBarRenderer)
		{
			titleBarInstance = titleBarRenderer.newInstance();
			
			var style:Object = getStyle("titleBarStyleName");
			if (style && titleBarInstance is ISimpleStyleClient)
			{
				ISimpleStyleClient(titleBarInstance).styleName = style;
			}
			
			var titleStyleName:String = getStyle("titleStyleName");
			titleBarInstance.setStyle("labelStyleName", titleStyleName);
			
			titleBarInstance.addEventListener(
				MouseEvent.MOUSE_DOWN,
				titleBar_mouseDownHandler);
			
			rawChildren.addChild(DisplayObject(titleBarInstance));
		}
	}
	
	//--------------------------------------------------------------------------
	//
	// Overriden Protected :: Handlers
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	override protected function startDragging(event:MouseEvent):void
	{
		regX = event.stageX - x;
		regY = event.stageY - y;
		
		systemManager.addEventListener(
			MouseEvent.MOUSE_MOVE,
			systemManager_mouseMoveHandler,
			true);
			
		systemManager.addEventListener(
			MouseEvent.MOUSE_UP,
			systemManager_mouseUpHandler,
			true);
			
		systemManager.stage.addEventListener(
			Event.MOUSE_LEAVE,
			stage_mouseLeaveHandler);
	}
	
	/**
	 * @private
	 */
	override protected function stopDragging():void
	{
		systemManager.removeEventListener(
			MouseEvent.MOUSE_MOVE,
			systemManager_mouseMoveHandler,
			true);
			
		systemManager.removeEventListener(
			MouseEvent.MOUSE_UP,
			systemManager_mouseUpHandler,
			true);
			
		systemManager.stage.removeEventListener(
			Event.MOUSE_LEAVE,
			stage_mouseLeaveHandler);
					
		regX = NaN;
		regY = NaN;
	}
	
	//--------------------------------------------------------------------------
	//
	// Protected :: Handlers
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	protected function titleBar_mouseDownHandler(event:MouseEvent):void
	{
		if (enabled && isPopUp && isNaN(regX))
			startDragging(event);
	}
	
	/**
	 * @private
	 */
	protected function systemManager_mouseMoveHandler(event:MouseEvent):void
	{
		event.stopImmediatePropagation();
		move(event.stageX - regX, event.stageY - regY);
	}
	
	/**
	 * @private
	 */
	protected function systemManager_mouseUpHandler(event:MouseEvent):void
	{
		if (!isNaN(regX))
			stopDragging();
	}
	
	/**
	 * @private
	 */
	protected function stage_mouseLeaveHandler(event:Event):void
	{
		if (!isNaN(regX))
			stopDragging();
	}
}
}