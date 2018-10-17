class Micropost < ApplicationRecord
  belongs_to :user
  has_many :user_microposts
  has_many :fans, through: :user_microposts, source: :user
  
  validates :content, presence: true, length: {maximum: 255}
end
