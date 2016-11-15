class JobApplicationsController < ApplicationController
  include SortingHelper
  include ScaffoldedActions
  include OwnResources

  attr_reader :job_application

  helper_method :sort_column, :sort_direction

  before_action :logged_in_user
  before_action :set_job_application, only: [:show, :edit, :update, :destroy]
  before_action :check_user,          only: [:show, :edit, :update, :destroy]

  # GET /job_applications
  # GET /job_applications.json
  def index
    active = params[:active]
    @job_applications = collection_belonging_to_user
    @job_applications = @job_applications.active(active).sorted
    @job_applications = custom_index_sort if params[:sort]
  end

  # GET /job_applications/1
  # GET /job_applications/1.json
  def show
    @notable = job_application
    @notes = @notable.notes
    @note = Note.new
  end

  # GET /job_applications/new
  def new
    company_id = params[:company_id]
    opts = { company_id: company_id }
    @job_application = JobApplication.new(opts)
  end

  # GET /job_applications/1/edit
  def edit
  end

  # POST /job_applications
  # POST /job_applications.json
  def create
    @job_application = JobApplication.new(job_application_params_with_associated_ids)
    save_and_respond(job_application)
  end

  # PATCH/PUT /job_applications/1
  # PATCH/PUT /job_applications/1.json
  def update
    respond_to do |format|
      if job_application.update(job_application_params_with_associated_ids)
        successful_update(format, job_application)
      else
        failed_update(format, job_application)
      end
    end
  end

  # DELETE /job_applications/1
  # DELETE /job_applications/1.json
  def destroy
    @job_application.destroy
    respond_to do |format|
      destruction(format, job_applications_url)
    end
  end

  private

  def set_job_application
    @job_application = JobApplication.find(params[:id])
  end

  def whitelisted_attr
    [:company_id, :active, :sort, :direction, :title, :company_name]
  end

  def job_application_params
    params.require(:job_application).permit(whitelisted_attr)
  end

  def job_application_params_with_associated_ids
    company_id = set_company_id
    user_id    = current_user.id
    job_application_params.merge(company_id: company_id, user_id: user_id)
  end

  def set_company_id
    company_name = params[:job_application][:company_name]
    Company.get_record_val_by(:name, company_name)
  end

  def model
    JobApplication
  end

  def collection
    @job_applications
  end

  def member
    @job_application
  end

  def default_sorting_column
    'updated_at'
  end
end
