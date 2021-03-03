require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe 'associations' do
    it { is_expected.to have_many(:posts) }
    it { is_expected.to have_many(:likes) }
    it { is_expected.to have_many(:comments) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(20) }
  end

  describe '#send_friend_requests_to' do
    context 'one time request' do
      it 'send friend request with pending status' do
        user = create(:user)
        another_user = create(:user)
        user.send_friend_requests_to(another_user)
        expect(user.receivers.map(&:id)).to match_array([another_user.id])
        expect(user.active_friendships.first.status).to eq('pending')
      end
    end

    it 'raise an error if user send multiple request' do
      user = create(:user)
      another_user = create(:user)
      user.send_friend_requests_to(another_user)
      expect { user.send_friend_requests_to(another_user) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe '#accept_friend_request_of' do
    it 'accept friend request ' do
      user = create(:user)
      another_user = create(:user)
      user.send_friend_requests_to(another_user)
      another_user.accept_friend_request_of(user)
      expect(user.active_friendships.first.status).to eq('accepted')
      expect(another_user.passive_friendships.first.status).to eq('accepted')
    end
  end

  describe '#delete_friend_request_of' do
    it 'delete friend request of the sender' do
      user = create(:user)
      another_user = create(:user)
      user.send_friend_requests_to(another_user)
      another_user.delete_friend_request_of(user)
      expect(user.receivers.map(&:id)).to match_array([])
      expect(another_user.receivers.map(&:id)).to match_array([])
    end
  end

  describe '#friends' do
    it 'list of all friends of the user' do
      user = create(:user)
      another_user = create(:user)
      user.send_friend_requests_to(another_user)
      another_user.accept_friend_request_of(user)

      expect(user.friends.map(&:id)).to match_array([another_user.id])
      expect(another_user.friends.map(&:id)).to match_array([user.id])
    end

    it 'does not list the friends that have pending status' do
      user = create(:user)
      another_user = create(:user)
      another_user.send_friend_requests_to(user)
      expect(user.friends.count).to be_zero
    end
  end

  describe '#friend?' do
    it 'returns true if the user is friend of another user' do
      user = create(:user)
      another_user = create(:user)
      user.send_friend_requests_to(another_user)
      another_user.accept_friend_request_of(user)

      expect(user.friend?(another_user)).to be_truthy
    end

    it 'return false if the user is not  friend of another user' do
      user = create(:user)
      another_user = create(:user)
      user.send_friend_requests_to(another_user)
      expect(user.friend?(another_user)).to be_falsy
    end
  end
end
