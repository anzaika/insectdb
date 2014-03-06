require_relative 'seeds/seq_seed'
require_relative 'seeds/annotation_seed'

SeqSeed.for_each_chromosome
AnnotationSeed.new.start
