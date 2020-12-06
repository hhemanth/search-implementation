require_relative 'document_index'
require 'pastel'
require 'tty-prompt'
require 'tty-progressbar'
require 'active_support/core_ext/hash/indifferent_access'

class SearchServiceCli
  attr_accessor :search_options, :search_service_hash, :doc_indices_hash, :prompt, :bar, :pastel

  def initialize(search_options)
    @search_options = search_options
    @search_service_hash = {}
    @doc_indices_hash = {}
    initialize_cli
    parse_search_options
    index_data_files

  end

  def run
    loop do
      user_input = prompt.select("Select Search Options:", ["Search Zendesk", "View Searchable Fields", "Quit"])
      break if user_input == "Quit"
      if user_input == "Search Zendesk"
        index_to_search = prompt.select("Select", doc_indices_hash.keys)
        binding.pry
        doc_index = doc_indices_hash[index_to_search]
        attribute_to_search = prompt.select("Select Search term: ", doc_index.attributes)
        value_to_search =prompt.select("Enter or Select Search value?", ["Enter value"] + doc_index.attribute_index_hash[attribute_to_search].attr_values )
        value_to_search = prompt.ask("Enter Value to search:") if value_to_search == "Enter value"
        pp doc_index.search(attr: attribute_to_search, val: value_to_search)
      end
    end
  end

  def initialize_cli
    @pastel = Pastel.new
    puts @pastel.cyan("Welcome to Zendesk Search")
    @prompt = TTY::Prompt.new(active_color: 'magenta')

  end

  def parse_search_options
    search_options.each do |search_option|
      search_index = search_option[:index_name]
      search_service_hash[search_index] = {
          data_file: Dir::pwd + '/' + search_option[:data_file],
          config_file: Dir::pwd + '/'+ search_option[:config_file]
      }
    end
  end

  def index_data_files
    search_service_hash.each do |search_index, search_params|
      data_file = search_params[:data_file]
      data = JSON.parse(File.read(data_file))
      config_file = search_params[:config_file]
      config = JSON.parse(File.read(config_file)).with_indifferent_access
      doc_index = DocumentIndex.new(search_index,config)
      doc_index.index!(data)
      puts pastel.cyan("Indexing #{search_index}")
      progress_bar
      doc_indices_hash[search_index] = doc_index
    end
  end

  def progress_bar
    @bar = TTY::ProgressBar.new("loading [:bar]", total: 50)
    50.times do
      sleep(0.1)
      @bar.advance(5)
    end
  end
end