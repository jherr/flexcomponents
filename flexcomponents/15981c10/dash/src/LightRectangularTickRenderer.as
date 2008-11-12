package
{
  import ilog.gauges.TickItem;
  import ilog.gauges.gaugesClasses.rectangular.IRectangularNumericScale;
  import ilog.gauges.gaugesClasses.rectangular.RectangularValueRenderer;
  import ilog.gauges.rectangular.renderers.RectangularScaleRenderer;
  import ilog.utils.ColorUtil;
  
  import mx.core.IDataRenderer;
  import mx.events.FlexEvent;
  import mx.skins.ProgrammaticSkin;
  import mx.utils.ColorUtil;

  public class LightRectangularTickRenderer extends ProgrammaticSkin implements IDataRenderer
  {
    public function LightRectangularTickRenderer() {
      super();
    }
    
    private var _data:Object;
    
    [Inspectable(environment="none")]
    [Bindable("dataChange")]       
    
    public function get data():Object {
      return _data;
    }

    public function set data(value:Object):void {
      _data = value;
      invalidateDisplayList();
      dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
    }
    
    private function get valueRenderer():RectangularValueRenderer {
      if (parent == null)
        return null;
      var gauge:Object = (parent.parent as RectangularScaleRenderer).gauge;
      if (gauge == null)
        return null;
      return gauge.valueRenderer as RectangularValueRenderer;      
    }   
    
    protected override function updateDisplayList(unscaledWidth:Number, 
                                                  unscaledHeight:Number):void {

      var value:Number = NaN;
      var scale:IRectangularNumericScale = TickItem(data).scale as IRectangularNumericScale;
      var rvr:RectangularValueRenderer = valueRenderer;
      if (rvr != null) {
        if (!isNaN(rvr.transitionPosition)) {
          value = scale.valueForPosition(rvr.transitionPosition) as Number;
        } else {
          value = rvr.value as Number;
        }
      }
      graphics.clear();
      // choose base color depending on the value
      var color:uint = getColor(Number(TickItem(data).value) / (scale.maximum - scale.minimum));      
      // apply some brightness depending on whether the tick lighted or not      
      if (!isNaN(value) && value != 0 && TickItem(data).value <= value) {
        graphics.beginFill(lightColor(color));
        graphics.lineStyle(1, color);
      } else {
        graphics.beginFill(mx.utils.ColorUtil.adjustBrightness(color,-100));
      }
      graphics.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, 5, 5);
      graphics.endFill();
    }    
    
    private function getColor(value:Number):uint {
      return ilog.utils.ColorUtil.getHSBColor(value * 0.36,
                                   0.9,
                                   0.6);
    }
    
    private static function lightColor(rgb:uint):uint {
      var f:Number = 1.0/0.3;
      var r:Number = ((rgb >> 16) & 0xff);
      var g:Number = ((rgb >> 8) & 0xff);
      var b:Number = (rgb & 0xff);     
      if ( r == 0 && g == 0 && b == 0) {
        return (f << 16) | (f << 8) | f;
      }
      if (r > 0 && r < f) r = f;
      if (g > 0 && g < f) g = f;
      if (b > 0 && b < f) b = f;
      return Math.min(r / 0.7, 255) << 16 |
             Math.min(g / 0.7, 255) << 8  |
             Math.min(b / 0.7, 255);        
    }        
  }
}