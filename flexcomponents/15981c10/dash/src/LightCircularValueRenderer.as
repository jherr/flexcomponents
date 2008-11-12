package
{
  import ilog.gauges.gaugesClasses.circular.CircularValueRenderer;
  import ilog.gauges.controls.NumericCircularGauge;
  
  public class LightCircularValueRenderer extends CircularValueRenderer
  {
    public function LightCircularValueRenderer() {
    }   
    
    protected override function updateDisplayList(unscaledWidth:Number, 
                                                  unscaledHeight:Number):void {
      NumericCircularGauge(gauge).scaleRenderer.invalidateDisplayList();
    }
  }
}