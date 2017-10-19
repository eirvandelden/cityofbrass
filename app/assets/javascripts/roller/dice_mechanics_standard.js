function dice_mechanics_standard(dice, bonus){
  var _dicepool = dice.split("+");
  var _bonus = (isNaN(parseInt(bonus)) ? 0 : parseInt(bonus));
  var _rolls = [_dicepool.length];
  var _rollstotal = 0;

  for (var i = 0; i < _dicepool.length; i++) {
    var roll = chance.rpg(_dicepool[i].trim(), {sum: true});
    _rolls[i] = roll;
    _rollstotal += roll;
  }

  var _rollmath;
  var _rollmsg;

  if(_bonus > 0){
    _rollmath = dice_standard_math(_rolls) + ' + ' + _bonus + ' = ' + (_rollstotal+_bonus);
    _rollmsg  = _dicepool.join(' + ') + ' + ' + _bonus;
  }else if(bonus < 0){
    _rollmath = dice_standard_math(_rolls) + ' - ' + (_bonus*-1) + ' = ' + (_rollstotal+_bonus);
    _rollmsg  = _dicepool.join(' + ') + ' + ' + _bonus;
  }else{
    _rollmath = dice_standard_math(_rolls) + ' = ' + (_rollstotal);
    _rollmsg  = _dicepool.join(' + ');
  }

  var _rollsult = (_rollstotal+_bonus);

  $("#rollmsg").html('');
  $("#rollsults").html(_rollsult);
  $("#rollmath").html(_rollmath);
}

function dice_standard_math(_rolls){
  return '<span style="color: #9c9c9c;">[</span> ' + _rolls.join(' <span style="color: #9c9c9c;">]</span> + <span style="color: #9c9c9c;">[</span> ') + ' <span style="color: #9c9c9c;">]</span>';
}
