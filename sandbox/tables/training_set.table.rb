class TrainingSet
  include MongoMapper::Document
  key :id, Integer
  key :kredit, Float
  key :laufkont, Float
  key :laufzeit, Float
  key :moral, Float
  key :verw, Float
  key :hoehe, Float
  key :sparkont, Float
  key :beszeit, Float
  key :rate, Float
  key :famges, Float
  key :buerge, Float
  key :wohnzeit, Float
  key :verm, Float
  key :alter, Float
  key :weitkred, Float
  key :wohn, Float
  key :bishkred, Float
  key :beruf, Float
  key :pers, Float
  key :telef, Float
  key :gastarb, Float
end