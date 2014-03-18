require_relative 'seeds/seed_second_stage'
require_relative 'seeds/seed_third_stage'
require_relative 'seeds/seed_fourth_stage'

# SeqSeed.for_each_chromosome_raw
# AnnotationSeed.new.start


# Seed second stage
# SeedSecondStage.run
# SeedThirdStage::Seeder.new(chromosome: '2R').run
# SeedThirdStage::Seeder.new(chromosome: '2L').run
# SeedThirdStage::Seeder.new(chromosome: '3R').run
SeedFourthStage::Seeder.new.run
