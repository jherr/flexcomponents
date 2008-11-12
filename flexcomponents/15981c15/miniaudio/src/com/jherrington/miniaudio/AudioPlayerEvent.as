package com.jherrington.miniaudio
{
  import flash.events.Event;
  import flash.media.SoundChannel;

  public class AudioPlayerEvent extends Event
  {
    public static const PLAY:String = "PLAY";

    public static const PAUSE:String = "PAUSE";

    public static const FINISHED:String = "FINISHED";

    public static const LOADED:String = "LOADED";
    
    public var channel:SoundChannel = null;
    
    public function AudioPlayerEvent(type:String, chan:SoundChannel = null, bubbles:Boolean=false, cancelable:Boolean=false)
    {
      super(type, bubbles, cancelable);
      channel = chan;
    }  
  }
}
