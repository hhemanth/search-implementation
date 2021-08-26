
require 'rspec'
require 'text_tokenizer'

RSpec.describe TextTokenizer do
  context '#tokens' do
    it 'given long text, returns an array of tokens' do
      text_tokenizer = TextTokenizer.new("Aliquip excepteur fugiat ex minim ea aute eu labore.Sunt eiusmod esse eu non commodo est veniam consequat.")
      expect(text_tokenizer.tokens).to match_array(["aliquip", "excepteur", "fugiat", "minim", "aute", "labore", "sunt", "eiusmod", "esse", "commodo", "veniam", "consequat"])
    end
  end

  it 'given short text, returns an array of tokens' do
    text_tokenizer = TextTokenizer.new("A Drama in St. Pierre and Miquelon")
    expect(text_tokenizer.tokens).to match_array([ "drama", "pierre", "miquelon"])
  end

  it 'given empty string, return an array of empty string' do
    text_tokenizer = TextTokenizer.new("")
    expect(text_tokenizer.tokens).to match_array([""])
  end

  it 'given string of empty spaces, return an array of empty string' do
    text_tokenizer = TextTokenizer.new("   ")
    expect(text_tokenizer.tokens).to match_array([""])
  end
end
