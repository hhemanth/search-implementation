require 'rspec'
require 'composite_tokenizer'

RSpec.describe CompositeTokenizer do
  context '#ArrayTokenizer' do
    it 'returns an array of terms when passed an array' do
      arr = [
          "Puerto-Rico",
          "Idaho",
          "Oklahoma",
          "Louisiana"
      ]
      tokenizer = CompositeTokenizer.new(arr)
      expect(tokenizer.tokens).to match_array(['idaho', 'oklahoma', 'louisiana', 'puerto-rico'])

    end
  end

  context 'TextTokenizer' do
    it 'uses TextTokenizer for text' do
      tokenizer = CompositeTokenizer.new("A Drama in St. Pierre and Miquelon")
      expect(tokenizer.tokens).to match_array([ "drama", "pierre", "miquelon"])
    end
  end

end