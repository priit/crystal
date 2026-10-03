class Subscriber < Grant::Base
  connection primary
  table subscribers

  column id : Int64, primary: true

  column email : String
  column confirmed : Bool?

  timestamps

  # Add validations here:
  # validate :name, "can't be blank" do |model|
  #   !model.name.to_s.empty?
  # end
end
