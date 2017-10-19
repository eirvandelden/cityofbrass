function roller(dice, bonus){
  var die = dice.split("+");
  var rolls = [die.length];
  var rollstotal = 0;

  for (var i = 0; i < die.length; i++) {
    var roll = chance.rpg(die[i].trim(), {sum: true});
    rolls[i] = roll
    rollstotal += roll
  }

  var rollmath

  if(bonus > 0){
    rollmath = dice + ' (' + rolls.join('+') + ')' + '+' + bonus + ' = ' + (rollstotal+bonus);
  }else if(bonus < 0){
    rollmath = dice + ' (' + rolls.join('+') + ')' + ' ' + bonus + ' = ' + (rollstotal+bonus);
  }else{
    rollmath = dice + ' (' + rolls.join('+') + ')' + ' = ' + (rollstotal+bonus);
  }
  var rollsult = (rollstotal+bonus)

  $("#rollsults").html(rollsult);
  $("#rollmath").html(rollmath);
}
