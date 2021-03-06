class UsersController < ApplicationController

  def index
    @users = params[:id] ? User.where(id: params[:id]) : User.all
    render json: @users
  end

  def show
    @user = User.find(params[:id].to_i)
    render json: @user
  end

  def create
    # Get a user object
    @user = User.find_or_create_by(email: params[:user][:email].downcase)

    # save and update params if the user is new
    if @user.new_record?
      if !@user.update_attributes(params[:user])
        render json: @user.errors.messages, status: 422
        return
      end
    end
    if @user.authenticate_merge_strategy(params[:user][:password])
      render json: @user.session_api_key, status: 201
    else
      render json: "Error: User exists, but authentication failed", status: 401
    end
  end
end
