class Post < Grant::Base
  connection primary
  table posts

  column id : Int64, primary: true

  column user_id : Int64?
  column category_id : Int64?
  column title : String
  column slug : String
  column body : String
  column published : Bool?
  column published_at : Time?

  timestamps

  belongs_to :user, foreign_key: user_id
  belongs_to :category, foreign_key: category_id
  has_many :comments
  has_many :post_tags
  has_many :tags, through: :post_tags

  def excerpt(length : Int32 = 200) : String
    body.size > length ? body[0, length] + "..." : body
  end

  def published? : Bool
    published == true
  end

  # Add validations here:
  # validate :name, "can't be blank" do |model|
  #   !model.name.to_s.empty?
  # end
end
