
# defines a class IngestAdapter
Adapter.define(:ingest_adapter) do
  map_date :created_at, :created_at, Time::DATE_FORMATS[:dpn]
  map_simple      :ingest_id, :ingest_id
  map_belongs_to  :bag,       :bag,       sub_method: :uuid
  map_bool        :ingested,  :ingested
  map_has_many :nodes, :replicating_nodes, model_class: Node, sub_method: :namespace
end