/*
Copyright (c) 2007, Axel Jensen, Maikel Sibbald
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/*
	xspf MP3Player version 0.1
    
    xspf mp3 player.
    
    Created by Maikel Sibbald
	info@flexcoders.nl
	http://labs.flexcoders.nl
	
	&
	
	Axel Jensen
	axel@cfwebtools.com	
	http://axel.cfwebtools.com
	
	Free to use.... just give us some credit
*/

package vo{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.*;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.binding.utils.*;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	[Event(name="play", type="flash.events.Event")]
	[Event(name="pause", type="flash.events.Event")]
	[Event(name="configComplete", type="flash.events.Event")]
	[Event(name="onDelayViewChange", type="flash.events.Event")]
	[Event(name="onDelayError", type="flash.events.Event")]
	
	[Bindable]
	public class MP3Player extends UIComponent{
		
		public static const DEFAULT_PLAYLIST_URL:String = "http://www.killtheheart.com/playlist.xml";
		public static const DEFAULT_SONG_URL:String = "http://www.killtheheart.com/Music/Angels and Airwaves/We Don&apos;t Need to Whisper/08 - the gift.mp3";
		public static const DEFAULT_SONG_TITLE:String = "The Gift";
		public static const DEFAULT_WELCOME_MSG:String = "Flex XML Mp3 Player - by Axel Jensen & Maikal Sibbald";
		public static const LOADING_PLAYLIST_MSG:String = "Loading Playlist...";
		public static const EVENT_CONFIG_COMPLETE:String = "configComplete";
		public static const EVENT_TIME_START_PASSED:String = "timeStartPassed";
		public static const EVENT_TIME_END_PASSED:String = "timeEndPassed";
		
		public var timeStartSetter:ChangeWatcher;
		public var timeEndSetter:ChangeWatcher;
		public var _isTimeStartPassed:Boolean = false;
		public var _isTimeEndPassed:Boolean = false;
		public var length:Number;
		public var sLength:String				= "0.00";
		public var sPosition:String 			= "0.00";
		public var pMinutes:Number 				= 0;
		public var pSeconds:Number 				= 0;
		public var position:Number 				= 0;
		public var currentTrack:Number 			= -1;
		public var currentTrackVO:TrackVO;
		public var pausePosition:Number;
		public var loadXML:HTTPService;

		private var _url:String;
		
		/**
		 * Author: Axel Jensen
		 * Update: 10.13.07
		 * used for timeStart/timeEnd on trackVO it lets us determine wheter or not 
		 * to start playing the song, or if it has already started playing... (as 
		 * if someone might have paused it? or something along those lines)
		 * it is only true when songs are in transit of skipping to a new song
		 * it could also be true if someone pauses a song, and clicks next...
		 * the _isNewTrack var gets set on the play() function
		 **/
		private var _isNewTrack:Boolean = true; 
		private var _isShuffleMode:Boolean = true;
		private var _isPlaying:Boolean = false;
		private var _isPaused:Boolean = false;
		private var _isResumeSet:Boolean = false;
		private var _isMoveTrackEnabled:Boolean = true;
		private var _isLoading:Boolean;
		private var _startTime:Number;
		private var _volume:Number 	= 100;
		private var _dataProvider:ArrayCollection = new ArrayCollection();
		private var _soundInstancePosition:Number = 0;
		
		/*****************PLAYER CONFIG************/
		public var playlist_url:String = MP3Player.DEFAULT_PLAYLIST_URL;
		private var _autoPlay:Boolean = true;
		private var _repeat_playlist:Boolean = true;
		private var _podcast_mode:Boolean = false;
		private var _song_url:String;
		private var _song_title:String;
		
		
		/********************TIMERS***************/
		/*
			delayMoveTrackTimer is used to delay people from 
			requesting songs to fast
		*/
		private var delayMoveTrackTimer:Timer = new Timer(1200,1);
		
		/*
			delayViewChangeTimer is used to dispatch an event that 
			the view could be changed at this certain time after getTrackAt() 
			is accessed
		*/
		private var delayViewChangeTimer:Timer = new Timer(5000,1);
		
		/*
			delayErrorTimer is used to dispatch an event... sometimes when a song tries to download
			there is an unknown interuption depending on the network, or the specific song rip...
			this will dispatch an event and we can use it to change songs... 
		*/
		private var delayErrorTimer:Timer = new Timer(4000,1);
		
		/*
			Author: Axel Jensen
			Update: 10.13.07
			timeStartTimer is used to dispatch an event when the start time has passed on the currentTrackVO
		*/
		private var timeStartTimer:Timer = new Timer(1,0);
		
		/*
			Author: Axel Jensen
			Update: 10.13.07
			timeEndTimer is used to dispatch an event when the end time has passed on the currentTrackVO
		*/
		private var timeEndTimer:Timer = new Timer(1,0);
		
		
		
		private var soundInstance:Sound;
		private var soundChannelInstance:SoundChannel;
		private var urlRequest:URLRequest = new URLRequest();
		private var soundBytes:ByteArray;
		
		private static var mp3Player:MP3Player;
		public static function getInstance():MP3Player{
			if(mp3Player == null){
				mp3Player = new MP3Player();
			}
			return mp3Player;
		}
		public function MP3Player():void{
			this.explicitHeight = 100;
			this._isShuffleMode = true;
			this.isPaused = false;
			this._isPlaying = false;
			this._isResumeSet = false;
			this.soundInstance = new Sound();
			watchSetter(); //sets up bindings
			this.setupListeners();
			
			if( !this.hasEventListener( Event.ENTER_FRAME ) )
				this.addEventListener( Event.ENTER_FRAME, enterFrameHandler);
			
			
			
			//these listeners don't have top be reinvoked on ever new sound like the other ones are.
			//TIMER LISTENERS
			this.delayMoveTrackTimer.addEventListener("timer",delayMoveTrackStatus);
			this.delayViewChangeTimer.addEventListener("timer",delayViewChangeStatus);
			this.delayErrorTimer.addEventListener("timer",delayErrorStatus);
			this.timeStartTimer.addEventListener("timer",onTimeStartTimer);
			this.timeEndTimer.addEventListener("timer",onTimeEndTimer);
			
			this.dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE,onDataChangeHandler);
			
			//CONFIG LISTENERS
			this.addEventListener(MP3Player.EVENT_CONFIG_COMPLETE,onConfigComplete);
			this.addEventListener(MP3Player.EVENT_TIME_START_PASSED,onTimeStartPassed);
			this.addEventListener(MP3Player.EVENT_TIME_END_PASSED,onTimeEndPassed);
			
			//SETUP HTTP SERVICE
			this.loadXML = new HTTPService();
		}
		
		private function callForData():void{
			loadXML.url = this.playlist_url;
			loadXML.resultFormat = HTTPService.RESULT_FORMAT_E4X;
			
			if(this.podcast_mode)
				this.loadXML.addEventListener('result',onPodcastResult);
			else
				this.loadXML.addEventListener('result',onResult);
				
			this.loadXML.addEventListener('fault',onFault);
			loadXML.send();
		}
		
		// ==========  BindingUtils.bindSetter =================
		private function watchSetter():void{
			timeStartSetter = BindingUtils.bindSetter(timeStartListener, this, "_isTimeStartPassed", true);
			timeEndSetter = BindingUtils.bindSetter(timeEndListener, this, "_isTimeEndPassed", true);
		}
		
		private function unwatchSetter():void{
			if(timeStartSetter != null)timeStartSetter.unwatch();
			if(timeEndSetter != null)timeEndSetter.unwatch();
		}
		
		// Event listener when binding occurs. 
		public function timeStartListener(object:*):void {
			if( this._isTimeStartPassed ){
				//trace('timeStartListenerAndPassed');
				this.startTime = this.currentTrackVO.timeStart;
				this.play();
				this.timeStartTimer.stop();
			}
		}
		// Event listener when binding occurs. 
		public function timeEndListener(object:*):void {
			if( this._isTimeEndPassed ){
				if( this.currentTrackVO.timeEnd != 0 ){
					//trace('timeEndListenerAndPassed');
					this.pause();
					this.timeEndTimer.stop();
				}
			}
		}
		
		/*****************TIMER HANDLERS*************************/
		private function delayMoveTrackStatus(event:TimerEvent):void{
			//trace('delayMoveTrackStatus');
			this.isMoveTrackEnabled = true;
		}
		private function delayViewChangeStatus(event:TimerEvent):void{
			this.dispatchEvent(new Event("onDelayViewChange"));
		}
		private function delayErrorStatus(event:TimerEvent):void{
			if(soundChannelInstance != null){
				if( this.sPosition == this.sLength ){
					this.dispatchEvent(new Event("onDelayError"));
				}
			}
		}
		private function onTimeStartTimer(event:TimerEvent):void{
			if(soundChannelInstance != null){

				if( currentTrackVO == null || currentTrackVO.timeStart == 0 )
					return;
				
			  	if( this.length > currentTrackVO.timeStart )
			  	{
				  	if( !this._isTimeStartPassed && !this._isNewTrack)
				  	{
			  			this.dispatchEvent(new Event(MP3Player.EVENT_TIME_START_PASSED));
				  	}
			  	}
			}
		}
		private function onTimeEndTimer(event:TimerEvent):void{
			if(soundChannelInstance != null){

				if( currentTrackVO == null || currentTrackVO.timeEnd == 0 )
					return;
				
				//trace( this.position );
			  	if( this.position > currentTrackVO.timeEnd )
			  	{
			  		//_isTimeEndPassed changes in the enterFrameHandler
				  	if( !this._isTimeEndPassed && !this._isNewTrack ){
			  			this.dispatchEvent(new Event(MP3Player.EVENT_TIME_END_PASSED));
				  	}
			  	}
			}
		}
		
		/*****************TIMER HANDLERS*************************/
		public function newSound():void{
			//remove old listeners
			this.removeListeners();
			
			//create a new sound
			this.soundInstance = new Sound();
			
			//create new listeners
			this.setupListeners();
			
			this._isNewTrack = true;
			this._isTimeEndPassed = false;
			this._isTimeStartPassed = false;
			this.isMoveTrackEnabled = false;
		}
		
		public function get dataProvider():ArrayCollection{
			return this._dataProvider;
		}
		
		public function set dataProvider(val:ArrayCollection):void{
			this._dataProvider = val;
		}
		
		public function set url(value:String):void{
			this._url = value;
			this.urlRequest.url = this._url;
			this.soundInstance.load(this.urlRequest);
			//trace('set url :' + _url);
		}

		public function get url():String{
			//trace('get url :' + _url);
			return _url;
		}
		
		public function set autoPlay(value:Boolean):void{
			this._autoPlay = value;
		}
		public function get autoPlay():Boolean{
			return this._autoPlay;
		}
		
		public function set podcast_mode(value:Boolean):void{
			this._podcast_mode = value;
		}
		public function get podcast_mode():Boolean{
			return this._podcast_mode;
		}
		
		public function set repeat_playlist(value:Boolean):void{
			this._repeat_playlist = value;
		}
		public function get repeat_playlist():Boolean{
			return this._repeat_playlist;
		}
		
		public function set song_url(value:String):void{
			this._song_url = value;
		}
		public function get song_url():String{
			return this._song_url;
		}
		
		public function set song_title(value:String):void{
			this._song_title = value;
		}
		public function get song_title():String{
			return this._song_title;
		}
		
		public function get volume():Number{
			return _volume;
		}
		public function set volume(value:Number):void{
			this._volume = value;
		}
		
		public function get isPlaying():Boolean{
			return this._isPlaying;
		}
		
		public function get isPaused():Boolean{
			return this._isPaused;
		}
		public function set isPaused(value:Boolean):void{
			this._isPaused = value;
		}
		
		public function get startTime():Number{
			return this._startTime;
		}
		
		public function get isResumeSet():Boolean{
			return this._isResumeSet;
		}
		
		public function get isMoveTrackEnabled():Boolean{
			return this._isMoveTrackEnabled;
		}
		
		public function set isMoveTrackEnabled(value:Boolean):void{
			this._isMoveTrackEnabled = value;
		}
		
		public function set startTime(value:Number):void{
			this._startTime = value;
		}
		public function get isBuffering():Boolean{
			return soundInstance.isBuffering;
		}
		public function get soundLength():Number{
			return soundInstance.length;
		}
		public function set isShuffleMode(value:Boolean):void{
			this._isShuffleMode = value;
		}
		public function get isShuffleMode():Boolean{
			return this._isShuffleMode;
		}
		
		
		public function getConfig(parameters:Object):void{
			
			var song_title:String = parameters.song_title;
			if( song_title == '')
				mp3Player.song_title = MP3Player.DEFAULT_SONG_TITLE;
			else
				mp3Player.song_title = song_title;
			
			//trace(ObjectUtil.toString(parameters));
			var playlist_url:String = parameters.playlist_url;
			var song_url:String = parameters.song_url;
			if( !playlist_url ){
				
				if( !song_url )
					mp3Player.playlist_url = MP3Player.DEFAULT_PLAYLIST_URL;
				else
					mp3Player.song_url = song_url;
			}
			else
				mp3Player.playlist_url = playlist_url;
				
				
			var podcast_mode:String = parameters.podcast_mode;
			if( podcast_mode != null)podcast_mode = podcast_mode.toLowerCase();
			if( podcast_mode == '0' || podcast_mode == 'false' )
				mp3Player.podcast_mode = false;
			else if( podcast_mode == null )
				mp3Player.podcast_mode = false;
			else
				mp3Player.podcast_mode = Boolean(podcast_mode);
				
				
			var repeat_playlist:Boolean = parameters.repeat_playlist;
			if( repeat_playlist )
				mp3Player.repeat_playlist = true;
			else
				mp3Player.repeat_playlist = false;
			
			//trace(mx.utils.ObjectUtil.toString(parameters));
			var autoPlay:String = parameters.autoPlay;
			
			if( autoPlay != null)autoPlay = autoPlay.toLowerCase();
			if( autoPlay == '0' || autoPlay == 'false' )
				mp3Player.autoPlay = false;
			else if( autoPlay == null )
				mp3Player.autoPlay = true;
			else
				mp3Player.autoPlay = Boolean(autoPlay);
				
				
			this.dispatchEvent(new Event(MP3Player.EVENT_CONFIG_COMPLETE));
			
		}
		public function get isLoading():Boolean{
			if(this.soundInstance != null){
				if(this.soundInstance.bytesLoaded < this.soundInstance.bytesTotal){
					_isLoading = true;
				}else{
					_isLoading = false;
				}
			}
			return _isLoading;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			if(this._autoPlay && !this._isPlaying){
				this.play();
			}
		}
		/******************************************CONTROLS***********************************************/
		private function setupListeners():void{
			this.soundInstance.addEventListener(Event.COMPLETE, completeHandler);
			this.soundInstance.addEventListener(Event.OPEN, openHandler);
            this.soundInstance.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			this.soundInstance.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			
			/*
			if( !this.hasEventListener( Event.ENTER_FRAME ) )
				this.addEventListener( Event.ENTER_FRAME, enterFrameHandler);
			*/
		}
		private function removeListeners():void{
			this.soundInstance.removeEventListener(Event.COMPLETE, doNothing);
			this.soundInstance.removeEventListener(Event.OPEN, doNothing);
            this.soundInstance.removeEventListener(IOErrorEvent.IO_ERROR, doNothing);
			this.soundInstance.removeEventListener(ProgressEvent.PROGRESS, doNothing);
		}
		public function doNothing(event:Event):void{
			//used when removing event listeners
		}
		
		public function getInfo():void{
			var u:URLRequest = new URLRequest(this.currentTrackVO.info);
			navigateToURL(u,'_blank');
		}
		public function getLink():void{
			var u:URLRequest = new URLRequest(this.currentTrackVO.link);
			navigateToURL(u,'_blank');
		}
		
		public function play():void{
			if(dataProvider){
				
				if(!this._isPlaying || this.isPaused){
					if(this.currentTrack == -1)
					{
						this.getTrackAt(0);
					}					
					else
					{
						this._isNewTrack = false;
						this._isPlaying = true;
						this.isPaused = false;
						var trans:SoundTransform = new SoundTransform(1, 0);

						
						this.soundChannelInstance = this.soundInstance.play(startTime);
						var e:Event = new Event("play");
						this.dispatchEvent(e);
						//trace('[timeStart]'+this.currentTrackVO.timeStart+'[timeEnd]'+this.currentTrackVO.timeEnd);
						trans.volume = this._volume;
						this.soundChannelInstance.soundTransform.volume = this._volume;
						this.soundInstance.addEventListener(ProgressEvent.PROGRESS, progressHandler);
						this.soundInstance.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
						this.soundChannelInstance.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
						this.pausePosition = 0;
						
						
						//start our timeStart/timeEnd Timers
						this.timeStartTimer.start();
						this.timeEndTimer.start();
							
						if( !this._isTimeStartPassed && currentTrackVO.timeStart != 0)
							pause();							
						
							
					}//end current track == -1

				}//end now Playing iff
			}//end dataProvider if
		}
		
		public function pause(isResumeSet:Boolean=false):void{
			if(dataProvider){
				if(this._isPlaying){
					this.startTime = this.soundChannelInstance.position;
					this._isPlaying = false;
					this._isResumeSet = isResumeSet;
					this.isPaused = true;
					this.soundChannelInstance.stop();
					var e:Event = new Event("pause");
					this.dispatchEvent(e);
				}
			}
		}
		
		public function stop():void{
			if(this.soundInstance != null){
				if(this.isPlaying){
					if( this.isLoading )
						this.soundInstance.close();
						
					var e:Event = new Event("stop");
					this.dispatchEvent(e);
					//trace('[stop] '+this.soundInstance.bytesLoaded)
				}
			}
			
			if(dataProvider){
				if(this.isPlaying){
					this._isPlaying = false;
					this.soundChannelInstance.stop();
				}		
			}
		}
	
		public function getFirstTrack():void{
			getTrackAt(0);
		}
		public function getNextTrack():void{
			var i:int;
			
			//if at end don't do
			if(dataProvider){
				if( currentTrack < dataProvider.length-1 ){
					i = currentTrack + 1;					
					getTrackAt(i);
				}else{
					if(!this.repeat_playlist){
						return;
					}
					getFirstTrack();
				}
			}else{
				trace('please choose tracks first');
			}
		}
		public function getPreviousTrack():void{
			var i:int;
			//if at beggining don't do
			if(dataProvider){
				if(currentTrack > 0){
					i = currentTrack - 1;
					getTrackAt(i);
				}else{
					i = dataProvider.length - 1;
					getTrackAt(i);					
				}
			}
		}
		public function getLastTrack():void{
			
			var i:int;
			if(dataProvider){
				i = dataProvider.length - 1;
				getTrackAt(i);
			}else{
				trace('please choose tracks first');
			}
		}
		public function getTrackAt(i:int):void{
			if(this.isMoveTrackEnabled){
				//try catch catches errors that are thrown.
				this.timeStartTimer.stop();
				this.timeEndTimer.stop();
				
				try{
					if(dataProvider.length){
						if(this.isPlaying || this.isPaused)
							this.stop();
							
						this.newSound();
						
						this.delayMoveTrackTimer.start();
						this.sPosition = '0:00';
						this.position = 0;
						this.startTime = 0;
						
						this._isPlaying = false;
						currentTrack = i;
						currentTrackVO = TrackVO(dataProvider.getItemAt(i));
						var _url:String = currentTrackVO.location + '?' + (new Date()).getTime();
						this.url = _url;
						
						this.play();

						//start the delayViewChange Timer so we can change views if necessarry
						delayViewChangeTimer.start();
						
						var tempDisplayTrack:int = currentTrack + 1;
						
						//trace('currentTrack :' + currentTrack);
					}else{
						trace('please choose tracks first');
					}
				}catch (err:Error){
					trace(err);
					//work around for error
					if( this.isLoading )
						this.stop();
						
					this.getNextTrack();
					trace('There was an error, track was skipped, this is still in beta testing, features are being added, and bugs are being fixed, please be patient');
				}

			}//end if is MoveTrackEnabled...
		}
		
		public function clearList():void{
			stop();
			currentTrack = -1; 
			
			if( dataProvider != null )
				dataProvider.removeAll();
			else
				dataProvider = new ArrayCollection();
				
		}
		/******************************************HANDLERS***********************************************/
		private function enterFrameHandler(event:Event):void {
			  if(soundChannelInstance != null){
			  	
			  	if(isPaused || isPaused == 'undefined'){
			  		position = startTime;
			  	}else{
			  		position = soundChannelInstance.position;
			  		this._soundInstancePosition = position;
				  	//trace('[enter_frameInsideIf]'+soundChannelInstance.position);
			  	}
			  	
			  	if( this.sPosition == this.sLength 
			  			&& this._soundInstancePosition != 0 
			  			&& !this.isPaused 
			  			&& !this.delayErrorTimer.running)
			  		this.delayErrorTimer.start();
			  		
			  	//trace('[enterFrame this.length]' + this.length);
			  		
			  	//trace('[enter_frameOutsideIf]'+soundChannelInstance.position);
			  	pMinutes = Math.floor(position / 1000 / 60);
			  	pSeconds = Math.floor(position / 1000) % 60;
			  	sPosition = pMinutes+":"+(pSeconds < 10?"0"+pSeconds:pSeconds);
			  	if(this.soundChannelInstance != null){
					this.soundChannelInstance.soundTransform = new SoundTransform(this._volume/100);
				}
			  }
		}
		private function onDataChangeHandler(event:CollectionEvent):void{
			if( autoPlay )
				play();
		}
		private function completeHandler(event:Event):void {
			this.dispatchEvent(event);
        }
        
		private function openHandler(event:Event):void {
			this.dispatchEvent(event);
        }

		public function soundCompleteHandler(event:Event):void {
			this._isPlaying = false;
			this.startTime = 0;
			this.stop();
			if(dataProvider.length > 0){
				this.getNextTrack();
			}
		}
		
        private function ioErrorHandler(event:IOErrorEvent):void {
           try{
           	
           }catch(err:Error){
	           trace('in error : ' + err.message);
           }
           //this.dispatchEvent(event);
        }

        private function progressHandler(event:ProgressEvent):void {
        	if(this.soundInstance != null){
	        	this.length = this.soundInstance.length;
				var tempMinutes:Number = Math.floor(this.length  / 1000 / 60);
				var tempSeconds:Number = Math.floor(this.length  / 1000) % 60;
				
				this.sLength = tempMinutes+":"+(tempSeconds < 10?"0"+tempSeconds:tempSeconds);
				
         	}
         	this.dispatchEvent(event);
        }
        
        
        //happens when MP3Player.EVENT_TIME_START_PASSED is dispatched
        private function onTimeStartPassed(event:Event):void{
        	//trace('timeStartPassed');
	        this._isTimeStartPassed = true;
        }
        //happens when MP3Player.EVENT_TIME_END_PASSED is dispatched
        private function onTimeEndPassed(event:Event):void{
        	//trace('timeEndPassed');
       		this._isTimeEndPassed = true;
        }
        private function onConfigComplete(event:Event):void{
			
			
			if( !this.song_url )
				//load the xml file with the httpService
				this.callForData();
			else
				//load the song url
				loadSongURL();
		}
		
		private function onResult(event:ResultEvent):void{
			//this will bring the xml back as an object by default... for optimization this is not typical... but works just fine for us here.
			var x:XML = event.result as XML;
			
			var aTracks:Array = new Array();
			for each(var t:XML in event.result.trackList.track){
				var trackVO:TrackVO = new TrackVO(
												t.album,
												t.annotation,
												t.artist,
												t.creator,
												t.image,
												t.info,
												t.link,
												t.location,
												t.timeEnd,
												t.timeStart,
												t.title,
												t.trackNum
												);
				aTracks.push(trackVO);
			}
			
			this.dataProvider.source = aTracks;
		}
		
		private function onPodcastResult(event:ResultEvent):void{
			//this will bring the xml back as an object by default... for optimization this is not typical... but works just fine for us here.
			var x:XML = event.result as XML;
			var aTracks:Array = new Array();
			/*
			for each(var p:XML in event.result.channel.item){
				var tempDate:String = p.pubDate;
				tempDate = tempDate.substr(0,16);
				//trace(tempDate.substr(0,16));
				var enclosureVO:EnclosureVO = new EnclosureVO(p.enclosure.@url,p.enclosure.@length,p.title,tempDate);
				tempArray.push(enclosureVO);
			}
			*/
			var artist:String = event.result.channel.title; //ends up being the "artist" in the interface
			for each(var t:XML in event.result.channel.item){
				var trackVO:TrackVO = new TrackVO(
												t.album,
												t.annotation,
												artist,
												t.author,
												t.image,
												t.info,
												t.link,
												t.enclosure.@url,
												t.timeEnd,
												t.timeStart,
												t.title,
												t.trackNum
												);
				aTracks.push(trackVO);
			}
			
			this.dataProvider.source = aTracks;
		}
		
		private function onFault(event:FaultEvent):void{
			Alert.show(event.fault.faultString);
		}
		
		private function loadSongURL():void{
			var aTracks:Array = new Array();
			
			var trackVO:TrackVO = new TrackVO(
											'',
											'',
											'',
											'',
											'',
											'',
											'',
											this.song_url,
											0,
											0,
											this.song_title,
											''
											);
			aTracks.push(trackVO);
			
			this.dataProvider.source = aTracks;
											
		}
		
		

	}
}