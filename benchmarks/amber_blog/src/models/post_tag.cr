class PostTag < Grant::Base
  connection primary
  table post_tags

  column id : Int64, primary: true

  column post_id : Int64?
  column tag_id : Int64?

  timestamps

  belongs_to :post, foreign_key: post_id
  belongs_to :tag, foreign_key: tag_id

  # Add validations here:
  # validate :name, "can't be blank" do |model|
  #   !model.name.to_s.empty?
  # end
end
