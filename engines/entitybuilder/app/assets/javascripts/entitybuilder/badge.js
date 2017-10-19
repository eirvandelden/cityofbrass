function eb_badge_whisper (badge_name) {
  ApCore.$emit('evt-privateMessage', badge_name);
}

function eb_add_entity (entity) {
  entity.initiative = 0;
  entity.stance = 0;
  ApCore.$emit('evt-addEntity', entity);
}
