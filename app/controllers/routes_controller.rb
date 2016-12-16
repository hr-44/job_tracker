class RoutesController < ApplicationController
  before_action :routes!

  def index
    render(:index)
  end

  private

  def routes!
    RouteReporter.routes! if routes?
    @routes = RouteReporter.routes
  end

  def routes?
    params[:refresh] || !RouteReporter.routes.present?
  end
end
