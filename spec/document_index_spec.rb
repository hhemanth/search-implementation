require 'rspec'
require 'document_index'
require 'pry'
require 'active_support/core_ext/hash/indifferent_access'

RSpec.describe DocumentIndex do

  let(:index_name) {'User'}
  let(:options) { {schema: {tokenize_list: ["subject", "description", "tags"]}}}
  let(:document_index) {DocumentIndex.new(index_name, options)}
  let(:document1) {
    {
        "_id": "1a227508-9f39-427c-8f57-1b72f3fab87c",
        "url": "http://initech.zendesk.com/api/v2/tickets/1a227508-9f39-427c-8f57-1b72f3fab87c.json",
        "external_id": "3e5ca820-cd1f-4a02-a18f-11b18e7bb49a",
        "created_at": "2016-04-14T08:32:31 -10:00",
        "type": "incident",
        "subject": "A Catastrophe in Micronesia",
        "description": "Aliquip excepteur fugiat ex minim ea aute eu labore. Sunt eiusmod esse eu non commodo est veniam consequat.",
        "priority": "low",
        "status": "hold",
        "submitter_id": 71,
        "assignee_id": 38,
        "organization_id": 112,
        "tags": [
            "Puerto Rico",
            "Idaho",
            "Oklahoma",
            "Louisiana"
        ],
        "description2": '  ',
        "has_incidents": false,
        "due_at": "2016-08-15T05:37:32 -10:00",
        "via": "chat"
    }.stringify_keys
  }

  let(:document2) {
    {
        "_id": "674a19a1-c330-45fb-8b61-b4d77ba87130",
        "url": "http://initech.zendesk.com/api/v2/tickets/674a19a1-c330-45fb-8b61-b4d77ba87130.json",
        "external_id": "050ea8ce-251c-44c8-b71c-535dd9072a74",
        "created_at": "2016-03-07T08:24:53 -11:00",
        "type": "task",
        "subject": "A Drama in St. Pierre and Miquelon",
        "description": "Incididunt exercitation voluptate eu laborum proident Lorem minim pariatur. Lorem culpa amet Lorem Lorem commodo anim deserunt do consectetur sunt.",
        "priority": "low",
        "status": "open",
        "submitter_id": 49,
        "assignee_id": 14,
        "organization_id": 109,
        "tags": [
            "Connecticut",
            "Arkansas",
            "Missouri",
            "Alabama"
        ],
        "description1": '',
        "has_incidents": false,
        "due_at": "2016-08-15T06:13:11 -10:00",
        "via": "voice"
    }.stringify_keys
  }
  before do
    document_index.index!([document1.with_indifferent_access, document2.with_indifferent_access])
  end


  context '#index_name' do
    it 'should return index_name' do
      expect(document_index.index_name).to eq('User')
    end
  end

  context '#attributes' do
    it 'should return attributes of documents indexed' do
      expect(document_index.attributes).to match_array((document1.keys + document2.keys).uniq)
    end
  end

  context '#no_documents' do
    it 'should return no of documents' do
      expect(document_index.no_documents).to eq(2)
    end
  end

  context '#values_for_attr' do
    it 'returns all values, given an attribute' do
      expect(document_index.values_for_attr('type')).to match_array(['incident', 'task'])
    end
  end

  context 'search empty values' do
    context '#search' do
      it 'search for empty string in an attribute' do
        expect(document_index.search(attr: 'description1', val: '')).to eq([document2])
      end

      it 'search for nil in an attribute' do
        expect(document_index.search(attr: 'description1', val: nil)).to eq([document2])
      end

      it 'search for empty string when value contained spaces' do
        expect(document_index.search(attr: 'description2', val: '')).to eq([document1])
      end

      it 'search for empty string when value contained spaces' do
        expect(document_index.search(attr: 'description2', val: nil)).to eq([document1])
      end


    end
  end
  context '#search' do
    it 'search for id' do
      expect(document_index.search(attr: '_id', val: '674a19a1-c330-45fb-8b61-b4d77ba87130')).to eq([document2])
    end

    it 'search for tags' do
      expect(document_index.search(attr: 'tags', val: 'Alabama')).to eq([document2])
    end

    it 'search for date & time' do
      expect(document_index.search(attr: 'due_at', val: '2016-08-15T06:13:11 -10:00')).to eq([document2])
    end
    xit 'search for string in text' do
      res_hash = {
          documents: {
              "1a227508-9f39-427c-8f57-1b72f3fab87c"=> {
                  "data"=> document2,
                  "references"=> {
                      "tickets" => ticket_ids,
                      "users" => user_ids
                  }
              }
          }
      }
      expect(document_index.search(attr: 'subject', val: 'Miquelon')).to eq(res_hash)
    end
  end
end

