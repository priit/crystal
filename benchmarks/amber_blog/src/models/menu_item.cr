class MenuItem < Grant::Base
  connection primary
  table menu_items

  column id : Int64, primary: true

  column page_id : Int64?
  column label : String
  column url : String?
  column position : Int32?

  timestamps

  belongs_to :page, foreign_key: page_id

  # Add validations here:
  # validate :name, "can't be blank" do |model|
  #   !model.name.to_s.empty?
  # end
end
