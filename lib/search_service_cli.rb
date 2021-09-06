require_relative 'document_index'
require 'pastel'
require 'tty-prompt'
require 'tty-progressbar'
require 'tty-table'
require 'tty-pager'
require 'tty-font'
require 'active_support/core_ext/hash/indifferent_access'

class SearchServiceCli
  attr_accessor :data_files_indexer_service, :prompt, :bar, :pastel

  def initialize(data_files_indexer_service)
    @data_files_indexer_service = data_files_indexer_service
    initialize_cli
  end

  def run
    data_files_indexer_service.indices.each do |index|
      puts @pastel.on_cyan("Indexing #{index}")
      progress_bar
    end

    loop do
      user_input = prompt.select("Select Search Options:", ["Search Zendesk", "View Searchable Fields", "Quit"])
      break if user_input == "Quit"
      if user_input == "Search Zendesk"
        search_zendex
      elsif user_input == "View Searchable Fields"
        view_searchable_fields
      end
    end
  end

  private

  def initialize_cli
    @pastel = Pastel.new
    puts @pastel.on_blue("Welcome to Zendesk Search")
    @prompt = TTY::Prompt.new(active_color: 'magenta')
    prompt = -> (page) { "Page -#{page_num}- Press enter to continue" }
    @pager = TTY::Pager::BasicPager.new(width: 180)
    @font = TTY::Font.new(:standard)
    puts @font.write("Zendesk Search")

  end


  def progress_bar
    @bar = TTY::ProgressBar.new("loading [:bar]", total: 50)
    50.times do
      @bar.advance(5)
    end
  end

  def print_arr_as_table(arr, header)
    table = TTY::Table.new(header: ["Searchable fields for #{header}"])
    arr.each do |element|
      table << [element]
    end
    puts table.render(:unicode)
  end

  def print_all_results_as_single_table(index:, search_results:)
    headers = search_results.first.keys.first(7)
    table = TTY::Table.new(header: headers)
    search_results.each do |res|
      cols = []
      headers.each do |h|
        col_val =   res[h].to_s.size > 20 ? res[h].to_s[0, 20] : res[h]
        cols <<  col_val
      end
      table << cols
    end
    puts table.render(:unicode)
  end

  def print_hash_as_table(search_results)
    begin
      search_results.each do |result|
        table = print_table(result)
        @pager.puts table.render(:unicode)

        result.each do |k, v|
          if v.is_a?(Hash)
            @pager.puts "************** #{k}***************"
            t = print_table(v)
            @pager.puts t.render(:unicode)
          end
        end

      end

    rescue TTY::Pager::PagerClosed
    ensure
      @pager.close
    end

  end

  def print_table(result)
    table = TTY::Table.new(header: ["Attribute", "Value"].map{|h| @pastel.inverse(h)})
    result.each do |k, v|
      v = v.to_s[0, 100] if v.to_s.size > 100
      table << [@pastel.inverse(k), v]
    end
    table
  end

  def view_searchable_fields
    index_input = prompt.select("Select", data_files_indexer_service.indices)
    attributes = attributes_arr(index_input)
    print_arr_as_table(attributes, index_input)
  end

  def search_zendex
    index_to_search = prompt.select("Select", indices_to_search)
    if index_to_search == "Search all indices"
      value_to_search = prompt.ask("Enter Value to search:")
      search_results = data_files_indexer_service.search_global(term: value_to_search)
    else
      attribute_to_search = prompt.select("Select Search term: ", attributes_arr(index_to_search))
      value_to_search = prompt.select("Enter or Select Search value?", ["Enter value"] + attribute_values(attribute_to_search, index_to_search))
      value_to_search = prompt.ask("Enter Value to search:") if value_to_search == "Enter value"
      search_results = data_files_indexer_service.search(index: index_to_search, attr: attribute_to_search, term: value_to_search.to_s)
    end


    if search_results.is_a?(Hash)
      search_results.each do |index, results|
        puts @pastel.on_blue("Results for  #{value_to_search} in #{index}")
        if results.size > 0
          print_all_results_as_single_table(index:index_to_search, search_results: results )
          print_hash_as_table(results)
        end
      end
    else
      puts @pastel.on_green("You searched for #{value_to_search} in #{index_to_search}[#{attribute_to_search}]")
      print_all_results_as_single_table(index:index_to_search, search_results: search_results )
      print_hash_as_table(search_results)
    end

  end

  def indices_to_search
    data_files_indexer_service.indices + ["Search all indices"]
  end
  def attribute_values(attribute_to_search, index_to_search)
    data_files_indexer_service.attribute_values(index_to_search, attribute_to_search)
  end

  def attributes_arr(index_to_search)
    data_files_indexer_service.attributes(index_to_search)
  end
end
