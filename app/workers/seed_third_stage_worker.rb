require_relative '../../db/seed_stages/seed_third_stage'

class SeedThirdStageWorker
  @queue = :seed

  def self.perform(chr, index, step)
    SeedThirdStage::Seeder.new(chr, index, step).run
  end
end
