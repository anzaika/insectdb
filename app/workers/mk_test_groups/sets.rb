module MkTestGroups::Sets

  def self.standard(method)
    puts "# performing SegmentsAltConst\n"
    MkTestGroups::SegmentsAltConst.new.perform(method)

    puts "# performing GenesAge\n"
    MkTestGroups::GenesAge.new.perform(method)

    puts "# performing GenesExpression\n"
    MkTestGroups::GenesExpression.new.perform(method)
  end

end
