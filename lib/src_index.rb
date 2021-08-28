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