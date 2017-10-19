function dice_mechanics_fate(bonus){

  var _bonus = (parseInt(bonus) == 'NAN' ? 0 : parseInt(bonus));
  var _rolls = [0,0,0,0]
  var _fate  = [0,0,0,0]
  var _rollstotal = 0;

  for (var i = 0; i < _rolls.length; i++) {
    var roll = (chance.rpg('1d3', {sum: true}))-2;
    _rolls[i] = roll;
    _fate[i]  = get_fate_dice_result(roll);
    _rollstotal += roll;
  }

  var _rollsult = (_rollstotal+_bonus)
  var _rollmath;

  if(_bonus > 0){
    _rollmath =  _fate.join(' ') + ' + ' + _bonus + ' = ' + (_rollsult);
  }else{
    _rollmath =  _fate.join(' ')  + ' = ' + (_rollsult);
  }

  var _rollmsg = fate_ladder(_rollsult);

  $("#rollmsg").html(_rollmsg);
  $("#rollsults").html(_rollsult);
  $("#rollmath").html(_rollmath);
}

function get_fate_dice_result(roll){
  var _val
  switch (roll) {
    case -1: _val = '<i class="fa fa-minus-square"></i>'; break;
    case 0:  _val = '<i class="fa fa-square"></i>'; break;
    case 1:  _val = '<i class="fa fa-plus-square"></i>'; break;
  }
  return _val;
}

function fate_ladder(result){
  var _val;
  switch (result) {
    case 8:  _val = 'Legendary!'; break;
    case 7:  _val = 'Epic!'; break;
    case 6:  _val = 'Fantastic!'; break;
    case 5:  _val = 'Superb!'; break;
    case 4:  _val = 'Great!'; break;
    case 3:  _val = 'Good!'; break;
    case 2:  _val = 'Fair!'; break;
    case 1:  _val = 'Average!'; break;
    case 0:  _val = 'Mediocre!'; break;
    case -1: _val = 'Poor!'; break;
    case -2: _val = 'Terrible!'; break;
    default: _val = ''; break;
  }
  return _val;
}
