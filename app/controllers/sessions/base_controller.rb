module Sessions
  class BaseController < ApplicationController
    attr_reader :user

    def destroy
      log_out if logged_in?
      # TODO: send this message as part of json response
      # flash[:info] = 'You have logged out'
      redirect_to(root_url)
    end
  end
end
