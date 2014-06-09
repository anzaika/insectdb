require_relative '../../db/seed_stages/seed_third_stage'

class SeedThirdStageWorker
  @queue = :seed

  def self.perform(bin)
    SeedThirdStage::Seeder.new(bin).run
  end
end
