require_relative './text_tokenizer'
class ArrayTokenizer
  attr_accessor :input_array
  def initialize(input_arr)
    @input_array = input_arr
  end

  def tokens
    return [''] if input_array.empty?
    input_array.uniq.compact.map(&:downcase)
  end
end