class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 20 }

  has_many :posts
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :active_friendships, class_name: 'Friendship', foreign_key: :sender_id, dependent: :destroy
  has_many :senders, through: :active_friendships, source: :receiver
  has_many :passive_friendships, class_name: 'Friendship', foreign_key: :receiver_id, dependent: :destroy
  has_many :receivers, through: :passive_friendships, source: :sender

  def friends
    friends_array = active_friendships.map { |f| f.receiver if f.accepted? }
    friends_array += passive_friendships.map { |f| f.requester if f.accepted? }
    friends_array.compact
  end

  # Users who have yet to confirme friend requests
  def pending_friends
    friends = passive_friendships.map { |f| f.sender if f.pending? }
    friends.compact
  end

  def send_friend_requests_to(user)
    active_friendships.create(receiver_id: user.id)
  end

  def accept_friend_request_of(_user)
    friend_request = passive_friendships.map { |f| f.sender if f.pending? }
    friend_request.accepted!
  end

  def delete_friend_request_of(user)
    friendship = Friendship.find_by(sender: user,
                                    receiver: self) || Friendship.find_by(sender: self, receiver: user)
    friendship.destroy
  end

  def friend?(user)
    friends.include?(user)
  end

  def friend_request_pending_from?(user)
    Friendship.where(sender: user, receiver: self, status: 'pending').exists?
  end

  def friend_request_pending_to?(user)
    Friendship.where(sender: self, requester: user, status: 'pending').exists?
  end

  def no_relation?(user)
    !friend?(user) && !friend_request_pending_from?(user) && !friend_request_pending_to?(user)
  end
end
