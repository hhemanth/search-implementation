#Indexes and stores the document for easy searching
# Consider the following document
# Provied following APIs
# search & index!
# contains src_index, which is a index->document hash
# contains attribute_index_hash which is a attribute->attribute_index_hash

require_relative './src_index'
require_relative './attribute_index'
require_relative './composite_tokenizer'

require 'pry'

class DocumentIndex
  attr_accessor :index_name,:options,  :src_index, :attribute_index_hash, :tokenize_list

  def initialize(index_name, iconfig=nil)
    @index_name = index_name
    @options = options
    @src_index = SrcIndex.new(index_name)
    @attribute_index_hash = {}
    @tokenize_list = iconfig&.tokenize_list || []
    # load_schema
  end


  def no_documents
    src_index.no_documents
  end

  def attributes
    attribute_index_hash.keys
  end

  def values_for_attr(attr)
    attribute_index_hash[attr].attr_values
  end

  def index!(docs_arr)
    src_index.index!(docs_arr)
    docs_arr.each do |doc|
      index_doc!(doc)
    end
  end

  def get(id)
    src_index.get(id)
  end

  def search(argv)
    attr = argv[:attr]
    term = argv[:val]
    attr = "#{index_name}_all_attrs" if attr.nil?
    attr_index = attribute_index_hash[attr]
    return [] if attr_index.nil?

    document_ids = attr_index.search(term)
    src_index.documents(document_ids)
  end

  private

  def index_doc!(document)
    document.each do |k, v|
      attribute_index_hash[k] ||= AttributeIndex.new(index_name, k)

      tokens = tokenize_list.include?(k) ? fetch_tokens(v): [v.to_s.strip]

      next if tokens.nil? || (tokens.is_a?(Array) && tokens.size == 0)
      tokens.each do |t|
        attribute_index_hash[k].index!(t, document['_id'])
        all_attrs_index.index!(t, document['_id'])
      end
    end
  end

  def fetch_tokens(v)
    CompositeTokenizer.new(v).tokens
  end

  def all_attrs_index
    attribute_index_hash["#{index_name}_all_attrs"] ||= AttributeIndex.new(index_name, "#{index_name}_all_attrs")
  end
end