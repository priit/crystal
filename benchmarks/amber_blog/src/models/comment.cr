class Comment < Grant::Base
  connection primary
  table comments

  column id : Int64, primary: true

  column post_id : Int64?
  column user_id : Int64?
  column body : String
  column approved : Bool?

  timestamps

  belongs_to :post, foreign_key: post_id
  belongs_to :user, foreign_key: user_id

  # Add validations here:
  # validate :name, "can't be blank" do |model|
  #   !model.name.to_s.empty?
  # end
end
