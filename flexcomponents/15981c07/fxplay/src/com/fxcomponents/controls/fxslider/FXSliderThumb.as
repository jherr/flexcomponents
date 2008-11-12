package com.fxcomponents.controls.fxslider
{
import mx.controls.Button;
import mx.core.mx_internal;

use namespace mx_internal;

public class FXSliderThumb extends Button
{
	public function FXSliderThumb()
	{
		super();
		
		stickyHighlighting = true;
	}
	
	override protected function measure():void
	{
		super.measure();

		measuredWidth = 9;
		measuredHeight = 9;
	}
}
}