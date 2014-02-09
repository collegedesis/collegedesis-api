class SessionsController < ApplicationController
  after_filter :log_log_in, only: [:create]

  def create
    user = User.where(email: params[:session][:email]).first
    if user && user.authenticate(params[:session][:password])
      render json: user.session_api_key, status: 201
    else
      render json: {}, status: 401
    end
  end

  def destroy
    session = lookup_session(params[:session])
    session.expire
    render nothing: true, status: 204
  end

private
  # TODO Use a real logger please. kthx
  def log_log_in
    if current_user
      puts "----------#{params[:email]}logging in!---------"
      puts current_user.email
      puts "-----------logging in---------"
    end
  end
end