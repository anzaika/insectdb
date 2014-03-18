FactoryGirl.define do
  factory :mutation do
    pos 1
    alleles ['A','T']

    initialize_with{Mutation.new(pos: pos, alleles: alleles)}
  end
end
