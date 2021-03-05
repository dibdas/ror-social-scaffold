class FriendshipsController < ApplicationController
  before_action :authenticate_user!
  def create
    @user = User.find(params[:user_id])
    current_user.send_friend_requests_to(@user)
    redirect_to root_path, notice: 'Invited '
  end

  def update
    @user = User.find(params[:user_id])
    current_user.accept_friend_request_of(@user)
    redirect_to root_path, notice: 'accepted'
  end

  def destroy
    @user = User.find(params[:user_id])
    current_user.delete_friend_request_of(@user)
    redirect_to root_path, notice: 'rejected'
  end
end
