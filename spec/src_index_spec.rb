require 'rspec'
require 'src_index'
RSpec.describe SrcIndex do
  let(:src_index) { SrcIndex.new(index_name) }
  let(:index_name) {'Organization'}
  let(:document1) { {_id: 1, name: 'name1'}.stringify_keys }
  let(:document2) { {_id: 2, name: 'name2'}.stringify_keys }

  context "#index_name" do
    it "returns index_name"  do
      expect(src_index.index_name).to eq("Organization")
    end
  end

  context "#ids" do
    it "should return ids of all documents indexed" do
      src_index.index!([document1, document2])
      expect(src_index.ids).to eq([1,2])
    end
  end

  context "#documents" do
    it "returns documents, given ids" do
      src_index.index!([document1, document2])
      expect(src_index.documents([1,2])).to eq([document1, document2])
    end
  end
end