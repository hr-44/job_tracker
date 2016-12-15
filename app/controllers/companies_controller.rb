class CompaniesController < ApplicationController
  include SortingHelper
  include ScaffoldedActions

  attr_reader :company

  helper_method :sort_column, :sort_direction

  before_action :set_company, only: [:show, :update]

  def index
    @companies = search_filter_sort
    render(:index)
  end

  def show
    @contacts = contacts_belonging_to_user_and_current_company
    @job_applications = job_applications_belonging_to_user_and_current_company
    render(:show)
  end

  def create
    @company = Company.new(company_params)
    save_and_respond(company)
  end

  def update
    if company.update(company_params)
      successful_update
    else
      @errors = company.errors
      render_errors
    end
  end

  private

  def set_company
    id = params[:id]
    @company = Company.find(id)
  end

  def company_params
    params.require(:company).permit(whitelisted_attr)
  end

  def contacts_belonging_to_user_and_current_company
    user_id    = current_user.id
    company_id = company.id
    Contact.belonging_to_user(user_id)
           .where(company_id: company_id)
  end

  def job_applications_belonging_to_user_and_current_company
    user_id    = current_user.id
    company_id = company.id
    JobApplication.belonging_to_user(user_id)
                  .where(company_id: company_id)
  end

  def whitelisted_attr
    [:name, :website, :sort, :direction, :search, category_ids: []]
  end

  def model
    Company
  end

  def collection
    @companies
  end

  def default_sorting_column
    'companies.name'
  end

  def sort_col_and_dir
    sort_column + ' ' + sort_direction
  end

  def search_filter_sort
    name_query = params[:search] || ''
    category_names = params[:category_names] || []
    Company.search_and_filter(name_query, category_names)
           .order(sort_col_and_dir)
  end
end
