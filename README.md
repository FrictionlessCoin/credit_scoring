## [Determining the solidness of borrowers via creditscoring](http://www.stat.uni-muenchen.de/service/datenarchiv/kredit/kredit_e.html)
In credit business, banks are interested in information whether prospective consumers will pay back their credit or not. The aim of credit-scoring is to model or predict the probability that a consumer with certain covariates is to be considered as a potential risk. The dataset consists of 1000 consumer credits from a german bank. For each consumer the binary response variable "creditability" is available. In addition, 20 covariates that are assumed to influence creditability were recorded. 

## Implementation
I decided to implement my datamining project with Ajaila. Here is the description, how I did this.

### Preparing a project
I created a new project within a command like that:
```
ajaila new CreditScoring
```

### Importing Data
Then I placed [this dataset](http://www.stat.uni-muenchen.de/service/datenarchiv/kredit/kredit.asc) into `datasets/raw` directory and changed its format into `CSV`.

After this I generated table TrainingSet (`sandbox/tables/traingin_set.table.rb`):
```ruby
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
```

When the table was ready I created selector called TrainingSet and after little adjustments it looked like this:
```ruby
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
```

Most part of this code was generated automatically. To execute selector TrainingSet we run the following command:
```
ajaila run selector TrainingSet
```

The selection process was successfully completed. Now we can move to the next step of our workflow.

### Adding Binary Classifier

We have to identify bad credits, which have already been given. First of all, we'll build logistic regression within all the factors that we have. As a target label we have information about status of credit request. It may be `0` (the credit request is rejected) or `1` (the credit is given).

To do this we will add VW library as a vendor plugin. This library provides us with an opportunity to conduct binary classification on the top of logistic regression. This plugin is not attached to this repository (more than 40mb), but you can do it manually in a few minutes.

There is a good wrapper for VW, called `Bors`. We place this gem to our `Gemfile`:
```ruby
source "http://rubygems.org"
gem "bors"
```

Additionally we'll do a small hack, which allows to connect the VW lib stored as a vendor plugin:
```ruby
require "bors"
class Bors
  class CommandLine
    def to_s
      "#{ROOT}/vendor/vw/vowpalwabbit/vw --data #{examples} #{training_mode} #{cache_file} #{create_cache} #{passes} #{initial_regressor} #{bit_precision} #{quadratic} #{ngram} #{final_regressor} #{predictions} #{min_prediction} #{max_prediction} #{loss_function}".squeeze(' ')
    end
    def run!
      system to_s
    end
  end
end
```

Then we are ready to  install all dependencies within the following console command:
```
bundle install
```

### Training

To train classification algorithm we generate new miner called 'Scoring', which is located at `sandbox/miners`. Inside this miner we have the following code:

```ruby
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
```

This snippet reads all data from the dataset and sends proper input to the binary classifier. The output goes to the `training_set_predictions.csv`, which is further parsed within TrainingResults selector.

If we look inside TrainingResults selector, then we'll the following:
```ruby
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
```

Training results are further stored in the table `TrainingResults`:
```ruby
class TrainingResults
  include MongoMapper::Document
  key :estim, Float
  key :real, Float
  key :id, Integer
end
```

Let's go further!

### Important Comments

After we've conducted classification and used the same training set to predict values, we can conduct probabilistic interpretation of recieved values. The algorithm knew, which applicants got the credit and who failed. Thus, we have the information about those people who deserve credit most of all and who was just lucky.

### Let's see what we have
If we normalize the logistic output and sort this results, then we can observe the following picture:
# picture here

The credit is given by chance if the class dependency is too low. We can identify such sort of users, if we build a new plot with relative growth values:
# new picture here

If analyze these results, we'll observe that there are just about 90 lucky people. There credit history shows that they could all chances not to get any confirmation.

### Final result
If we index rows inside the input table and use this numbers as IDs of people. Then we can say that bad credit was given to people with an id from this array:
```ruby
[586, 1, 587, 589, 588, 595, 590, 596, 606, 604, 591, 609, 612, 597, 607, 614, 608, 613, 602, 598, 592, 615, 603, 599, 725, 610, 523, 616, 2, 525, 734, 527, 544, 722, 528, 535, 646, 624, 726, 618, 631, 622, 638, 731, 630, 723, 642, 546, 620, 636, 526, 634, 524, 633, 3, 623, 49, 626, 51, 617, 533, 625, 530, 50, 529, 735, 727, 660, 639, 730, 737, 534, 658, 728, 739, 650, 558, 571, 547, 536, 540, 663, 641, 661, 750, 712, 551, 649, 659, 621]
```