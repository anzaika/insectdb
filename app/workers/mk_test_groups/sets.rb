module MkTestGroups::Sets

  def self.standard
    puts "# performing SegmentsAltConst\n"
    MkTestGroups::SegmentsAltConst.new.perform

    puts "# performing GenesAge\n"
    MkTestGroups::GenesAge.new.perform

    puts "# performing GenesExpression\n"
    MkTestGroups::GenesExpression.new.perform
  end

end
