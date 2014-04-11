module Insectdb

  SEEDS_ROOT = File.join(Insectdb::Application.root, 'db/seed_data/')
  ANN_ROOT   = File.join(SEEDS_ROOT,                 'annotation/')

  SEEDS = {
    :seqs             => SEEDS_ROOT + 'sequences',
    :gain             => ANN_ROOT   + 'segment_gain',
    :incl             => ANN_ROOT   + 'incl_changes_for_segments',
    :segments         => ANN_ROOT   + 'segment',
    :mrnas            => ANN_ROOT   + 'mrna',
    :genes            => ANN_ROOT   + 'gene',
    :genes_mrnas      => ANN_ROOT   + 'genes_mrnas',
    :mrnas_segments   => ANN_ROOT   + 'mrnas_segments'
  }
end
