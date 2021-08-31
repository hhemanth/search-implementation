# Stores
class AttributeIndex
  attr_accessor :index_name, :attribute_name, :attr_index

  def initialize(index_name, attribute_name)
    @index_name = index_name
    @attribute_name = attribute_name
    @attr_index = {}
  end

  def index!(attr_val, doc_index)

    attr_index[process(attr_val)] ||= []
    attr_index[process(attr_val)] << doc_index

  end

  def search(term)
    attr_index[process(term)]&.uniq || []
  end

  def process(q)
    q.to_s.downcase
  end

  def attr_values
    attr_index.keys
  end

end