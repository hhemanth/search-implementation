require 'rspec'
require 'array_tokenizer'

RSpec.describe ArrayTokenizer do
  context "#tokens" do
    context 'empty array' do
      it 'returns tokns for an array' do
        array_tokenizer = ArrayTokenizer.new([])
        expect(array_tokenizer.tokens).to match_array([''])
      end
    end

    context 'non empty array' do
      it 'returns tokns for an array' do
        array_tokenizer = ArrayTokenizer.new([
                                               "Puerto-Rico",
                                               "Idaho",
                                               "Oklahoma",
                                               "Louisiana"
                                             ])
        expect(array_tokenizer.tokens).to match_array(['idaho', 'oklahoma', 'louisiana', 'puerto-rico'])
      end
    end
  end
end