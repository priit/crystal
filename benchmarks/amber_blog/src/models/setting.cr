class Setting < Grant::Base
  connection primary
  table settings

  column id : Int64, primary: true

  column key : String
  column value : String?

  timestamps

  # Add validations here:
  # validate :name, "can't be blank" do |model|
  #   !model.name.to_s.empty?
  # end
end
