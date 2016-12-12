class SearchSuggestionsController < ApplicationController
  before_action :logged_in_user

  def index
    term = params[:term] # set by jquery-ui/autocomplete
    key  = params[:key]  # set by coffeescript
    @suggestions = SearchSuggestion.terms_for(term, key)
    render(:index)
  end
end
