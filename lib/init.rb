require 'yaml'
require 'sequel'
require 'tilt/erubis'
require 'rdiscount'
require 'cgi'
require 'uri'

CONFIG = YAML.load_file('config.yml')

DB = Sequel.connect(CONFIG['database']['connection_string'])

require_relative '../db/post'

unless DB.table_exists?(:posts)
  DB.create_table :posts do
    primary_key :id
    column :body, :text
    DateTime :created_at
    DateTime :updated_at
  end
end
