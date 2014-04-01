require 'hirb'

class ResultFile
  def initialize(name)
    fname = name + "___" + Time.now.strftime('%s')
    path = File.join(Dir.pwd, 'results', fname)
    @f = File.open(path, 'w')
  end

  # Public: write string
  def wheader(hash)
    # @f << "## " + hash.map{|a| a.join(': ')}.join(", ") + "\n"
    @f.write('hellojs ')
  end

  def pupee
    @f.write("woopsie\n")
  end

  def wtable(array)
    @f << Hirb::Helpers::AutoTable.render(
            array,
            fields: [:pnn, :pn, :psn, :ps, :dnn, :dn, :dsn, :ds, :ns, :nn, :alpha, :divs, :snps]
          )
    @f << "\n"
  end

  def close
    @f.close
  end

end
