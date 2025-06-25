def get_file_paths(mo, type, file)
  mo.children.each do |child|
    if child.type == type
      file.puts("#{child.id} - #{child.path}")
    elsif child.type == 'Model Group'
      get_file_paths(child, type, file)
    end
  end
end

# Select database from current path
directory = File.dirname(__FILE__)
db_file="#{directory}\\database\\Standalone.icmm"

db = WSApplication.open db_file,false
mo = db.model_object_from_type_and_id('Model Group', 1)

# Rainfalls
file_name = "gui_app\\rainfalls.txt"

if !File.exist?(file_name)
  file = File.new(file_name, 'a')
  get_file_paths(mo, 'Rainfall Event', file)
  file.close
end

# Networks
file_name = "gui_app\\networks.txt"
if !File.exist?(file_name)
  file = File.new(file_name, 'a')
  get_file_paths(mo, 'Model Network', file)
  file.close
end


