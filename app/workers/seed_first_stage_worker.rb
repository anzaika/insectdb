require_relative '../../db/seed_stages/seed_first_stage'

class SeedFirstStageWorker
  @queue = :seed

  def self.perform(chr, index, step)
    SeedFirstStage::Seeder.new(chr, index, step).run
  end
end
