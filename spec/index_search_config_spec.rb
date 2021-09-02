require 'rspec'
require 'index_search_config'
require 'pry'
require 'active_support/core_ext/hash/indifferent_access'

RSpec.describe IndexSearchConfig do
  let(:index_search_config) { IndexSearchConfig.new(config) }
  let!(:index_name) { 'Organization'}
  let(:config) {
    [
      {
        index_name: 'User',
        data_file: 'spec/fixtures/dataset1/users.json',
        config_file: 'spec/fixtures/dataset1/user_search_config.json',

      },
      {
        index_name: 'Organization',
        data_file: 'spec/fixtures/dataset1/organizations.json',
        config_file: 'spec/fixtures/dataset1/organization_search_config.json'
      },
      {
        index_name: 'Ticket',
        data_file: 'spec/fixtures/dataset1/tickets.json',
        config_file: 'spec/fixtures/dataset1/ticket_search_config.json',
      }
    ]
  }
  context '#new' do
    context 'config is valid' do
      it 'creates a new object' do
        expect(index_search_config).to be_a(IndexSearchConfig)
      end
    end
    context 'config is not valid' do
      xit 'returns nil' do
        expect(index_search_config).to be_nil
      end
    end
  end

  context '#data_file' do
    it 'returns the data file for an index' do
      expect(index_search_config.data_file(index_name)).to include('spec/fixtures/dataset1/organizations.json')
    end
  end

  context '#config_file' do
    it 'returns the data file for an index' do
      expect(index_search_config.config_file(index_name)).to include('spec/fixtures/dataset1/organization_search_config.json')
    end
  end


  context '#schema_tokenize_list' do
    it 'returns schema' do
      expect(index_search_config.schema_tokenize_list(index_name)).to eq([
                                                                           "name",
                                                                           "domain_names",
                                                                           "details",
                                                                           "tags"
                                                                         ])
    end

  end

  context '#one_to_one_reference_config' do
    let!(:index_name) { 'Ticket'}
    it 'returns schema' do
      expect(index_search_config.one_to_one_reference_config(index_name)).to eq([
                                                                                  {
                                                                                    "reference_id"=>  "organization_id",
                                                                                    "reference_entity"=> "Organization"
                                                                                  },
                                                                                  {
                                                                                    "reference_id"=> "assignee_id",
                                                                                    "reference_entity"=> "User"
                                                                                  },
                                                                                  {
                                                                                    "reference_id"=> "submitter_id",
                                                                                    "reference_entity"=> "User"
                                                                                  }
                                                                                ])
    end

  end

  context '#one_to_many_reference_config' do
    it 'returns schema' do
      expect(index_search_config.one_to_many_reference_config(index_name)).to eq([{
                                                                                    "reference_id" => "organization_id",
                                                                                    "reference_entity" => "User",
                                                                                    "result_term" => "users"
                                                                                }])
    end

  end


  context '#valid?' do
  end

end