module JobApplications
  class PostingsController < ApplicationController
    include SortingHelper
    include ScaffoldedActions
    include OwnResources

    attr_reader :posting

    helper_method :sort_column, :sort_direction

    before_action :logged_in_user
    before_action :set_posting, only: [:show, :edit, :update, :destroy]
    before_action :check_user,  only: [:show, :edit, :update, :destroy]

    # GET /postings
    # GET /postings.json
    def index
      @postings = collection_belonging_to_user
      @postings = @postings.sorted
      @postings = custom_index_sort if params[:sort]
      json = {
        postings: @postings,
        params: {
          sort: params[:sort],
          direction: params[:direction]
        }
      }
      render(json: json)
    end

    # GET /postings/1
    # GET /postings/1.json
    def show
      json = {
        posting: posting
      }
      render(json: json)
    end

    # GET /postings/new
    def new
      opts = {
        job_application_id: params[:job_application_id],
        posting_date: Time.now.utc
      }
      @posting = Posting.new(opts)
    end

    # GET /postings/1/edit
    def edit
    end

    # POST /postings
    # POST /postings.json
    def create
      @posting = Posting.new(posting_params_with_associated_ids)

      if posting.save
        json = {
          posting: posting
        }
        render(json: json, status: :created)
      else
        json = {
          text: posting.errors
        }
        render(json: json, status: 409)
      end
    end

    # PATCH/PUT /postings/1
    # PATCH/PUT /postings/1.json
    def update
      if posting.update(posting_params)
        json = {
          posting: posting
        }
        render(json: json)
      else
        json = {
          text: posting.errors
        }
        render(json: json, status: 409)
      end
    end

    # DELETE /postings/1
    # DELETE /postings/1.json
    def destroy
      @posting.destroy
      json = {
        message: "Posting, #{@posting.job_title}, deleted"
      }
      render(json: json)
    end

    private

    def set_posting
      id = params[:job_application_id]
      @posting = Posting.find_by_job_application_id(id)
    end

    def whitelisted_attr
      [:job_application_id, :posting_date, :source_id, :job_title, :content,
       :job_application_title]
    end

    def posting_params
      params.require(:job_applications_posting).permit(whitelisted_attr)
    end

    def posting_params_with_associated_ids
      job_application_id = params[:job_application_id]
      posting_params.merge(job_application_id: job_application_id)
    end

    def model
      Posting
    end

    def collection
      @postings
    end

    def member
      @posting
    end

    def default_sorting_column
      'posting_date'
    end
  end
end
