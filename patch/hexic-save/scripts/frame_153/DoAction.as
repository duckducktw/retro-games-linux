var _save = SharedObject.getLocal("hexic_save");
_save.data.level = _root._Level;
_save.data.score = _root._Score;
_save.flush();
_root._LevelUp._Time = -1;
_root.LevelUp_Think(_root._LevelUp);
if(_root._GameType == _root.GT.Timed && (_root._Level == 0 || _root._Level == 3))
{
   _root.gotoAndStop("Level_" + (_root._Level + 1) + "_Timed");
}
else
{
   _root.gotoAndStop("Level_" + (_root._Level + 1));
}
