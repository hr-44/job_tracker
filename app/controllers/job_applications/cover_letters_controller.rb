module JobApplications
  class CoverLettersController < ApplicationController
    include SortingHelper
    include ScaffoldedActions
    include OwnResources

    attr_reader :cover_letter

    helper_method :sort_column, :sort_direction

    before_action :set_cover_letter, only: [:show, :update, :destroy]
    before_action :check_user,       only: [:show, :update, :destroy]

    # GET /cover_letters
    # GET /cover_letters.json
    def index
      @cover_letters = collection_belonging_to_user
      @cover_letters = @cover_letters.sorted
      @cover_letters = custom_index_sort if params[:sort]
      render(:index)
    end

    # GET /cover_letters/1
    # GET /cover_letters/1.json
    def show
      render(:show)
    end

    # POST /cover_letters
    # POST /cover_letters.json
    def create
      @cover_letter = CoverLetter.new(cover_letter_params_with_associated_ids)
      save_and_respond(cover_letter)
    end

    # PATCH/PUT /cover_letters/1
    # PATCH/PUT /cover_letters/1.json
    def update
      if cover_letter.update(cover_letter_params)
        successful_update
      else
        @errors = cover_letter.errors
        render_errors(status: 409)
      end
    end

    # DELETE /cover_letters/1
    # DELETE /cover_letters/1.json
    def destroy
      @cover_letter.destroy
      @message = "Cover letter for, #{@cover_letter.job_application_title}, deleted"

      render('shared/destroy')
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
