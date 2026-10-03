# Schema for validating Profile create/update parameters.
#
# Used by ProfileController for request validation.
#
# See: https://amberframework.org/docs/v2/guides/schema-api/
class ProfileSchema < Amber::Schema::Definition
  content_type "application/x-www-form-urlencoded"

  field :user_id, Int64
  field :website, String
  field :location, String
  field :avatar_url, String
end
