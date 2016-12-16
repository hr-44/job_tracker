module RouteReporter
  class << self
    attr_reader :routes

    def routes!
      routes_objects = Rails.application.routes.routes
      @routes = routes_objects.map { |r| extract_info(r) }
    end

    private

    def extract_info(r)
      {
        verb: r.verb,
        path: r.path.spec.to_s,
        controller: r.defaults[:controller],
        action: r.defaults[:action]
      }
    end
  end
end
