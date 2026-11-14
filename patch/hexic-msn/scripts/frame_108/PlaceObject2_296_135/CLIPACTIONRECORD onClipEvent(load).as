onClipEvent(load){
   _root.Localizer.Loc(this.text,"confirmbutton_yes");
   this.myPress = function()
   {
      _root._SoundMask |= _root.SF.ButtonDown;
   };
   this.myRelease = function()
   {
      var _loc1_ = _root;
      _loc1_._SoundMask |= _loc1_.SF.ButtonUp;
      if(_loc1_._GameAbort)
      {
         _loc1_._EndGameHeader = "gameend_gameover";
         _loc1_._EndGameInfo = "gameendinfo_abort";
         _loc1_._SoundMask |= _loc1_.SF.GameOver;
         _loc1_._GameOver = true;
         _loc1_.gotoAndStop("Active");
      }
      else
      {
         _loc1_.gotoAndStop("Active");
      }
   };
}
