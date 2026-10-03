# Schema for validating User create/update parameters.
#
# Used by UserController for request validation.
#
# See: https://amberframework.org/docs/v2/guides/schema-api/
class UserSchema < Amber::Schema::Definition
  content_type "application/x-www-form-urlencoded"

  field :name, String, required: true
  field :email, String, required: true, format: "email"
  field :bio, String
  field :admin, Bool
end
