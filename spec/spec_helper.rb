require 'rspec/its'
require 'awesome_print'

# factor based
require_relative '../lib/factors/RandomVar'     # Class
require_relative '../lib/factors/Factor'        # Class
require_relative '../lib/factors/FactorArray'   # Class

# graph based
require_relative '../lib/graphs/Node'           # Class
require_relative '../lib/graphs/Messenger'      # Module
require_relative '../lib/graphs/Graph'          # Module
require_relative '../lib/graphs/Tree'           # Module
require_relative '../lib/graphs/InducedMarkov'  # Class
require_relative '../lib/graphs/CliqueTree'     # Class



RSpec.configure do |c|
  c.alias_example_to :expect_it
end

RSpec::Core::MemoizedHelpers.module_eval do
  alias to should
  alias to_not should_not
end


