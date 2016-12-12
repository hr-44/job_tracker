module Sessions
  class BaseController < ApplicationController
    attr_reader :user

    def destroy
      log_out if logged_in?
      render('sessions/logout')
    end
  end
end
