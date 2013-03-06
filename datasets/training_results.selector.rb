require "ajaila/selectors"
file = import "training_set_predictions.csv"

TrainingResults.collection.remove

predictions = []
CSV.foreach file do |row|
  predictions << row[0].to_f
end

TrainingSet.find_each(:order => :id.asc) do |dude|
  p = predictions.shift
  puts "id: #{dude.id}, expected: #{p}, real: #{dude.kredit}"
  TrainingResults.create(id: dude.id, estim: p, real: dude.kredit)
end