class SrcIndex
  attr_accessor :index_name,:source_index
  def initialize(index_name)
    @index_name = index_name
    @source_index = {}
  end

  def index!(documents)
      documents.each do |doc|
        doc_id = doc['_id']
        source_index[doc_id] = doc
      end
  end

  def no_documents
    ids.size
  end

  def ids
    source_index.keys
  end

  def documents(ids)
    source_index.values_at(*ids).compact
  end
end