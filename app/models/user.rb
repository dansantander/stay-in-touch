class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 20 }

  has_many :posts
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  # Friendship associatons

  has_many :friendships, class_name: 'Friendship', foreign_key: 'confirmer_id'
  has_many :confirmers, through: :friendships, source: :confirmer

  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'requester_id'
  has_many :requesters, through: :friendships, source: :requester

  def friends
    friends_array = friendships.map { |friendship| friendship.requester if friendship.confirmed }
    friends_array + inverse_friendships.map { |friendship| friendship.confirmer if friendship.confirmed }
    friends_array.compact
  end

  # Users who have yet to confirm friend requests
  def pending_friends
    friendships.map { |friendship| friendship.requester unless friendship.confirmed }.compact
  end

  # Users who have requested to be friends
  def friend_requests
    inverse_friendships.map { |friendship| friendship.confirmer unless friendship.confirmed }.compact
  end

  def confirm_friend(user)
    friendship = inverse_friendships.find { |f| f.confirmer == user }
    friendship.confirmed = true
    friendship.save
  end

  def friend?(user)
    friends.include?(user)
  end

  def friendship_created?(confirmer)
    friendships.find_by(confirmer_id: confirmer.id).nil? && created_inverse?(confirmer)
  end

  def created_inverse?(confirmer)
    confirmer.inverse_friendships.find_by(confirmer_id: id).nil?
  end
end
