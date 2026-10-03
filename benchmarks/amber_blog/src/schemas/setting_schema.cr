# Schema for validating Setting create/update parameters.
#
# Used by SettingController for request validation.
#
# See: https://amberframework.org/docs/v2/guides/schema-api/
class SettingSchema < Amber::Schema::Definition
  content_type "application/x-www-form-urlencoded"

  field :key, String, required: true
  field :value, String
end
