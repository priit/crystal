class Profile < Grant::Base
  connection primary
  table profiles

  column id : Int64, primary: true

  column user_id : Int64?
  column website : String?
  column location : String?
  column avatar_url : String?

  timestamps

  belongs_to :user, foreign_key: user_id

  # Add validations here:
  # validate :name, "can't be blank" do |model|
  #   !model.name.to_s.empty?
  # end
end
