# This the integration class
# Provides APIs search, search_global & index!
# contains doc_indices_hash & search_config
# search_config has info about data_file, config_file(schema), also performs input & schema validations
# doc_indices_hash is a index->doc_index hash, which contains all the document indices being indexed.

require 'pry'
require 'json'
require_relative './document_index'
require_relative './index_search_config'
require_relative './annotate_search_results'
class DataFilesIndexerService
  attr_accessor :search_options, :doc_indices_hash, :search_config

  class ConfigInvalid < StandardError
  end

  def initialize(search_options)
    @search_options = search_options
    @doc_indices_hash = {}
    @search_config = IndexSearchConfig.new(search_options)
  end

  def config_valid?
    search_config.valid?
  end

  def errors
    search_config.errors
  end

  def attributes(index)
    doc_index = doc_indices_hash[index]
    doc_index.attributes
  end

  def attribute_values(index, attr)
    doc_index = doc_indices_hash[index]
    doc_index.values_for_attr(attr)
  end

  def index_data_files!
    raise ConfigInvalid unless config_valid?
    indices.each do |index|
      doc_index = DocumentIndex.new(index, cur_config(index))
      data_file = search_config.data_file(index)
      data = JSON.parse(File.read(data_file))
      doc_index.index!(data)
      doc_indices_hash[index] = doc_index
    end
    return true
  end


  def indices
    search_config.indices
  end

  def cur_config(index)
    search_config.cur_config(index)
  end

  def search_global(term:nil)
    result = {}
    doc_indices_hash.keys.each do |index|
      result[index] = search(index: index, term: term)
    end
    result
  end

  def search(index:nil, attr:nil, term:nil)
    doc_index = doc_indices_hash[index]
    result = search_tokens(term).flat_map do |t|
      doc_index.search(attr: attr, val: t)
    end.uniq
    annotate_result = AnnotateSearchResults.new(doc_indices_hash, search_config)
    annotate_result.run!(result, index: index)
    result

  end

  private

  def search_tokens(input_text)
    return [''] if input_text.to_s.strip == ''
    (input_text.to_s).split(' ').map(&:downcase)
  end


end
