def collection_to_array(collections, type)
  temp_list = []
  collections.each do |collection|
    if type == "nodes"
      temp_list << {
        :id => collection.node_id,  # Assuming 'node_id' is a valid attribute
        :x => collection.x,         # X-coordinate
        :y => collection.y,          # Y-coordinate
        :node_type => collection.node_type
        # Add more attributes as needed
      }
    else
      temp_list << {
        :asset_id => collection.asset_id,       # Assuming 'ID' is a valid attribute
        :us_node_id => collection.us_node_id,  # Start node ID
        :ds_node_id => collection.ds_node_id,  # End node ID
        :link_type => type
        # Add more attributes as needed
      }
    end
  end
  return temp_list
end

def check_collection_property(collections)
  # Get first conduit to examine structure
  sample_collection = collections[0]
  # puts sample_conduit.table_info.fields

  sample_collection.table_info.fields.each do |field|
    puts "Tables Name: #{field.name}"
  end
end

def get_field_names(network)
  on= network.open
  arr=on.field_names('hw_conduit')
    arr.each do |f|
    puts f
  end
end