require_relative 'seed_stages/seed_first_stage'
require_relative 'seed_stages/seed_second_stage'
require_relative 'seed_stages/seed_third_stage'
require_relative 'seed_stages/seed_fourth_stage'

# SeqSeed.for_each_chromosome_raw
# AnnotationSeed.new.start


# Seed second stage
# SeedFirstStage::Seeder.new(chr: '3L').run
# SeedFirstStage::Seeder.new(chr: 'X').run
# SeedSecondStage.run
# SeedThirdStage::Seeder.new(chr: '2R').run
# SeedThirdStage::Seeder.new(chr: '2L').run
# SeedThirdStage::Seeder.new(chr: '3R').run
# SeedThirdStage::Seeder.new(chr: '3L').run
# SeedThirdStage::Seeder.new(chr: 'X').run
SeedFourthStage::Seeder.new.run
