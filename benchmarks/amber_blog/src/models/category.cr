class Category < Grant::Base
  connection primary
  table categories

  column id : Int64, primary: true

  column name : String
  column slug : String
  column description : String?

  timestamps

  has_many :posts

  # Add validations here:
  # validate :name, "can't be blank" do |model|
  #   !model.name.to_s.empty?
  # end
end
