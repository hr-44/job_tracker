class CategoriesController < ApplicationController
  attr_reader :category, :companies

  before_action :logged_in_user
  before_action :set_category

  def show
    @companies = category.companies
    json = {
      category: category,
      companies: companies
    }
    render(json: json)
  end

  private

  def set_category
    id = params[:id]
    @category = Category.find(id)
  end
end
