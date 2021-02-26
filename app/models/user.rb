class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 20 }

  has_many :posts
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
end

 # Users who have yet to confirme friend request
def confirm_friend(user)
  friendship = inverse_friendships.find{|friendship| friendship.user == user}
  friendship.confirmed = true
  friendship.save
end
def friend_requests
  inverse_friendships.map{|friendship| friendship.user if !friendship.confirmed}.compact
end