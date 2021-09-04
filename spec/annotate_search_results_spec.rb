require 'rspec'
require 'active_support/core_ext/hash/indifferent_access'
require 'data_files_indexer_service'

RSpec.describe AnnotateSearchResults do
  include ErrorMsg
  let(:data_files_indexer_service) { DataFilesIndexerService.new(options) }

  let(:options) {
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
  before do
    data_files_indexer_service.index_data_files!
  end

  context '#run' do
    let(:search_config) { data_files_indexer_service.search_config}
    let(:doc_indices_hash) { data_files_indexer_service.doc_indices_hash}
    let(:annotate_search_results) {AnnotateSearchResults.new(doc_indices_hash, search_config)}
    let(:result) {
      [{
        "_id": 1,
        "url": "http://initech.zendesk.com/api/v2/users/1.json",
        "external_id": "74341f74-9c79-49d5-9611-87ef9b6eb75f",
        "name": "Francisca Rasmussen",
        "alias": "Miss Coffey",
        "created_at": "2016-04-15T05:19:46 -10:00",
        "active": true,
        "verified": true,
        "shared": false,
        "locale": "en-AU",
        "timezone": "Sri Lanka",
        "last_login_at": "2013-08-04T01:03:27 -10:00",
        "email": "coffeyrasmussen@flotonic.com",
        "phone": "8335-422-718",
        "signature": "Don't Worry Be Happy!",
        "organization_id": 119,
        "tags": [
          "Springville",
          "Sutton",
          "Hartsville/Hartley",
          "Diaperville"
        ],
        "suspended": true,
        "role": "admin"
      }.with_indifferent_access]
    }
    let(:index) {'User'}
    it 'should return all records with given search criteria along with reference records' do
      annotate_search_results.run!(result, index: index)
      res = result.first
      expect(res["Organization"]["_id"]).to eq(res["organization_id"])
    end
  end

end
