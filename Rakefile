require 'neography/tasks'
require './hcir.rb'

namespace :data do
  task :generate do
    generate_data
    #process_publications
  end
end

namespace :neo4j do
  task :create do
    create_graph
  end
end