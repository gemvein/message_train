json.id participant.id
json.model_name participant.class.name
json.slug box_participant_slug(participant)
json.name box_participant_name(participant)
json.path message_train.box_model_participant_path(@box, participant.class.table_name, participant.id)