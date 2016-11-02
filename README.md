# Rails View Adapters

[![Build Status](https://travis-ci.org/mlibrary/rails_view_adapters.svg?branch=master)](https://travis-ci.org/mlibrary/rails_view_adapters)
[![Coverage Status](https://coveralls.io/repos/github/mlibrary/rails_view_adapters/badge.svg?branch=master)](https://coveralls.io/github/mlibrary/rails_view_adapters?branch=master)

This gem provides a 
[DSL](http://www.rubydoc.info/github/mlibrary/rails_view_adapters/master/RailsViewAdapters/DefinitionProxy)
for defining adapters that map your model's 
representations to those of your views, and vice versa.  

### Adapters are presenters

The adapters can be used to convert a model to its public representation,
including associated models, as well as support for arbitrary operations.

```ruby
FooAdapter.from_model(Foo.find(id)).to_public_hash
```

### Adapters wrap input parameters

The adapters also understand how to "undo" the presentation logic,
converting the public representation back to the model or models 
that (may have) generated it.

```ruby
Bar.new(BarAdapter.from_public(params).to_params_hash)
```

## Usage

### Basics 

Define your adapter using the DSL.

```ruby
# lib/adapters/team_member_adapter.rb
require "rails_view_adapters"
RailsViewAdapters::Adapter.define(:team_member_adapter) do
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
```

Then require and use it like you would any other class.

```ruby
require "lib/adapters/team_member_adapter"
TeamMemberAdapter.from_model(TeamMember.find(params[:id])).to_public_hash
```

### Rails

I've found it convenient to create a concern that gets invoked in a controller
`before_action` to automatically grab the right adapter, instantiate it, and use
it to modify the params hash.  Something like this:

```ruby
module Adaptation
  extend ActiveSupport::Concern

  included do
    append_before_action :adapt_params
  end

  private
  def adapt_params
    adapter = "#{controller_path.classify.gsub("Controller", "")}Adapter".constantize
    params.merge!(adapter.from_public(params).to_params_hash) {|key,lhs,rhs| rhs}
  end
end
```

### Testing Adapters

Individual needs will vary, but for a reasonable integration test take a look at 
`spec/integration/an_adapter_spec.rb`

Do note that the above relies on your controllers and adapters being named predictably.

## Documentation
http://www.rubydoc.info/github/mlibrary/rails_view_adapters/

# License

Copyright (c) 2015 The Regents of the University of Michigan.
All Rights Reserved.
Licensed according to the terms of the Revised BSD License.
See LICENSE.md for details.

