# Schema for validating MenuItem create/update parameters.
#
# Used by MenuItemController for request validation.
#
# See: https://amberframework.org/docs/v2/guides/schema-api/
class MenuItemSchema < Amber::Schema::Definition
  content_type "application/x-www-form-urlencoded"

  field :page_id, Int64
  field :label, String, required: true
  field :url, String
  field :position, Int32
end
