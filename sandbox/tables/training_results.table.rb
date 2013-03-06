class TrainingResults
  include MongoMapper::Document
  key :estim, Float
  key :real, Float
  key :id, Integer
end