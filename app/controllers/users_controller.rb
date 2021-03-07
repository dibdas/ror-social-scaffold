class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @posts = @user.posts.ordered_by_most_recent
    @pending_friends = @user.pending_friends
    @mutual_friends = current_user.mutual_friends(@user)
  end

  def update
    @user = User.find(params[:id])
  end

  def delete
    @user = User.find(params[:id])
  end
end
