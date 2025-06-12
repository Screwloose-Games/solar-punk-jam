class_name EnterAreaQuestStep 
extends QuestStep

@export var area_id : String
@export var start_time : int = 0
@export var end_time : int = 0

# QuestStepArea3D has an id String field.
# EnteredAreaQuestStep has an id String field.
# Must work when standing in area ahead of time
# Must work when entering the area within the time frameq
# Either neither or both start and end time must be configured or throws editor error
