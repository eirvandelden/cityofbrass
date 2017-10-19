function roll_them_bones(core_rules, dice, bonus){
  switch (dice) {
    case 'Fate': dice_mechanics_fate(bonus); break;
    case 'Roll Under': dice_mechanics_roll_under('1d20', bonus); break;
    case 'Standard': dice_mechanics_standard('1d20', bonus); break;
    default: dice_mechanics_standard(dice, bonus); break;
  }
}

function roll_them_bones2(dice, bonus){
  switch (dice.toLowerCase()) {
    case 'fate': dice_mechanics_fate(bonus); break;
    case 'roll under': dice_mechanics_roll_under('1d20', bonus); break;
    case 'standard': dice_mechanics_standard('1d20', bonus); break;
    default: dice_mechanics_standard(dice, bonus); break;
  }
}
