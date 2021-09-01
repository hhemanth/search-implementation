# Stores hash table where the key is the ID of the document and value is the whole document

# Consider the following Index (Document), index_name: Person
# [{"_id" => 1, "name" => "Hemanth Haridas", "age"=> 35, "occupation"=> "Software Engineer"},
#  {"_id" => 2, "name" => "Jack Straw", "age"=> 25, "occupation"=> "Senior Software Engineer"},
# ]
# Then the indexing will result in the following SrcIndex
# SrcIndex index_name: Person,  source_index: {"1" => {"_id" => 1, "name" => "Hemanth Haridas", "age"=> 35, "occupation"=> "Software Engineer"},
#                                              "2" => {"_id" => 2, "name" => "Jack Straw", "age"=> 25, "occupation"=> "Senior Software Engineer"}
#                                              }

class SrcIndex
  attr_accessor :index_name,:source_index
  def initialize(index_name)
    @index_name = index_name
    @source_index = {}
  end

  def index!(documents)
      documents.each do |doc|
        doc_id = doc['_id']
        source_index[doc_id.to_s] = doc
      end
  end

  def no_documents
    ids.size
  end

  def ids
    source_index.keys
  end

  def get(id)
    source_index[id.to_s]
  end

  def documents(ids)
    source_index.values_at(*(ids.map(&:to_s))).compact
  end
end