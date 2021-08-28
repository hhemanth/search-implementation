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
          search_hash = data_files_indexer_service.search_service_hash.with_indifferent_access
          expect(search_hash.keys).to match_array(%w[User Organization Ticket])
          expect(search_hash['User']['data_file']).to include('users.json')
          expect(search_hash['User']['config_file']).to include('user_search_config.json')
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
                     email phone signature organization_id tags suspended role])
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
          search_results = data_files_indexer_service.search(index: 'User', attr: 'name', value: 'francisca')
          expect(search_results.first['_id']).to eq(1)
        end
        it 'should return all records with given search criteria along with reference records' do

        end
      end
      context 'search for multiple terms in an attribute in an Index' do
        it 'should return all records with any or all of the terms' do
        end
      end

      context 'search for empty string in an attribute in an Index ' do
        it 'should return all records with the attribute empty' do
        end
      end

      context ' search for nil value in an attribute in an Index' do
        it 'should return all records with the attribute empty' do
        end
      end

      context 'search for single term in all attributes in a Index' do
        it 'should return all records with the given search term' do
        end
      end
      context 'search for multiple terms in all attributes in an Index' do
        it 'should return all records with any or all of the terms' do
        end
      end

      context 'search for empty string in all attributes in an Index ' do
        it 'should return all records with the attribute empty' do
        end
      end

      context ' search for nil value in all attributes in an Index' do
        it 'should return all records with the attribute empty' do
        end
      end


      context 'search for single term in all attributes in all Indices' do
        it 'should return all records with the given search term' do
        end
      end
      context 'search for multiple terms in all attributes in all Indices' do
        it 'should return all records with any or all of the terms' do
        end
      end

      context 'search for empty string in all attributes in all Indices ' do
        it 'should return all records with the attribute empty' do
        end
      end

      context ' search for nil value in all attributes in all Indices' do
        it 'should return all records with the attribute empty' do
        end
      end



    end
  end
end