class_name IntelResource
extends Resource
## A physical intel pickup. Banking it pins a card to the Evidence Board.

enum Category { PERSONAL, FACTION, MEDICAL, CORPORATE }

@export var id: StringName
@export var title: String
@export_multiline var body: String
@export var category: Category = Category.PERSONAL
@export var thread_id: StringName
@export var zone: StringName
