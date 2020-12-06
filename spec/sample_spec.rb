require 'rspec'
require 'sample'

RSpec.describe Sample do
  context "sample" do
    it "returns a name"  do
      expect(Sample.new.name).to eq("name")
    end

  end
end