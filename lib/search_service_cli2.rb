require_relative 'document_index'
require 'pastel'
require 'tty-prompt'
require 'tty-progressbar'
require 'active_support/core_ext/hash/indifferent_access'

class SearchServiceCli
  attr_accessor :data_files_indexer_service, :prompt, :bar, :pastel

  def initialize(data_files_indexer_service)
    @data_files_indexer_service = data_files_indexer_service
    initialize_cli
  end

  def run
    loop do
      user_input = prompt.select("Select Search Options:", ["Search Zendesk", "View Searchable Fields", "Quit"])
      break if user_input == "Quit"
      if user_input == "Search Zendesk"
        index_to_search = prompt.select("Select", data_files_indexer_service.indices)
        # doc_index = doc_indices_hash[index_to_search]
        attribute_to_search = prompt.select("Select Search term: ", data_files_indexer_service.attributes(index_to_search))
        value_to_search =prompt.select("Enter or Select Search value?", ["Enter value"] + data_files_indexer_service.attribute_values(index_to_search, attribute_to_search) )
        value_to_search = prompt.ask("Enter Value to search:") if value_to_search == "Enter value"
        pp data_files_indexer_service.search(index:index_to_search, attr: attribute_to_search, value: value_to_search)
      end
    end
  end

  def initialize_cli
    @pastel = Pastel.new
    puts @pastel.cyan("Welcome to Zendesk Search")
    @prompt = TTY::Prompt.new(active_color: 'magenta')

  end


  def progress_bar
    @bar = TTY::ProgressBar.new("loading [:bar]", total: 50)
    50.times do
      sleep(0.1)
      @bar.advance(5)
    end
  end
end