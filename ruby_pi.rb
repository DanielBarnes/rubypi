# Require Bundler if we're packing up the executable. Otherwise no.
require 'bundler/setup' unless not defined?(Ocra)

require 'gtk3'

require_relative 'view/ruby_pi_main_menu.rb'

require_relative 'controllers/pi_configuration_controller.rb'
require_relative 'controllers/planet_controller.rb'
require_relative 'controllers/command_center_controller.rb'
require_relative 'controllers/customs_office_controller.rb'
require_relative 'controllers/storage_facility_controller.rb'
require_relative 'controllers/industrial_facility_controller.rb'

require_relative 'model/pi_configuration.rb'

require_relative 'model/product.rb'
require_relative 'model/schematic.rb'

class RubyPI < Gtk::Window
  
  VERSION = "0.0.11"
  
  attr_accessor :pi_configuration
  
  def initialize
	super(Gtk::Window::Type::TOPLEVEL)
	
	# Set up a default size.
	# After much fiddling around I've found these values to do well.
	self.set_default_size(1024, 475)
	
	# Make sure closing the window runs properly.
	self.signal_connect("delete_event") do
	  close_application
	end
	
	# Setup the models.
	# Load static products into memory.
	products = Product.all
	if (products.empty?)
	  Product.load_from_yaml
	end
	
	# Load static schematics into memory.
	schematics = Schematic.all
	if (schematics.empty?)
	  Schematic.load_from_yaml
	end
	
	# Create a blank PI Configuration with 6 planets. User can load a different one if they feel like it.
	@pi_configuration = PIConfiguration.new
	
	# Setup the view.
	@menu_bar = RubyPIMainMenu.new
	
	@box = Gtk::Box.new(:vertical)
	@box.pack_start(@menu_bar, :expand => false, :fill => false)
	
	self.add(@box)
	
	self.load_controller_for_model(@pi_configuration)
	
	return self
  end
  
  def menu_bar
	return @menu_bar
  end
  
  # Given a model object,
  # Selects a controller (or errors)
  # and connects its view to the box beneath the menu.
  def load_controller_for_model(model_object)
	if (@controller)
	  @controller.destroy
	end
	
	if (model_object.is_a?(PIConfiguration))
	  @controller = PIConfigurationController.new(model_object)
	  
	elsif (model_object.is_a?(Planet))
	  @controller = PlanetController.new(model_object)
	
	elsif (model_object.is_a?(CommandCenter))
	  @controller = CommandCenterController.new(model_object)
	  
	elsif (model_object.is_a?(CustomsOffice))
	  @controller = CustomsOfficeController.new(model_object)
	  
	elsif (model_object.is_a?(StorageFacility))
	  @controller = StorageFacilityController.new(model_object)
	  
	elsif (model_object.is_a?(BasicIndustrialFacility) or
	       model_object.is_a?(AdvancedIndustrialFacility) or
	       model_object.is_a?(HighTechIndustrialFacility))
	  
	  @controller = IndustrialFacilityController.new(model_object)
	  
	else
	  raise ArgumentError, "Unknown model object class #{model_object.class}."
	end
	
	@box.pack_start(@controller.view)
	
	self.show_all
  end
  
  def close_application
	Gtk.main_quit
	exit!
  end
end


# If the Ocra class isn't defined, then run the app.
# If it is defined, we're packaging it and we don't want to run the app.
if not defined?(Ocra)
  $ruby_pi_main_gtk_window = RubyPI.new
  
  # Start the main loop for event handling.
  Gtk.main
end
