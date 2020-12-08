require_relative './src_index'
require_relative './attribute_index'
require_relative './composite_tokenizer'

require 'pry'

class DocumentIndex
  attr_accessor :index_name,:options,  :src_index, :attribute_index_hash, :tokenize_list

  def initialize(index_name, options={})
    @index_name = index_name
    @options = options
    @src_index = SrcIndex.new(index_name)
    @attribute_index_hash = {}
    load_schema
  end

  def load_schema
    if options.nil?  || options[:schema].nil?
      @tokenize_list = []
    else
      schema = options[:schema]
      @tokenize_list = schema[:tokenize_list] || []
    end

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

  def search(argv)
    attr = argv[:attr]
    term = argv[:val]

    attr_index = attribute_index_hash[attr]
    return [] if attr_index.nil?

    document_ids = attr_index.search(term)
    src_index.documents(document_ids)
  end

  private

  def index_doc!(document)
    document.each do |k, v|
      attribute_index_hash[k] ||= AttributeIndex.new(index_name, k)

      tokens = tokenize_list.include?(k) ? fetch_tokens(v): [v.to_s]

      next if tokens.nil? || (tokens.is_a?(Array) && tokens.size == 0)
      tokens.each do |t|
        attribute_index_hash[k].index!(t, document['_id'])
      end
    end
  end

  def fetch_tokens(v)
    CompositeTokenizer.new(v).tokens
  end
end