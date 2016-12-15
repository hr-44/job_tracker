class SearchSuggestionsController < ApplicationController
  def index
    term = params[:term] # set by jquery-ui/autocomplete
    key  = params[:key]  # set by coffeescript
    @suggestions = SearchSuggestion.terms_for(term, key)
    render(:index)
  end
end
