module OwnResources
  private

  def check_user
    unless correct_user?
      @errors = 'You are not authorized to access or modify this resource'
      render('shared/errors', status: :unauthorized)
    end
  end

  def correct_user?
    current_user?(member.user)
  end

  def collection_belonging_to_user
    model.belonging_to_user(current_user.id)
  end
end
