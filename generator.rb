# External libraries
require 'Win32API'
require 'date'

# Select database from this path
$db_name="Standalone.icmm"
$db_file=".\\database\\#{$db_name}"

db=WSApplication.open $db_file,false
mo=db.model_object 'MODG~Modelbestanden>MODG~Buien>MODG~Standaard buien'

network = db.model_object 'MODG~Modelbestanden>MODG~Driebergen_Rijsenburg>NNET~Rioolmodel'

standard_rainfall_events = db.model_object 'MODG~Modelbestanden>MODG~Buien>MODG~Standaard buien'
rainfalls = Array.new
standard_rainfall_events.children.each do |rfe|
    if rfe.type == 'Rainfall Event'
      rainfalls.push(rfe)
    end
end

# run parameters
run_params_hash=Hash.new
run_params_hash['ExitOnFailedInit']=true
run_params_hash['Duration']=2
run_params_hash['DurationUnit']='Hours'
run_params_hash['Level']='MODG~Modelbestanden>LEV~Levelfile'
run_params_hash['ResultsMultiplier']=300
run_params_hash['TimeStep']=1
run_params_hash['StorePRN']=true
run_params_hash['DontLogModeSwitches']=false
run_params_hash['DontLogRTCRuleChanges']=false

# Creates a new_guid string that can be used as a unique global identifier for the run
$uuid_create = Win32API.new('rpcrt4', 'UuidCreate', 'P', 'L')
def new_guid
  result = ' ' * 16
  $uuid_create.call(result)
  a, b, c, d, e, f, g, h = result.unpack('SSSSSSSS')
  sprintf('%04X%04X-%04X-%04X-%04X-%04X%04X%04X', a, b, c, d, e, f, g, h)
end

run_name = new_guid
run = mo.new_run(run_name, network, nil, rainfalls, 'test', run_params_hash)

sims = run.children
sims.each do |sim|
  puts "running sim"
  sim.run_ex '.',1
end