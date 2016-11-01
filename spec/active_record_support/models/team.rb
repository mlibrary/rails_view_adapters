# frozen_string_literal: true
class Team < ActiveRecord::Base
  has_many :users
end
