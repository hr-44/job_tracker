class ContactsController < ApplicationController
  include SortingHelper
  include ScaffoldedActions
  include OwnResources

  attr_reader :contact

  helper_method :sort_column, :sort_direction

  before_action :set_contact,   only: [:show, :update, :destroy]
  before_action :check_user,    only: [:show, :update, :destroy]

  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = collection_belonging_to_user
    @contacts = @contacts.sorted
    @contacts = custom_index_sort if params[:sort]
    render(:index)
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
    @notable = contact # TODO: remove variable? not sure it's needed w/ JSON only
    @notes = @notable.notes
    @note = Note.new
    render(:show)
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params_with_associated_ids)
    save_and_respond(contact)
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    if contact.update(contact_params_with_associated_ids)
      successful_update
    else
      @errors = contact.errors
      render_errors
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    @message = "Contact, #{contact.name}, deleted"

    render('shared/destroy')
  end

  private

  def set_contact
    id = params[:id]
    @contact = Contact.belonging_to_user(current_user.id).friendly.find(id)
  end

  def whitelisted_attr
    [:first_name, :last_name, :title, :email, :company_id,
     :phone_office, :phone_mobile, :sort, :direction, :name, :company_name]
  end

  def contact_params
    params.require(:contact).permit(whitelisted_attr)
  end

  def contact_params_with_associated_ids
    user_id = current_user.id

    if params[:contact][:company_name].present?
      company_id = set_company_id
      contact_params.merge(company_id: company_id, user_id: user_id)
    else
      contact_params.merge(user_id: user_id)
    end
  end

  def set_company_id
    company_name = params[:contact][:company_name]
    Company.get_record_val_by(:name, company_name)
  end

  def model
    Contact
  end

  def collection
    @contacts
  end

  def member
    @contact
  end

  def default_sorting_column
    'name'
  end
end
