require 'rspec/its'
require 'awesome_print'

# factor based
require_relative '../lib/factors/RandomVar'     # Class
require_relative '../lib/factors/Factor'        # Class
require_relative '../lib/factors/Factium'       # Module

# graph based
require_relative '../lib/graphs/Node'           # Class
require_relative '../lib/graphs/Graphium'       # Module
require_relative '../lib/graphs/InducedMarkov'  # Class
require_relative '../lib/graphs/CliqueTree'     # Class



RSpec.configure do |c|
  c.alias_example_to :expect_it
end

RSpec::Core::MemoizedHelpers.module_eval do
  alias to should
  alias to_not should_not
end


