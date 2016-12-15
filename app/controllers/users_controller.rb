class UsersController < ApplicationController
  include ScaffoldedActions

  attr_reader :user, :filtered_user_info

  skip_before_action :authorize_request, only: :create
  before_action :set_user,       only: [:show, :update, :destroy]
  before_action :check_user,     only: [:show, :update, :destroy]

  # GET /users/1
  def show
    filter_user_info
    render(:show)
  end

  # POST /users
  def create
    @user = new_account(user_params)

    if user.save
      filter_user_info
      @message = { text: 'Thanks for signing up.' }
      @auth_token = JsonWebToken.encode(user_id: user.id)
      render(:success, status: :created)
    else
      @errors = user.errors
      render_errors
    end
  end

  # PATCH/PUT /users/1
  def update
    if user.update(user_params)
      filter_user_info
      @message = 'Profile was successfully updated.'
      render(:success)
    else
      @errors = user.errors
      render_errors
    end
  end

  # DELETE /users/1
  def destroy
    user.destroy
    @message = 'Your user account, along with associated contacts, notes, job applications, cover letters & postings have been deleted. Thanks for using the app.'
    render('shared/destroy')
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

  # This method does same thing as the `#check_user` method in `OwnResources`.
  # However, that module brings some extra requirements, not needed here.
  # It's easier to rewrite the helper method for this controller.
  def check_user
    unless current_user?(user)
      @errors = 'You are not authorized to access or modify this resource'
      render('shared/errors', status: :unauthorized)
    end
  end

  def filter_user_info
    @filtered_user_info = User.filter_user_info(user)
  end
end
