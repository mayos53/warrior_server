class Pattern < ActiveRecord::Base
	has_one :typepattern, :foreign_key => "patternType"
end
