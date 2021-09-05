require_relative 'lib/document_index'
require 'json'
require 'pastel'
require 'tty-prompt'
require 'tty-progressbar'
require_relative 'lib/search_service_cli'
require_relative 'lib/data_files_indexer_service'

search_options =

    [
        {
            index_name: 'User',
            data_file: 'data/users.json',
            config_file: 'data/user_search_config.json'
        },
        {
            index_name: 'Organization',
            data_file: 'data/organizations.json',
            config_file: 'data/organization_search_config.json'
        },
        {
            index_name: 'Ticket',
            data_file: 'data/tickets.json',
            config_file: 'data/ticket_search_config.json'
        }

    ]

begin
  data_indexer_service = DataFilesIndexerService.new(search_options)
  data_indexer_service.index_data_files!
rescue StandardError => e
  puts "********Something went Wrong*******"
  puts data_indexer_service.errors
  exit
end

SearchServiceCli.new(data_indexer_service).run