package vo
{
	//http://www.xspf.org/xspf-v1.html#rfc.section.4.1.1.2
	//the above link is all the documentation on xspf, this loosely follows the spec
	//alphabetical vars
	[Bindable]
	public class TrackVO
	{
		public var album:String;
		public var artist:String; //not in xspf spec
		public var annotation:String;
		public var creator:String;
		public var image:String;
		public var info:String;
		public var link:String;
		public var location:String;
		public var timeEnd:Number = 0;
		public var timeStart:Number = 0;
		public var title:String;
		public var trackNum:String;
		
		public function TrackVO(album:String,
								annotation:String, 
								artist:String,
								creator:String, 
								image:String, 
								info:String, 
								link:String, 
								location:String,
								timeEnd:Number,
								timeStart:Number,
								title:String, 
								trackNum:String
								)
		{
			this.album = album;
			this.annotation = annotation;
			this.artist = artist;
			this.creator = creator;
			this.image = image;
			this.info = info;
			this.link = link;
			this.location = location;
			this.timeEnd = timeEnd;
			this.timeStart = timeStart;
			this.title = title;
			this.trackNum = trackNum;
		}
	}
}