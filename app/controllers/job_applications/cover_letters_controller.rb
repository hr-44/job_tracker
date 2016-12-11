module JobApplications
  class CoverLettersController < ApplicationController
    include SortingHelper
    include ScaffoldedActions
    include OwnResources

    attr_reader :cover_letter

    helper_method :sort_column, :sort_direction

    before_action :logged_in_user
    before_action :set_cover_letter, only: [:show, :edit, :update, :destroy]
    before_action :check_user,       only: [:show, :edit, :update, :destroy]

    # GET /cover_letters
    # GET /cover_letters.json
    def index
      @cover_letters = collection_belonging_to_user
      @cover_letters = @cover_letters.sorted
      @cover_letters = custom_index_sort if params[:sort]
      json = {
        cover_letters: @cover_letters,
        params: {
          sort: params[:sort],
          direction: params[:direction]
        }
      }
      render(json: json)
    end

    # GET /cover_letters/1
    # GET /cover_letters/1.json
    def show
      json = {
        cover_letter: cover_letter
      }
      render(json: json)
    end

    # GET /cover_letters/new
    def new
      job_application_id = params[:job_application_id]

      opts = {
        job_application_id: job_application_id,
        sent_date: Time.now.utc
      }

      @cover_letter = CoverLetter.new(opts)
    end

    # GET /cover_letters/1/edit
    def edit
    end

    # POST /cover_letters
    # POST /cover_letters.json
    def create
      @cover_letter = CoverLetter.new(cover_letter_params_with_associated_ids)

      if cover_letter.save
        json = {
          cover_letter: cover_letter
        }
        render(json: json)
      else
        json = {
          text: cover_letter.errors
        }
        render(json: json, status: 409)
      end
    end

    # PATCH/PUT /cover_letters/1
    # PATCH/PUT /cover_letters/1.json
    def update
      if cover_letter.update(cover_letter_params)
        json = {
          cover_letter: cover_letter
        }
        render(json: json)
      else
        json = {
          text: cover_letter.errors
        }
        render(json: json, status: 409)
      end
    end

    # DELETE /cover_letters/1
    # DELETE /cover_letters/1.json
    def destroy
      @cover_letter.destroy
      json = {
        message: "Cover letter for, #{@cover_letter.job_application_title}, deleted"
      }
      render(json: json)
    end

    private

    def set_cover_letter
      id = params[:job_application_id]
      @cover_letter = CoverLetter.find_by_job_application_id(id)
    end

    def whitelisted_attr
      [:job_application_id, :sent_date, :content, :job_application_title]
    end

    def cover_letter_params
      params.require(:job_applications_cover_letter).permit(whitelisted_attr)
    end

    def cover_letter_params_with_associated_ids
      job_application_id = params[:job_application_id]
      cover_letter_params.merge(job_application_id: job_application_id)
    end

    def model
      CoverLetter
    end

    def collection
      @cover_letters
    end

    def member
      @cover_letter
    end

    def default_sorting_column
      'sent_date'
    end
  end
end
