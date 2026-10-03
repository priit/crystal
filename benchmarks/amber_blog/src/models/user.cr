class User < Grant::Base
  connection primary
  table users

  column id : Int64, primary: true

  column name : String
  column email : String
  column bio : String?
  column admin : Bool?

  timestamps

  has_one :profile
  has_many :posts
  has_many :comments
  has_many :media

  def display_name : String
    admin? ? "#{name} (admin)" : name
  end

  def admin? : Bool
    admin == true
  end

  # Add validations here:
  # validate :name, "can't be blank" do |model|
  #   !model.name.to_s.empty?
  # end
end
