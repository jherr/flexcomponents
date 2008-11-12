package com.jherrington
{
  public class Address
  {
    private var _first:String = '';
    public function set first( str:String ) : void { _first = str; }
    public function get first( ) : String { return _first; }

    private var _last:String = '';
    public function set last( str:String ) : void { _last = str; }
    public function get last( ) : String { return _last; }

    private var _email:String = '';
    public function set email( str:String ) : void { _email = str; }
    public function get email( ) : String { return _email; }

    public function Address( inFirst:String, inLast:String, inEmail:String )
    {
      first = inFirst;
      last = inLast;
      email = inEmail;
    }
  }
}