# frozen_string_literal: true

module AuthenticationHelpers
  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s

  def user_login(user)
    token = JWT.encode({ user_id: user.id }, SECRET_KEY)

    request.headers['Authorization'] = "Bearer #{token}"
  end

  def http_login(username, password)
    if page.driver.respond_to?(:basic_auth)
      page.driver.basic_auth(username, password)
    elsif page.driver.respond_to?(:basic_authorize)
      page.driver.basic_authorize(username, password)
    elsif page.driver.respond_to?(:browser) &&
          page.driver.browser.respond_to?(:basic_authorize)
      page.driver.browser.basic_authorize(username, password)
    else
      raise 'Authentication error'
    end
  end
end
