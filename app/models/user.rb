class User < ApplicationRecord
  
  before_save{ self.email.downcase!}
  
  has_many :microposts
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverce_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverce_of_relationship, source: :user
  has_many :user_microposts
  has_many :favorite_microposts, through: :user_microposts, source: :micropost
  
  validates :name, presence: true, length: {maximum: 50}
  validates :email, presence: true, length: {maximum: 255},
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  
  has_secure_password
  
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end
  
  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end
  
  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids << self.id)
  end
  
  def favorite(micropost)
    self.user_microposts.find_or_create_by(micropost_id: micropost.id)
  end
  
  def unfavorite(micropost)
    user_micropost = self.user_microposts.find_by(micropost_id: micropost.id)
    user_micropost.destroy if user_micropost
  end
  
  def favorite?(micropost)
    self.favorite_microposts.include?(micropost)
  end
end
