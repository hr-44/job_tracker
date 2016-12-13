class RecruitmentsController < ApplicationController
  attr_reader :recruitment, :company

  before_action :logged_in_user
  before_action :load_company
  before_action :set_recruitment, only: :destroy

  def create
    opts = build_recruitment_params
    @recruitment = Recruitment.new(opts)

    if recruitment.save
      # TODO: send this message as part of json response
      # flash[:success] = 'Client, Agency relationship successfully added'
      redirect_to company
    else
      # TODO: send client an error message
    end
  end

  def destroy
    recruitment.destroy
    # TODO: send this message as part of json response
    # flash[:info] = 'Relationship removed'
    redirect_to company
  end

  private

  def load_company
    company_id = params[:company_id]
    @company = Company.find(company_id)
  end

  def set_recruitment
    id = params[:id]
    @recruitment = Recruitment.find(id)
  end

  def recruitment_params
    params.require(:recruitment).permit(whitelisted_attr)
  end

  def whitelisted_attr
    [:agency_id, :client_id]
  end

  def build_recruitment_params
    if company.agency?
      agency_id = company.id
      client_id = set_client_id
    else
      client_id = company.id
      agency_id = set_agency_id
    end

    recruitment_params_with_associated_ids(agency_id, client_id)
  end

  def set_client_id
    client_name = params[:recruitment][:client_name]
    Company.find_by_name(client_name).id
  end

  def set_agency_id
    agency_name = params[:recruitment][:agency_name]
    Company.find_by_name(agency_name).id
  end

  def recruitment_params_with_associated_ids(agency_id, client_id)
    recruit_id = current_user.id
    recruitment_params.merge(agency_id: agency_id,
                             client_id: client_id,
                             recruit_id: recruit_id)
  end
end
