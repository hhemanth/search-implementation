# require 'textoken'

class TextTokenizer
  attr_accessor :input_text
  def initialize(input_text)
    @input_text = input_text.to_s
  end

  def tokens
    return [''] if input_text.to_s.strip == ''
    input_text.strip.downcase.gsub(/[^a-z0-9\s]/i, ' ').split.select{|w| w.size > 3}
    # Textoken(input_text, more_than: 3).tokens
  end
end