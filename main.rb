require_relative 'lib/document_index'
require 'json'
require 'pastel'
require 'tty-prompt'
require 'tty-progressbar'
require_relative 'lib/search_service_cli'

search_options =

    [
        {
            index_name: 'User',
            data_file: 'data/users.json',
            config_file: 'data/user_search_config.json'
        }
    ]


SearchServiceCli.new(search_options).run


# progress_bar
#
# pastel = Pastel.new
# puts pastel.cyan("Hello World")
#
#
# def password
#   prompt = TTY::Prompt.new(active_color: 'magenta')
#   user_input = prompt.mask("Enter your password")
# end
#
# def choose_sport
#   prompt = TTY::Prompt.new(active_color: 'magenta')
#   user_input = prompt.select("Choose your sport?", ["Football", "Basketball", "Tennis"])
# end
#
# choose_sport
#
# user_docs_options  = {
#     schema: {
#         tokenize_list: ['name', 'signature', 'tags']
#     }
# }
#
# user_doc_index = DocumentIndex.new('User',user_docs_options)
# user_file = File.read('data/users.json')
# data_hash = JSON.parse(user_file)
# user_doc_index.index!(data_hash)
# binding.pry
#
#
# org_docs_options  = {
#     schema: {
#         tokenize_list: ['name', 'domain_names', 'details','tags']
#     }
# }
#
# org_doc_index = DocumentIndex.new('Organisation',org_docs_options)
# org_file = File.read('data/organizations.json')
# data_hash = JSON.parse(org_file)
# org_doc_index.index!(data_hash)
# binding.pry
# pp "Indexing complete"
#
# ticket_docs_options  = {
#     schema: {
#         tokenize_list: ['subject', 'description', 'tags']
#     }
# }
#
# ticket_doc_index = DocumentIndex.new('Ticket',ticket_docs_options)
# ticket_file = File.read('data/tickets.json')
# data_hash = JSON.parse(ticket_file)
# ticket_doc_index.index!(data_hash)
# binding.pry
# pp "Indexing complete"
