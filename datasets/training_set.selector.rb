require "ajaila/selectors"
file = import "credit.csv"

TrainingSet.collection.remove
id = 0
CSV.foreach file do |row|
  kredit = row[0]
  kredit = -1.0 if kredit.to_f == 0.0
  laufkont = row[1]
  laufzeit = row[2]
  moral = row[3]
  verw = row[4]
  hoehe = row[5]
  sparkont = row[6]
  beszeit = row[7]
  rate = row[8]
  famges = row[9]
  buerge = row[10]
  wohnzeit = row[11]
  verm = row[12]
  alter = row[13]
  weitkred = row[14]
  wohn = row[15]
  bishkred = row[16]
  beruf = row[17]
  pers = row[18]
  telef = row[19]
  gastarb = row[20]
  TrainingSet.create(id: id, kredit: kredit, laufkont: laufkont, laufzeit: laufzeit, moral: moral, verw: verw, hoehe: hoehe, sparkont: sparkont, beszeit: beszeit, rate: rate, famges: famges, buerge: buerge, wohnzeit: wohnzeit, verm: verm, alter: alter, weitkred: weitkred, wohn: wohn, bishkred: bishkred, beruf: beruf, pers: pers, telef: telef, gastarb: gastarb)
  id += 1
end

TrainingSet.all.each do |dude|
  puts "kredit: #{dude.kredit}, verw: #{dude.verw}"
end
