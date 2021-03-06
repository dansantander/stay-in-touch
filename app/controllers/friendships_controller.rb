class FriendshipsController < ApplicationController
  include FriendshipsHelper

  def index
    @friendship = Friendship.all
    @cu_friendships = Friendship.where(confirmer: current_user.id)

    @cu_friendships.each do |friendship|
      @single_friendship = friendship.id
    end
  end

  def new
    @friendship = Friendship.new
  end

  def create
    @friendship = Friendship.new(friendship_params)

    if @friendship.save
      flash.notice = 'Friend Request Succesfully Sent'
      redirect_to users_path
    else
      flash.alert = @friendship.errors.full_messages[0]
      redirect_to root_path
    end
  end

  def edit; end

  def update
    user_id = current_user.id
    @friendship = Friendship.find_by(confirmer: user_id)
    accepted = @friendship.update_attribute(:confirmed, params[:confirmed] = true)

    if accepted
      redirect_to user_path(user_id), notice: 'Friend request Succesfully Accepted'
    else
      redirect_to user_path(user_id), alert: 'Something Went wrong'
    end
  end

  def destroy
    user_id = current_user.id
    @friendship = Friendship.find_by(confirmer: user_id)
    deleted = @friendship.destroy

    if deleted
      redirect_to user_path(user_id), notice: 'Friend request Succesfully Rejected'
    else
      redirect_to user_path(user_id), alert: 'Something Went wrong'
    end
  end
end
