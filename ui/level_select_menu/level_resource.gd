class_name LevelResource
extends Resource


@export var index := 0
@export var name := "Level %02d" % index
@export_multiline var text := "This is the first level contract"
@export 	var image: Texture2D
@export_file("*.tscn") var scene_path : String 
