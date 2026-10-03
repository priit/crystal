# Schema for validating Media create/update parameters.
#
# Used by MediaController for request validation.
#
# See: https://amberframework.org/docs/v2/guides/schema-api/
class MediaSchema < Amber::Schema::Definition
  content_type "application/x-www-form-urlencoded"

  field :user_id, Int64
  field :filename, String, required: true
  field :content_type, String
  field :byte_size, Int64
end
