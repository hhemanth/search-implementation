require 'rspec'
require 'active_support/core_ext/hash/indifferent_access'
require 'data_files_indexer_service'

RSpec.describe DataFilesIndexerService do
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
  context '#search_service_hash' do
    context 'A valid search servise hash provided' do
      context 'Index single file' do

      end
      context 'Hash is empty' do

      end

      context 'index multiple files' do
        it 'should return correct data_file and confix file' do
          search_config = data_files_indexer_service.search_config
          expect(search_config.indices).to match_array(%w[User Organization Ticket])
          expect(search_config.data_file("User")).to include('users.json')
          expect(search_config.config_file("User")).to include('user_search_config.json')
        end
      end
    end

    context 'An invalid Search Service hash is provided' do
      context 'Invalid Json file is provided' do

      end

      context 'Data file is not present' do

      end

      context 'Config file is not present' do

      end

      context 'reference config is not valid' do

      end

    end
  end
  context 'Operations after Indexing' do

    before do
      data_files_indexer_service.index_data_files!
    end

    context '#indexes' do
      it 'return all the indexes including global index' do
        expect(data_files_indexer_service.indices).to match_array(%w(User Organization Ticket))
      end
    end
    context '#attributes' do
      it 'returns all the attributes, for a given index including global' do
        expect(data_files_indexer_service.attributes('User')).to match_array(
                                                                   %w[_id url external_id name alias created_at
                     active verified shared locale timezone last_login_at
                     email phone signature organization_id tags suspended role User_all_attrs])
      end
    end

    context '#attribute_values' do
      it 'returns all attribute values, for a given attribute & index' do
        attr_values = data_files_indexer_service.attribute_values('User', 'email')
        expect(attr_values).to include('coffeyrasmussen@flotonic.com')
        expect(attr_values).to include('jonibarlow@flotonic.com')
      end
    end

    context '#search' do
      context 'search for single term in an attribute in a Index' do
        it 'should return all records with the given search term' do
          search_results = data_files_indexer_service.search(index: 'User', attr: 'name', term: 'francisca')
          expect(search_results.first['_id']).to eq(1)
        end
        it 'should return all records with given search criteria along with reference records' do
          search_results = data_files_indexer_service.search(index: 'User', attr: 'name', term: 'francisca')
          user = search_results.first
          expect(user["Organization"]["_id"]).to eq(user["organization_id"])
        end

        it 'should return all records with given search criteria along with reference records, for one to many references' do
          search_results = data_files_indexer_service.search(index: 'Organization', attr: 'name', term: 'Enthaze')
          org = search_results.first
          expect(org["users"].map{|o| o["organization_id"]}.uniq).to eq([org["_id"]])
        end



        it 'should return all records with given search criteria along with reference records' do
          search_results = data_files_indexer_service.search(index: 'Ticket', attr: '_id', term: '436bf9b0-1147-4c0a-8439-6f79833bff5b')
          ticket = search_results.first
          expect(ticket["Assignee"]["_id"]).to eq(ticket["assignee_id"])
          expect(ticket["Submitter"]["_id"]).to eq(ticket["submitter_id"])
        end

      end
      context 'search for multiple terms in an attribute in an Index' do
        it 'should return all records with any or all of the terms' do
          search_results = data_files_indexer_service.search(index: 'Ticket', attr: 'subject', term: 'Hungary morocco')
          expect(search_results.map { |s| s['_id'] }).to match_array(['87db32c5-76a3-4069-954c-7d59c6c21de0', '2217c7dc-7371-4401-8738-0a8a8aedc08d'])
        end
      end

      context 'search for empty string in an attribute in an Index ' do
        it 'should return all records with the attribute empty' do
          search_results = data_files_indexer_service.search(index: 'Ticket', attr: 'description', term: '')
          expect(search_results.map { |s| s['_id'] }).to match_array(["436bf9b0-1147-4c0a-8439-6f79833bff5b", "fc5a8a70-3814-4b17-a6e9-583936fca909"])
        end
      end

      context ' search for nil value in an attribute in an Index' do
        it 'should return all records with the attribute empty' do
          search_results = data_files_indexer_service.search(index: 'Ticket', attr: 'description', term: nil)
          expect(search_results.map { |s| s['_id'] }).to match_array(["436bf9b0-1147-4c0a-8439-6f79833bff5b", "fc5a8a70-3814-4b17-a6e9-583936fca909"])
        end
      end

      context 'search for single term in all attributes in a Index' do
        it 'should return all records with the given search term' do
          search_results = data_files_indexer_service.search(index: 'User', term: 'francisca')
          expect(search_results.first['_id']).to eq(1)
        end
      end
      context 'search for multiple terms in all attributes in an Index' do
        it 'should return all records with any or all of the terms' do
          search_results = data_files_indexer_service.search(index: 'Ticket', term: 'question Nicaragua')
          expect(search_results.count).to eq(51)
          expect(search_results.map { |s| s["type"] }.uniq).to match_array(["question", "task"])
          expect(search_results.map { |s| s["subject"] }.uniq).to include("A Nuisance in Nicaragua")
        end

        it 'should return all records with any or all of the terms' do
          search_results = data_files_indexer_service.search(index: 'Ticket', term: 'A Nuisance in Nicaragua')
          expect(search_results.count).to eq(49)
          expect(search_results.map { |s| s["subject"] }.uniq).to include("A Nuisance in Nicaragua")
        end

      end

      context 'search for empty string in all attributes in an Index ' do
        it 'should return all records with the attribute empty' do
          search_results = data_files_indexer_service.search(index: 'Ticket', term: "")
          expect(search_results.map { |s| s['_id'] }).to match_array(["436bf9b0-1147-4c0a-8439-6f79833bff5b", "1a227508-9f39-427c-8f57-1b72f3fab87c",
                                                                      "87db32c5-76a3-4069-954c-7d59c6c21de0", "fc5a8a70-3814-4b17-a6e9-583936fca909"])
        end
      end

      context ' search for nil value in all attributes in an Index' do
        it 'should return all records with the attribute empty' do
          search_results = data_files_indexer_service.search(index: 'Ticket', term: nil)
          expect(search_results.map { |s| s['_id'] }).to match_array(["436bf9b0-1147-4c0a-8439-6f79833bff5b", "1a227508-9f39-427c-8f57-1b72f3fab87c",
                                                                      "87db32c5-76a3-4069-954c-7d59c6c21de0", "fc5a8a70-3814-4b17-a6e9-583936fca909"])

        end
      end
    end

    context "#search_global" do
      context 'search for single term in all attributes in all Indices' do
        it 'should return all records with the given search term' do
          search_results = data_files_indexer_service.search_global(term: 'Nicaragua')
          expect(search_results).to be_a(Hash)
          expect(search_results.keys).to match_array(%w(Ticket Organization User))
          expect(search_results['User'].map { |s| s["_id"] }).to match_array([])
          expect(search_results['Organization'].map { |s| s["_id"] }).to match_array([])
          expect(search_results['Ticket'].map { |s| s["_id"] }).to match_array(["4e85e18c-797a-4d28-8e92-750447d3b4f5"])
        end
      end
      context 'search for multiple terms in all attributes in all Indices' do
        it 'should return all records with any or all of the terms' do
          search_results = data_files_indexer_service.search_global(term: 'A Nuisance in Nicaragua')
          expect(search_results).to be_a(Hash)
          expect(search_results.keys).to match_array(%w(Ticket Organization User))
          expect(search_results['User'].map { |s| s["_id"] }).to match_array([])
          expect(search_results['Organization'].map { |s| s["_id"] }).to match_array([])
          expect(search_results['Ticket'].count).to eq(49)
          expect(search_results['Ticket'].map { |s| s["subject"] }.uniq).to include("A Nuisance in Nicaragua")
        end
      end

      context 'search for empty string in all attributes in all Indices ' do
        it 'should return all records with the attribute empty' do
          search_results = data_files_indexer_service.search_global(term: '')
          expect(search_results).to be_a(Hash)
          expect(search_results.keys).to match_array(%w(Ticket Organization User))
          expect(search_results['User'].map { |s| s["_id"] }).to match_array([])
          expect(search_results['Organization'].map { |s| s["_id"] }).to match_array([])
          expect(search_results['Ticket'].map { |s| s["_id"] }).to match_array(["1a227508-9f39-427c-8f57-1b72f3fab87c", "436bf9b0-1147-4c0a-8439-6f79833bff5b", "87db32c5-76a3-4069-954c-7d59c6c21de0", "fc5a8a70-3814-4b17-a6e9-583936fca909"])
        end
      end

      context ' search for nil value in all attributes in all Indices' do
        it 'should return all records with the attribute empty' do
          search_results = data_files_indexer_service.search_global(term: nil)
          expect(search_results).to be_a(Hash)
          expect(search_results.keys).to match_array(%w(Ticket Organization User))
          expect(search_results['User'].map { |s| s["_id"] }).to match_array([])
          expect(search_results['Organization'].map { |s| s["_id"] }).to match_array([])
          expect(search_results['Ticket'].map { |s| s["_id"] }).to match_array(["1a227508-9f39-427c-8f57-1b72f3fab87c", "436bf9b0-1147-4c0a-8439-6f79833bff5b", "87db32c5-76a3-4069-954c-7d59c6c21de0", "fc5a8a70-3814-4b17-a6e9-583936fca909"])

        end
      end
    end

  end
end
