# Given a building model, can draw an image of it to a Cairo context.

class CairoBuildingImage
  
  PATH_TO_IMAGES_FOLDER = "view/images/64x64/"
  
  NAME_TO_FILENAME = { "Command Center" => "command_center_icon.png",
                       "Extractor" => "extractor_icon.png",
                       "Storage Facility" => "storage_facility_icon.png",
                       "Launchpad" => "launchpad_icon.png",
                       "Basic Industrial Facility" => "industrial_facility_two_materials.png",
                       "Advanced Industrial Facility" => "industrial_facility_two_materials.png",
                       "High Tech Industrial Facility" => "industrial_facility_three_materials.png",
                       "Customs Office" => "poco_icon.png"}
  
  attr_reader :image
  
  def initialize(building_model, width, height)
	raise ArgumentError unless building_model.is_a?(PlanetaryBuilding)
	
	@building_model = building_model
	filename = "#{PATH_TO_IMAGES_FOLDER}" + "#{NAME_TO_FILENAME[@building_model.name]}"
	
	raise "#{filename} not found." unless File.exists?(filename)
	
	# WORKAROUND:
	# So, I really wanted to use SVGs and scale them on the fly.
	# The RSVG library says to use RSVG::Handle.new_from_file(filename). However, the GC never releases it.
	# This causes crazy memory allocation issues.
	# So instead I resort to using pixbufs. Sigh.
	@image = Gdk::Pixbuf.new(filename, width, height)
	@width = width
	@height = height
  end
  
  def horizontal_scale
	# Take the requested width and divide it by the width of the image we're loading off the hard drive.
	return (@width / @image.width.to_f)
  end
  
  def vertical_scale
	# Take the requested height and divide it by the height of the image we're loading off the hard drive.
	return (@height / @image.height.to_f)
  end
  
  def top_left_x_coord
	# Take the center x position from the building_model and subtract half the width.
	return (@building_model.x_pos - (@width / 2))
  end
  
  def top_left_y_coord
	# Take the center y position from the building_model and subtract half the height.
	return (@building_model.y_pos - (@height / 2))
  end
  
  def draw(cairo_context)
	# Do all the painting in a transaction.
	cairo_context.save do
	  # Move to the x/y coordinate that starts the top left corner of the scaled image.
	  cairo_context.translate(self.top_left_x_coord, self.top_left_y_coord)
	  
	  # Scale the base image.
	  #cairo_context.scale(self.horizontal_scale, self.vertical_scale)
	  
	  # Paint the SVG to the target.
	  cairo_context.set_source_pixbuf(@image)
	  cairo_context.paint
	end
  end
end