package
{
  import ilog.gauges.controls.NumericRectangularGauge;
  import ilog.gauges.gaugesClasses.rectangular.RectangularValueRenderer;
  
  public class LightRectangularValueRenderer extends RectangularValueRenderer
  {
    public function LightRectangularValueRenderer() {
    }   
    
    protected override function updateDisplayList(unscaledWidth:Number, 
                                                  unscaledHeight:Number):void {      
       NumericRectangularGauge(gauge).scaleRenderer.invalidateDisplayList();   
    }
  }
}