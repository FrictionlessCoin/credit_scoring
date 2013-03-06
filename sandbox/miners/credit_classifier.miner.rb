require "ajaila/miners"
require "credit_classifier.helper"

training_results = TrainingResults.all(:order => :id.asc, :real => 1.0)

sample = training_results.map do |el|
  # next if el.real == -1.0
  # estim = el.estim
  # real = el.real
  # id = el.id
  el.estim
end

normalized_sample = Ajaila.normalize(sample)

sub_result = {}
training_results.each_index do |ind|
  sub_result[normalized_sample[ind]] = training_results[ind].id
end 

final_output = []
sub_result.keys.sort.first(90).each do |key|
  final_output << sub_result[key] + 1
end

puts "FINAL RESULTS:"
puts "#{final_output}"
