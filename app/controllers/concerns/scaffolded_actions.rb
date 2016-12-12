module ScaffoldedActions
  private

  def save_and_respond(object)
    if object.save
      successful_creation(object)
    else
      failed_creation(object)
    end
  end

  def successful_creation(object, message = nil)
    message ||= "#{model} was successfully created."
    canned_success(object, message, :created)
  end

  def failed_creation(object)
    render json: object.errors, status: :unprocessable_entity
  end

  def successful_update(object, message = nil)
    message ||= "#{model} was successfully updated."
    canned_success(object, message, :ok)
  end

  def failed_update(object)
    render json: object.errors, status: :unprocessable_entity
  end

  def destruction(redirect_url)
    # TODO: send this message as part of json response
    # flash = { info: "#{model} was successfully destroyed." }
    head :no_content
  end

  def canned_success(object, message, status)
    # TODO: send this message as part of json response
    # flash = { success: message }
    render :show, status: status, location: object
  end
end
