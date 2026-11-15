onClipEvent(load){
   _root.Localizer.Loc(this.text,"menuButton_resume");
   if((!_root._PiecesDropped || _root._GameOver) && !(_root._SavedLevel > 0))
   {
      this._alpha = 10;
      this.button.enabled = false;
   }
   this.myPress = function()
   {
      _root._SoundMask |= _root.SF.ButtonDown;
   };
   this.myRelease = function()
   {
      var _loc1_ = _root;
      _loc1_._SoundMask |= _loc1_.SF.ButtonUp;
      if(_loc1_._SavedLevel > 0 && (!_loc1_._PiecesDropped || _loc1_._GameOver))
      {
         _loc1_._InitialLevel = _loc1_._SavedLevel;
         _loc1_._ResumeScore = _loc1_._SavedScore;
         _loc1_.createEmptyMovieClip("_resumeFix",16000);
         _loc1_._resumeFix.onEnterFrame = function()
         {
            _root._Score = _root._ResumeScore;
            _root.Score.Score.text = Math.floor(_root._Score);
            this.removeMovieClip();
         };
      }
      _loc1_.gotoAndStop("Active");
   };
}
