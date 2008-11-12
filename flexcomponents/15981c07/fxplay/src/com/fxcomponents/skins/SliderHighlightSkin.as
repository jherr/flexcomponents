////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2004-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.fxcomponents.skins
{

import mx.skins.Border;

/**
 *  The skin for the track in a Slider.
 */
public class SliderHighlightSkin extends Border 
{
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
	 *  Constructor.
	 */
	public function SliderHighlightSkin()
	{
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  measuredWidth
	//----------------------------------

	/**
	 *  @private
	 */
	override public function get measuredWidth():Number
	{
		return 200;
	}

	//----------------------------------
	//  measuredHeight
	//----------------------------------

	/**
	 *  @private
	 */
	override public function get measuredHeight():Number
	{
		return 7;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
	
    /**
	 *  @private
	 */
	override protected function updateDisplayList(w:Number, h:Number):void
	{	
		super.updateDisplayList(w, h);
		
		var trackColor:Number = getStyle("themeColor");
		
		graphics.clear();
		
		drawRoundRect(0, 0, w, h, 0, trackColor, 1);
	}
}

}
