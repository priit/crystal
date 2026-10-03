class Tag < Grant::Base
  connection primary
  table tags

  column id : Int64, primary: true

  column name : String
  column slug : String

  timestamps

  has_many :post_tags
  has_many :posts, through: :post_tags

  # Add validations here:
  # validate :name, "can't be blank" do |model|
  #   !model.name.to_s.empty?
  # end
end
