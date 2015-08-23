json.id participant.id
json.model_name participant.class.name
json.slug box_participant_slug(participant)
json.name box_participant_name(participant)
json.path message_train.box_participant_path(@box, participant.id)