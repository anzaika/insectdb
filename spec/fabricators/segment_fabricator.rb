seq = Sequence.new(
  [[1,'A'], [2,'G'], [3,'T']]
)

Fabricator(:segment) do
  id { sequence(:id, 1) }
  _ref_seq seq
  chromosome 0
  start seq.start
  stop seq.stop
  type { sequence(:type) {|i| ['coding(const)', 'coding(alt)'][i%2]} }
end
