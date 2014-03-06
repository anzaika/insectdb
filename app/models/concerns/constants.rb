module Constants
  extend ActiveSupport::Concern

  CHROMOSOMES = {'2R' => 0,
                 '2L' => 1,
                 '3R' => 2,
                 '3L' => 3,
                 'X'  => 4}

  SEEDS = {
    :segmentGain      => Insectdb::Application.root + 'data/segment_gain.csv',
    :segmentInclusion => Insectdb::Application.root + 'data/incl_changes_for_segments',
    :seqs             => Insectdb::Application.root + 'db/seed_data/seq',
    :segments         => Insectdb::Application.root + 'db/seed_data/annotation/segment',
    :mrnas            => Insectdb::Application.root + 'db/seed_data/annotation/mrna',
    :genes            => Insectdb::Application.root + 'db/seed_data/annotation/gene',
    :genes_mrnas      => Insectdb::Application.root + 'db/seed_data/annotation/genes_mrnas',
    :mrnas_segments   => Insectdb::Application.root + 'db/seed_data/annotation/mrnas_segments'
  }

end
