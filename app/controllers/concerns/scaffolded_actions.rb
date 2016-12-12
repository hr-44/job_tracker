module ScaffoldedActions
  private

  def save_and_respond(object)
    if object.save
      successful_creation
    else
      render_errors
    end
  end

  def successful_creation
    render_show(status: :created)
  end

  def successful_update
    render_show(status: :ok)
  end

  def render_errors(status: :unprocessable_entity)
    render('shared/errors', status: status)
  end

  def render_show(status: :ok)
    render(:show, status: status, content_type: :json)
  end
end
