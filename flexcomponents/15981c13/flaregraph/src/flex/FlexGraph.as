package flex
{
  import flare.animate.Sequence;
  import flare.animate.Transition;
  import flare.animate.Transitioner;
  import flare.util.Button;
  import flare.util.GraphUtil;
  import flare.vis.Visualization;
  import flare.vis.controls.DragControl;
  import flare.vis.data.Data;
  import flare.vis.data.NodeSprite;
  import flare.vis.operator.OperatorSwitch;
  import flare.vis.operator.layout.CircleLayout;
  import flare.vis.operator.layout.ForceDirectedLayout;
  import flare.vis.operator.layout.IndentedTreeLayout;
  import flare.vis.operator.layout.NodeLinkTreeLayout;
  import flare.vis.operator.layout.Orientation;
  import flare.vis.operator.layout.RadialTreeLayout;
  import flare.vis.util.graphics.Shapes;
  
  import flash.display.Sprite;
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import flash.geom.Rectangle;
  
  public class FlexGraph extends Sprite
  {
    private var vis:Visualization;
    private var os:OperatorSwitch;
    private var anchors:Array;
    private var shape:int = 0;
    
    public var WIDTH:Number = 800;
    public var HEIGHT:Number = 550;

    public function FlexGraph() {
      name = "FlexGraph";
      var w:Number = WIDTH;
      var h:Number = HEIGHT;
      
      var data:Data = GraphUtil.diamondTree(5,3,5);
      vis = new Visualization(data);
      vis.bounds = new Rectangle(0,0,w,h);
      
      os = new OperatorSwitch(
        new ForceDirectedLayout(),
        new NodeLinkTreeLayout(Orientation.LEFT_TO_RIGHT, 20, 5, 10),
        new IndentedTreeLayout(20),
        new RadialTreeLayout(50, false),
        new CircleLayout()
      );
      anchors = [
        null,
        new Point(40, h/2),
        new Point(40, 40),
        new Point(w/2, h/2),
        new Point(0, 0)
      ];
      os.index = 1;
      vis.marks.x = anchors[1].x;
      vis.marks.y = anchors[1].y;

      vis.operators.add(os);
      vis.tree.nodes.visit(function(n:NodeSprite):void {
        n.size = 1.5;
        n.fillColor = 0x666666; n.fillAlpha = 0.8;
        n.lineColor = 0x999999; n.lineAlpha = 0.9;
        n.lineWidth = 2;
        n.buttonMode = true;
      });
      vis.update();
      addChild(vis);
      
      vis.controls.add(new DragControl());
    }
    
    public function changeLayout( index:int ) : void {
      switchLayout( index ).play();
    }
    
    public function starbust() : void {
      toStarburst().play();
    }
    
    private function switchLayout(idx:int):Transition
    {
      vis.operators.clear();
      vis.operators.add(os);
      vis.continuousUpdates = false;
      vis.operators[0].index = idx;
      
      var seq:Sequence;
      if (shape != 0) {
        seq = new Sequence(
          vis.data.nodes.setProperties({scaleX:0, scaleY:0}, 0.5),
          vis.data.nodes.setProperties({shape:0, lineColor:0xffdddddd}, 0.5),
          vis.data.nodes.setProperties({scaleX:1, scaleY:1}, 0),
          vis.data.edges.setProperties({lineColor:0xffcccccc}, 0.5)
        );
      } else {
        seq = new Sequence();
      }
      
      shape = 0;
      if (idx > 0) {
        seq.onEnd = function():void {
          var t:Transitioner = new Transitioner(2);
          t.$(vis.marks).x = anchors[idx].x;
          t.$(vis.marks).y = anchors[idx].y;
          vis.update(t).play();
        };
      } else {
        seq.onEnd = function():void { vis.continuousUpdates = true; };
      }
      return seq;
    }
    
    private function toStarburst():Transition
    {
      vis.operators.clear();
      vis.operators.add(new RadialTreeLayout(50,false));
      var t0:Transitioner = new Transitioner(2);        

      t0.$(vis.marks).x = WIDTH/2;
      t0.$(vis.marks).y = HEIGHT/2;
      if (shape == Shapes.WEDGE) {
        return vis.update(t0);
      } else {
        shape = Shapes.WEDGE;
        return new Sequence(
          vis.update(t0),
          vis.data.edges.setProperties({lineColor:0}, 0.5),
          vis.data.nodes.setProperties({scaleX:0, scaleY:0}, 0.5),
          vis.data.nodes.setProperties({shape:Shapes.WEDGE, lineColor:0xffffffff}, 0),
          vis.data.nodes.setProperties({scaleX:1, scaleY:1}, 0.5)
        );
      }
    }
    
    public function play():void
    {
      var os:OperatorSwitch = vis.operators.getOperatorAt(0) as OperatorSwitch;
      if (os.index == 0)
        vis.continuousUpdates = true;
    }
    
    public function stop():void
    {
      vis.continuousUpdates = false;
    }   
  }
}