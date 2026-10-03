# Schema for validating Subscriber create/update parameters.
#
# Used by SubscriberController for request validation.
#
# See: https://amberframework.org/docs/v2/guides/schema-api/
class SubscriberSchema < Amber::Schema::Definition
  content_type "application/x-www-form-urlencoded"

  field :email, String, required: true, format: "email"
  field :confirmed, Bool
end
