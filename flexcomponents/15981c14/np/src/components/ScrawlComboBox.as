package components
{
	import mx.controls.ComboBox;
	import mx.core.IFactory;
	import mx.core.ClassFactory;

	public class ScrawlComboBox extends ComboBox
	{
		private var _ddFactory:IFactory = new ClassFactory(ScrawlComboBoxDropdown);	

	    override public function get dropdownFactory():IFactory
	    {
	        return _ddFactory;
	    }		

	    override public function set dropdownFactory(factory:IFactory):void
	    {
	        _ddFactory = factory;
	    }
	}
}