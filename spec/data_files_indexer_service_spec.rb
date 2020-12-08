require 'rspec'
require 'active_support/core_ext/hash/indifferent_access'
require 'data_files_indexer_service'

RSpec.describe DataFilesIndexerService do
  let(:data_files_indexer_service) {DataFilesIndexerService.new(options)}
  context '#search_service_hash' do
    let(:options) {[
        {
            index_name: 'User',
            data_file: 'data/users.json',
            config_file: 'data/user_search_config.json'
        },
        {
            index_name: 'Organization',
            data_file: 'data/organizations.json',
            config_file: 'data/organization_search_config.json'
        },
        {
            index_name: 'Ticket',
            data_file: 'data/tickets.json',
            config_file: 'data/ticket_search_config.json'
        }

    ]}
    it 'indexes multiple data file' do
      search_hash = data_files_indexer_service.search_service_hash.with_indifferent_access
      expect(search_hash.keys).to match_array(['User', 'Organization', 'Ticket'])
      expect(search_hash['User']['data_file']).to include("users.json")
      expect(search_hash['User']['config_file']).to include("user_search_config.json")
    end
  end
  context 'Operations after Indexing' do
    let(:options) {[
        {
            index_name: 'User',
            data_file: 'spec/fixtures/users.json',
            config_file: 'spec/fixtures/user_search_config.json'
        }
    ]}

    before do
      data_files_indexer_service.index_data_files!
    end

    context '#indexes' do
      it 'return all the indexes' do
        expect(data_files_indexer_service.indices).to match_array(['User'])
      end
    end
    context '#attributes' do
      it 'returns all the attributes, for a given index' do
        expect(data_files_indexer_service.attributes('User')).to match_array(["_id", "url", "external_id", "name", "alias", "created_at", "active", "verified", "shared", "locale", "timezone", "last_login_at", "email", "phone", "signature", "organization_id", "tags", "suspended", "role"])
      end
    end

    context '#attribute_values' do
      it 'returns all attribute values, for a given attribute & index' do
        attr_values = data_files_indexer_service.attribute_values('User', 'email')
        expect(attr_values).to match_array(['coffeyrasmussen@flotonic.com', 'jonibarlow@flotonic.com'])
      end
    end

    context '#search' do
      it "searches for terms" do
        search_results = data_files_indexer_service.search(index: 'User', attr: 'name', value: 'francisca')
        expect(search_results.first['_id']).to eq(1)
      end
    end
  end

end