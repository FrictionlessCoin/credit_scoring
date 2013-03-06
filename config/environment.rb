require "bors"
require "histogram/array"
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

#
# Global Constants:
# 
# Here you can specify global constants, which are available across 
# the application. 
#
# Example:
#  FOO = "something bad"
#  
# After initializing constant FOO - you have a chance to refer to this
# constant through miners, helpers, selectors and presenters.
#
# 
#
# Additional Libraries:
#
# If you want to extend your application with additional libraries (Gems), you
# can add gems here.
#  
# Example:
#   require "statsample"
#
# Don't forget to add gems to the Gemfile and run command `bundle install`.
# 