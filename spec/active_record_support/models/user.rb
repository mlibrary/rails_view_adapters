# frozen_string_literal: true
class User < ActiveRecord::Base
  belongs_to :team
  has_many :posts
end
