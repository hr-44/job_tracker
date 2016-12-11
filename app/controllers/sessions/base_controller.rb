module Sessions
  class BaseController < ApplicationController
    attr_reader :user

    def destroy
      log_out if logged_in?
      render(json: { message: 'You have logged out' })
    end
  end
end
