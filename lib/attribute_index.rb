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

    # if attr_val.is_a?(Array)
    #   index_array(attr_val, doc_index)
    # elsif attr_val.is_a?(String)
    #   index_str(attr_val, doc_index)
    # else
    #   index_other(attr_val, doc_index)
    # end
    #
  end

  def search(term)
    attr_index[process(term)]&.uniq || []
  end

  def process(q)
    q.to_s.downcase
  end

  # def index_array(attr_val, doc_id)
  #   attr_val.each do |attr|
  #     attr_index[process(attr)] ||= []
  #     attr_index[process(attr)] << doc_id
  #   end
  # end
  #
  # def index_str(attr_val, doc_id)
  #   attr_val.split.each do |attr|
  #     attr_index[process(attr)] ||= []
  #     attr_index[process(attr)] << doc_id
  #   end
  # end
  #
  # def index_other(attr_val, doc_id)
  #   attr_index[process(attr_val)] ||= []
  #   attr_index[process(attr_val)] << doc_id
  # end


end