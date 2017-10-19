class Performance
  @@current_symbols = []

  def self.current_symbols
    @@current_symbols
  end

  def self.new_symbols
    all_symbols = Symbol.all_symbols
    result = all_symbols - @@current_symbols
    @@current_symbols = all_symbols
    result
  end
end
