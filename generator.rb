require 'Win32API'
require 'date'

SCENARIO = "Generator"

$uuid_create = Win32API.new('rpcrt4', 'UuidCreate', 'P', 'L')
def new_guid
  result = ' ' * 16
  $uuid_create.call(result)
  a, b, c, d, e, f, g, h = result.unpack('SSSSSSSS')
  sprintf('%04X%04X-%04X-%04X-%04X-%04X%04X%04X', a, b, c, d, e, f, g, h)
end

def validate_network(on)
  validation = on.validate(SCENARIO)
  errors = validation.error_count()
  return errors == 0
end

def create_metadata_file(guid, nid, rfid, rt, rv, wcv, iiv)
  filename = "generated_data\\simulation_results\\meta_#{guid}.dat"
  File.open(filename, 'w') do |file|
    file.puts("guid: #{guid}")
    file.puts("network_id: #{nid}")
    file.puts("rainfall_id: #{rfid}")
    file.puts("roughness_type: #{rt}")
    file.puts("roughness_value: #{rv}")
    file.puts("weir_coefficient: #{wcv}")
    file.puts("initial_infilatration: #{iiv}")
  end
end

def run_simulation(guid, mo, network, rainfall, scenario, params)
  run_name = guid
  directory = File.dirname(__FILE__)
  output_directory = "#{directory}\\generated_data\\simulation_results"

  on = network.open
  if !validate_network(on)
    puts "Network could not be validated with current values"
    return false
  end
  
  puts "Run Identification: #{run_name}"
  run = mo.new_run(run_name, network, nil, rainfall, scenario, params)
  sims = run.children
  sims.each do |sim|
    puts "Running Simulation..."
    sim.run
    puts "Run End Status: #{sim.status}"
    puts "Exporting Results..."
    sim.results_csv_export_ex(nil, [['Node',['depnod','flooddepth']]], output_directory)
    # sim.results_csv_export_ex(nil, [['Node',['flooddepth']]], output_directory)
  end
  return true
end

def set_roughness(type, network, value)
  if type == 'MANNINGS'
    rt = 'Mannings'
  else
    rt = type
  end
  on = network.open
  on.current_scenario=SCENARIO
  on.clear_selection
  on.transaction_begin

  on.row_objects('hw_conduit').each do |conduit|
    conduit.roughness_type = type
    conduit["top_roughness_#{rt}"] = value
    conduit["bottom_roughness_#{rt}"] = value
    conduit.write
  end

  on.transaction_commit
  validate_network(on)
  network.commit "changed #{type} roughness"
end

#TODO: Optimize Value changes?
def set_weir_coefficient(network, value)
  on = network.open
  on.current_scenario=SCENARIO
  on.clear_selection
  on.transaction_begin

  on.row_objects('hw_weir').each do |weir|
    if weir.discharge_coeff != value
      weir.discharge_coeff = value
      weir.write     
    end
  end

  on.transaction_commit
  validate_network(on)
  network.commit 'changed weir discharge coefficent'
end

def set_infiltration(network, value)
  on = network.open
  on.current_scenario=SCENARIO
  on.clear_selection
  on.transaction_begin

  on.row_objects('hw_runoff_surface').each do |ros|
    if ros.initial_infiltration != value
      ros.initial_infiltration = value
      ros.write
    end
  end

  on.transaction_commit
  validate_network(on)
  network.commit 'changed initial infiltration for runoff surface'
end

def add_scenario(network, name)
    on = network.open
    on.scenarios do |s|
      if name == s
        return
      end
    end
    on.add_scenario(name, 'Base', "Created for data generation")
end

# Select database from current path
directory = File.dirname(__FILE__)
db_file="#{directory}\\database\\Standalone.icmm"

db=WSApplication.open db_file,false
mo = db.root_model_objects()[0]

# Loading network and rainfall from arguments
network_id = ARGV[2].to_i
network = db.model_object_from_type_and_id('Model Network', network_id)

# Loading rainfall event from arguments
rainfall_id = ARGV[3].to_i
rainfall = db.model_object_from_type_and_id('Rainfall Event', rainfall_id)

add_scenario(network, SCENARIO)

# Loading roughness from arguments
TYPES = {
  'c' => "CW",
  'h' => "HW",
  'm' => "MANNING",
  'n' => "N"
}
r_type = TYPES[ARGV[4]]
r_value = ARGV[5].to_f

set_roughness(r_type, network, r_value)

# Loading weir and infiltration values from arguments
weir_coefficient = ARGV[6].to_f
infiltration = ARGV[7].to_f
set_weir_coefficient(network, weir_coefficient)
set_infiltration(network, infiltration)

# run parameters
run_params_hash=Hash.new
run_params_hash['ExitOnFailedInit']=true
run_params_hash['ResultsMultiplier']=5

guid = new_guid
created = run_simulation(guid, mo, network, rainfall, SCENARIO, run_params_hash)
if created
  create_metadata_file(guid, network_id, rainfall_id, r_type, r_value, weir_coefficient, infiltration)
end
