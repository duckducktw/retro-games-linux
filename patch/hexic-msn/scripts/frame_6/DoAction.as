function onEnterFrame()
{
   var _loc1_ = _root;
   if(_loc1_._SplashPlayed == null)
   {
      _loc1_._SessReady = false;
      _loc1_._SplashPlayed = new Date().getTime();
      _loc1_.InitSounds();
      _loc1_.Localizer.Loc(_loc1_.welcome_txt,"welcome_title");
   }
   var _loc2_ = new Date();
   var _loc3_ = _loc2_.getTime() - _loc1_._SplashPlayed;
   if(_loc3_ > _loc1_.UI.SplashTime && _loc1_.Localizer.Loaded && _loc1_.S_WinGame.getBytesLoaded() >= _loc1_.S_WinGame.getBytesTotal())
   {
      false;
      this.onEnterFrame = function()
      {
         this.onEnterFrame = null;
         _root._ReceivedSessionStart = true;
         _root.InitSession();
         _root.gotoAndStop("Menu");
      };
      _root.SessionUpdate();
   }
   false;
}
stop();
