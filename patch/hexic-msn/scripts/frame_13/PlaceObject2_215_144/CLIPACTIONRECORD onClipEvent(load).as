onClipEvent(load){
   _root.Localizer.Loc(this.text,"modeButton_normal");
   this.myPress = function()
   {
      _root._SoundMask |= _root.SF.ButtonDown;
   };
   this.myRelease = function()
   {
      var _loc1_ = _root;
      _loc1_._SoundMask |= _loc1_.SF.ButtonUp;
      _loc1_.PlaySounds();
      _loc1_._GameTypeCache = _loc1_.GT.Marathon;
      if(!_loc1_._PiecesDropped || _loc1_._GameOver)
      {
         _loc1_.gotoAndStop("Active");
      }
      else
      {
         _loc1_.gotoAndStop("Confirm");
      }
   };
}
