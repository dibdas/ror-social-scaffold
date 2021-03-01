class FriendshipsController < ApplicationController
  before_action :authenticate_user!
  def create
    @user = User.find(params[:id])
  end
end
