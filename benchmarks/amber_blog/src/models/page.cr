class Page < Grant::Base
  connection primary
  table pages

  column id : Int64, primary: true

  column title : String
  column slug : String
  column body : String?
  column position : Int32?

  timestamps

  has_many :menu_items

  # Add validations here:
  # validate :name, "can't be blank" do |model|
  #   !model.name.to_s.empty?
  # end
end
