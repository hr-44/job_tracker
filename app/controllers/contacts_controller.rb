class ContactsController < ApplicationController
  include SortingHelper
  include ScaffoldedActions
  include OwnResources

  attr_reader :contact

  helper_method :sort_column, :sort_direction

  before_action :logged_in_user
  before_action :set_contact,   only: [:show, :edit, :update, :destroy]
  before_action :check_user,    only: [:show, :edit, :update, :destroy]

  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = collection_belonging_to_user
    @contacts = @contacts.sorted
    @contacts = custom_index_sort if params[:sort]
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
    @notable = contact
    @notes = @notable.notes
    @note = Note.new
  end

  # GET /contacts/new
  def new
    company_id = params[:company_id]
    opts = { company_id: company_id }
    @contact = Contact.new(opts)
  end

  # GET /contacts/1/edit
  def edit
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
    respond_to do |format|
      if contact.update(contact_params_with_associated_ids)
        successful_update(format, contact)
      else
        failed_update(format, contact)
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      destruction(format, contacts_url)
    end
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
    company_id = set_company_id
    user_id    = current_user.id
    contact_params.merge(company_id: company_id, user_id: user_id)
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
