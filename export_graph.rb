directory = File.dirname(__FILE__)
db_file="#{directory}\\database\\Standalone.icmm"
db=WSApplication.open db_file,false
output_folder = "#{directory}\\generated_data\\network_exports"

network_id = ARGV[2].to_i
puts "Network id: #{network_id}"

require './utils'
require 'json'

net = db.model_object_from_type_and_id('Model Network', network_id).open
node_file_name = File.join(output_folder, "#{network_id}_nodes.json")
link_file_name = File.join(output_folder, "#{network_id}_links.json")

# Get the collection of nodes (e.g., manholes or junctions)
node_collection = net.row_object_collection("hw_node")

# Get the collections of links (conduits, weirs, and pumps)
link_collection = net.row_object_collection("hw_conduit")
weir_collection = net.row_object_collection("hw_weir")
pump_collection = net.row_object_collection("hw_pump")
orifice_collection = net.row_object_collection("hw_orifice")
channel_collection = net.row_object_collection("hw_channel")

puts "Number of Conduits: #{link_collection.length}"
puts "Number of Weirs   : #{weir_collection.length}"
puts "Number of Pumps   : #{pump_collection.length}"
puts "Number of Orifices: #{orifice_collection.length}"
puts "Number of Channel : #{channel_collection.length}"
puts "Number of Nodes   : #{node_collection.length}"

nodes = collection_to_array(node_collection, "nodes")

# Convert each collection to array and combine them into a single links array
conduit_links = collection_to_array(link_collection, "conduit")
weir_links = collection_to_array(weir_collection, "weir")
pump_links = collection_to_array(pump_collection, "pump")
orifice_links = collection_to_array(orifice_collection, "orifice")
channel_links = collection_to_array(channel_collection, "channel")


# Combine all link types into a single array
links = conduit_links

# Only add non-empty collections to avoid errors
links.concat(weir_links) unless weir_links.empty?
links.concat(pump_links) unless pump_links.empty?
links.concat(orifice_links) unless orifice_links.empty?
links.concat(channel_links) unless channel_links.empty?
puts "===================== SUMMARY ====================="
puts "Nodes array length: #{nodes.length} ; Type: #{nodes.class}"
puts "Combined links array length: #{links.length} ; Type: #{links.class}"

# Save nodes to a JSON file
File.open(node_file_name, "w") do |f|
  f.write(nodes.to_json)
end

File.open(link_file_name, "w") do |f|
  f.write(links.to_json)
end

# Save individual link types for visualization
File.open(File.join(output_folder, "#{network_id}_conduits.json"), "w") do |f|
  f.write(conduit_links.to_json)
end

File.open(File.join(output_folder, "#{network_id}_weirs.json"), "w") do |f|
  f.write(weir_links.to_json)
end

File.open(File.join(output_folder, "#{network_id}_pumps.json"), "w") do |f|
  f.write(pump_links.to_json)
end

File.open(File.join(output_folder, "#{network_id}_orifices.json"), "w") do |f|
  f.write(orifice_links.to_json)
end

File.open(File.join(output_folder, "#{network_id}_channels.json"), "w") do |f|
  f.write(channel_links.to_json)
end

puts "File saved at: #{File.expand_path(node_file_name)}"
puts "File saved at: #{File.expand_path(link_file_name)}"