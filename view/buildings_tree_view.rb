require_relative 'icon_column.rb'
require_relative 'text_column.rb'
require_relative 'buildings_list_store.rb'

class BuildingsTreeView < Gtk::TreeView
  def initialize(planet_model)
	# Given a planet, create a list store of its buildings.
	@buildings_list_store = BuildingsListStore.new(planet_model)
	
	super(@buildings_list_store)
	
	# Create columns for the tree view.
	icon_column = IconColumn.new("Icon", 2)
	name_column = TextColumn.new("Name", 3)
	stored_column = TextColumn.new("Stored Products", 4)
	produces_column = TextColumn.new("Produces", 5)
	pg_used_column = TextColumn.new("PG Used", 6)
	cpu_used_column = TextColumn.new("CPU Used", 7)
	isk_cost_column = TextColumn.new("ISK Cost", 8)
	
	# Pack columns in tree view, left-to-right.
	self.append_column(icon_column)
	self.append_column(name_column)
	self.append_column(stored_column)
	self.append_column(produces_column)
	self.append_column(pg_used_column)
	self.append_column(cpu_used_column)
	self.append_column(isk_cost_column)
	
	# Signals
	# On double-click, remove the building.
	self.signal_connect("row-activated") do |tree_view, path, column|
	  delete_selected
	end
	
	# Tree View settings.
	self.reorderable = true
	
	return self
  end
  
  def clear_sort
	# Sort by the index column.
	@buildings_list_store.set_sort_column_id(0)
  end
  
  def edit_selected
	# Determine which row is selected.
	row = self.selection
	tree_iter = row.selected
	
	# Get the building instance from the model.
	building_instance = tree_iter.get_value(1)
	
	# Change the main widget to a BuildingViewWidget, passing in the selected building instance.
	$ruby_pi_main_gtk_window.change_main_widget(BuildingViewWidget.new(building_instance))
  end
  
  def delete_selected
	# Determine which row is selected.
	row = self.selection
	tree_iter = row.selected
	
	# Pass the selected row along to the model's delete_building method.
	@buildings_list_store.delete_building(tree_iter)
  end
  
  def planet_model=(new_planet_model)
	@buildings_list_store.planet_model = new_planet_model
  end
  
  def start_observing_model
	@buildings_list_store.start_observing_model
  end
  
  def stop_observing_model
	@buildings_list_store.stop_observing_model
  end
  
  def destroy
	self.children.each do |child|
	  child.destroy
	end
	
	# Clean up after our list store.
	@buildings_list_store.destroy
	
	super
  end
end