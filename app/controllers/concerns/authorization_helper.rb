module AuthorizationHelper
  private

  def authorize_api_request(headers)
    token = decode_auth_token(headers)

    if token
      user = find_user_from_token(token)
      return user if user
      add_auth_error!('User not found')
    end

    add_auth_error!('Token invalid')
    nil
  end

  def decode_auth_token(headers)
    result = http_auth_header(headers)
    JsonWebToken.decode(result)
  end

  def http_auth_header(headers)
    if headers['Authorization'].present?
      split_headers = headers['Authorization'].split(' ')
      split_headers.last
    else
      add_auth_error!('Authorization header not present. Missing token.')
      nil
    end
  end

  def find_user_from_token(token)
    user_id = token[:user_id]
    User.find(user_id)
  end

  def add_auth_error!(msg)
    @auth_errors = [] unless @auth_errors.present?
    @auth_errors.push(msg)
  end
end
