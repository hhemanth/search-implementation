require 'rspec'
require 'attribute_index'

RSpec.describe AttributeIndex do
  let(:attribute_index) { AttributeIndex.new(index_name, attribute_name)}
  let(:index_name) { 'Organisation' }
  let(:attribute_name) { 'name' }

  context "#index_name" do
    it 'returns index_name' do
      expect(attribute_index.index_name).to eq(index_name)
    end
  end

  context "#attribute_name" do
    it 'returns attribute_name' do
      expect(attribute_index.attribute_name).to eq(attribute_name)
    end
  end

  context '#index & #search, #attr_values' do
    before do
      attribute_index.index!("Bob", 1)
      attribute_index.index!("Dan", 2)
      attribute_index.index!("Hemanth", 1)
    end
    it 'searches for attributes' do
      expect(attribute_index.search('bob')).to eq([1])
      expect(attribute_index.search('Bob')).to eq([1])
      expect(attribute_index.search('Bbb')).to eq([])
      expect(attribute_index.search('Dan')).to eq([2])
    end

    it 'returns attr_values' do
      expect(attribute_index.attr_values).to match_array(['bob', 'dan', 'hemanth'])
    end
  end

end