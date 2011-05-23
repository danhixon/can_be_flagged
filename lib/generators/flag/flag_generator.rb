require 'rails/generators/migration'

class FlagGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  def self.source_root
    @_flag_this_source_root ||= File.expand_path("../templates", __FILE__)
  end

  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

  def create_model_file
    template "flag.rb", "app/models/flag.rb"
    migration_template "create_flags.rb", "db/migrate/create_flags.rb"
  end
end
