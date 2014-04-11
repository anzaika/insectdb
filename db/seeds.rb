require_relative 'seed_stages/seed_first_stage'
require_relative 'seed_stages/seed_second_stage'
require_relative 'seed_stages/seed_third_stage'
require_relative 'seed_stages/seed_fourth_stage'

SeedFirstStage.run
SeedSecondStage.run
SeedThirdStage.run
SeedFourthStage::Seeder.new.run

# Set ref_seq's

puts 'Initiate Segment.set_ref_seq'
Segment.set_ref_seq
puts '...complete'
puts 'Initiate Mrna.set_ref_seq'
Mrna.set_ref_seq
puts '...complete'
