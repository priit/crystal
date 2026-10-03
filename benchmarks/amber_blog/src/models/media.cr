class Media < Grant::Base
  connection primary
  table medias

  column id : Int64, primary: true

  column user_id : Int64?
  column filename : String
  column content_type : String?
  column byte_size : Int64?

  timestamps

  belongs_to :user, foreign_key: user_id

  # Add validations here:
  # validate :name, "can't be blank" do |model|
  #   !model.name.to_s.empty?
  # end
end
