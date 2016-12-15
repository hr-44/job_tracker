class CategoriesController < ApplicationController
  attr_reader :category, :companies

  before_action :set_category

  def show
    @companies = category.companies
    render(:show)
  end

  private

  def set_category
    id = params[:id]
    @category = Category.find(id)
  end
end
