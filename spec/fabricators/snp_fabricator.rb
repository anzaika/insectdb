Fabricator(:snp) do
  chromosome 0
  position { sequence(:position, 1) }
  sig_count 162
  alleles {{'C' => 150, 'T' => 12}}
end
