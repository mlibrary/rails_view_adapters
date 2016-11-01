# frozen_string_literal: true
require "active_record"
require "fabrication"

require "active_record_support/models/user"
require "active_record_support/models/post"
require "active_record_support/models/team"

require "active_record_support/fabricators/user_fabricator"
require "active_record_support/fabricators/post_fabricator"
require "active_record_support/fabricators/team_fabricator"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveSupport::Deprecation.silenced = true
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate File.join(File.dirname(__FILE__), "active_record_support/db/migrate")
