class UsersController < ApplicationController
  before_action :logged_in_user, only: [:show, :update, :destroy]
  before_action :set_user,       only: [:show, :update, :destroy]
  before_action :check_user,     only: [:show, :update, :destroy]

  # GET /users/1
  def show
  end

  # POST /users
  def create
    @user = new_account(user_params)

    if @user.save
      log_in @user
      # TODO: send this message as part of json response
      # flash[:success] = 'Thanks for signing up.'
      redirect_to root_url
    else
      # TODO: send client an error message
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      # TODO: send this message as part of json response
      # flash[:success] = 'Profile was successfully updated.'
      redirect_to user_path
    else
      # TODO: send back an error message
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to user_url, info: 'Profile was successfully destroyed.'
  end

  private

  def set_user
    id = current_user.id
    @user = User.find(id)
  end

  def new_account(params_for_new_account = {})
    Users::Account.new(params_for_new_account)
  end

  def user_params
    params.require(:users_account).permit(whitelisted_attr)
  end

  def whitelisted_attr
    [:name, :email, :password, :password_confirmation]
  end

  def check_user
    redirect_to(root_url) unless current_user?(@user)
  end
end
