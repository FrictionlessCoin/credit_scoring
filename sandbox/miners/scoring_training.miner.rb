require "ajaila/miners"
require "scoring.helper"

training_set_vw = "#{ROOT}/datasets/raw/training_set.vw"
File.open(training_set_vw, 'w') {|file| file.truncate(0) }
bors = Bors.new({:examples_file => training_set_vw})

TrainingSet.find_each(:order => :id.asc) do |el|
  features_hash = {
     "laufkont" => el.laufkont,
     "laufzeit" => el.laufzeit,
     "moral" => el.moral,
     "verw" => el.verw,
     "hoehe" => el.hoehe,
     "sparkont" => el.sparkont,
     "beszeit" => el.beszeit,
     "rate" => el.rate,
     "famges" => el.famges,
     "buerge" => el.buerge,
     "wohnzeit" => el.wohnzeit,
     "verm" => el.verm,
     "alter" => el.alter,
     "weitkred" => el.weitkred,
     "wohn" => el.wohn,
     "bishkred" => el.bishkred,
     "beruf" => el.beruf,
     "pers" => el.pers,
     "telef" => el.telef,
     "gastarb" => el.gastarb
    }
  bors.add_example({ :label => el.kredit, :features => [features_hash] })
end

bors.run!({
  :loss_function => "logistic",
  :predictions => "#{ROOT}/datasets/raw/training_set_predictions.csv", 
})

Ajaila.execute_selector("TrainingResults")