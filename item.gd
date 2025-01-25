@tool

extends Resource

class_name Item

@export var name: String
@export var description: String
@export var icon: Texture
@export var is_stackable: bool = false
@export var max_stack: int = 1
