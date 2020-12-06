require_relative './text_tokenizer'
require_relative './array_tokenizer'

class CompositeTokenizer
  attr_accessor :input_text

  def initialize(input_text)
    @input_text = input_text
  end

  def tokens
    if input_text.is_a?(Array)
      ArrayTokenizer.new(input_text).tokens
    elsif input_text.is_a?(Integer)
      [input_text] #dont tokenize
    else
      TextTokenizer.new(input_text.to_s).tokens
    end
  end
end