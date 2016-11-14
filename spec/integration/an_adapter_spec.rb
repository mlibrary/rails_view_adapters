# frozen_string_literal: true
require "active_record_helper"
require "spec_helper"

module RailsViewAdapters

  describe "an adapter", integration: true do
    date_format = "%Y-%m-%dT%H:%M:%S%z"
    secret_token = Faker::Internet.password
    Adapter.define(:user_integration_test_adapter) do
      map_simple :name, :author
      map_date :join_date, :member_since, date_format
      map_date :created_at, :created_at, date_format
      map_date :updated_at, :updated_at, date_format
      map_bool :admin, :super_user
      hidden_field :secret
      map_from_public :secret do |token|
        { secret: token }
      end
      map_belongs_to :team, :favorite_team, model_class: Team
      map_has_many :posts, :all_posts, sub_method: :body
    end

    before(:each) do
      @model = Fabricate(:user, secret: secret_token)
      Fabricate.times(3, :post, user: @model)

      @public_hash = {
        author: @model.name,
        member_since: @model.join_date.in_time_zone.strftime(date_format),
        super_user: @model.admin,
        favorite_team: @model.team.id,
        all_posts: @model.posts.pluck(:body),
        created_at: @model.created_at.in_time_zone.strftime(date_format),
        updated_at: @model.updated_at.in_time_zone.strftime(date_format)
      }

      @model_hash = {
        name: @model.name,
        join_date: @model.join_date,
        admin: @model.admin,
        secret: @model.secret,
        team: @model.team,
        posts: @model.posts,
        created_at: @model.created_at,
        updated_at: @model.updated_at
      }
    end

    it_behaves_like "an adapter", secret: secret_token do
      let(:adapter_class) { UserIntegrationTestAdapter }
      let(:model)         { @model }
      let(:public_hash)   { @public_hash }
      let(:model_hash)    { @model_hash }
    end
  end

end
