@tool
extends EditorScript

func _run():
	var selection := EditorInterface.get_selection()
	var nodes := selection.get_selected_nodes()
		
	if nodes.is_empty():
		push_error("No nodes selected.")
		return
		
	var svg_paths := []
	var min_x := INF
	var min_y := INF
	var max_x := -INF
	var max_y := -INF
	
	for node in nodes:
		if node is Polygon2D or node is CollisionPolygon2D:
			var points = node.polygon
			if points.size() < 3:
				continue
			
			var path := "M "
			for i in points.size():
				var p = node.to_global(points[i])
				min_x = min(min_x, p.x)
				min_y = min(min_y, p.y)
				max_x = max(max_x, p.x)
				max_y = max(max_y, p.y)
				
				path += "%f %f " % [p.x, p.y]
				if i == 0:
					path = "M %f %f " % [p.x, p.y]
				else:
					path += "L %f %f " % [p.x, p.y]
			
			path += "Z"
			svg_paths.append(path)
	
	if svg_paths.is_empty():
		push_error("No Polygon2D found in selection.")
		return
	
	var width = max_x - min_x
	var height = max_y - min_y
	
	var svg := """<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg
	width="%f" 
	height="%f"
	viewBox="%f %f %f %f"
	version="1.1"
	xmlns="http://www.w3.org/2000/svg"
	xmlns:svg="http://www.w3.org/2000/svg">
""" % [width, height, min_x, min_y, width, height]
	
	for path in svg_paths:
		svg += '<path d="%s" fill="#cccccc" stroke="#000000" stroke-width="2"/>\n' % path
	
	svg += "</svg>"
	
	var file_path = "res://assets/level_blockout.svg"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(svg)
	file.close()
	
	print("SVG exported to ", file_path)
