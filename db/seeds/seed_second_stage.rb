module SeedSecondStage
  def self.run
    ActiveRecord::Base
      .connection
      .execute("CREATE UNIQUE INDEX seqs_chromosome_position ON seqs(chromosome, position)")
  end
end
