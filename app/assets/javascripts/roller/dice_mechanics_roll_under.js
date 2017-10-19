function dice_mechanics_roll_under(dice, bonus){
  var _dicepool = dice.split("+");
  var _bonus = (parseInt(bonus) == 'NAN' ? 0 : parseInt(bonus));
  var _rolls = [_dicepool.length];
  var _rollstotal = 0;

  for (var i = 0; i < _dicepool.length; i++) {
    var roll = chance.rpg(_dicepool[i].trim(), {sum: true});
    _rolls[i] = roll
    _rollstotal += roll
  }

  var _rollmath

  _rollmath = _dicepool + ' (' + _rolls.join('+') + ')' + ' = ' + (_rollstotal);

  var _rollsult = (_rollstotal)
  var _rollmsg = (_rollstotal < _bonus ? 'SUCCESS!' : 'FAIL!');

  $("#rollmsg").html('');
  $("#rollsults").html(_rollsult);
  $("#rollmath").html(_rollmsg);
}
