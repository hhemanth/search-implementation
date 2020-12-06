require 'document_index'
require 'pry'
RSpec.describe DocumentIndex do
  let(:document_index) {DocumentIndex.new(index_name)}

  let(:index_name) {'User'}
  let(:document1) {
    {
        _id: 1,
        name: 'hemanth',
        age: '35',
        city: 'Sydney'
    }.stringify_keys
  }

  let(:document2) {
    {
        _id: 2,
        name: 'Bob',
        age: '21',
        city: 'Melbourne'
    }.stringify_keys
  }
  before do
    document_index.index!([document1, document2])
  end


  context '#index_name' do
    it 'should return index_name' do
      expect(document_index.index_name).to eq('User')
    end
  end

  context '#attributes' do
    it 'should return attributes of documents indexed' do
      expect(document_index.attributes).to eq(['_id', 'name', 'age', 'city'])
    end
  end

  context '#no_documents' do
    it 'should return no of documents' do
      expect(document_index.no_documents).to eq(2)
    end
  end

  context '#search' do
    context 'search for integer attributes' do
      it 'search for id' do
        expect(document_index.search(attr: '_id', val: 1)).to eq([document1])
      end
    end
  end
end

