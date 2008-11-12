package
{
  import com.adobe.flex.extras.controls.springgraph.Item;
  import com.adobe.webapis.flickr.*;

  public class FlickrItemData extends Item
  {
    public var photo:Photo = null;
    
    public var text:String = null;
    
    public function FlickrItemData(id:String=null)
    {
      super(id);
    }
    
  }
}