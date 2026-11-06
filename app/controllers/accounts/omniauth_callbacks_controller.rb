# frozen_string_literal: true

module Accounts
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google
      account = Account.from_omniauth(request.env['omniauth.auth'])
      raise ArgumentError, 'Account is inactive' unless account.active_for_authentication?

      sign_in_and_redirect account, event: :authentication
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique, ArgumentError
      redirect_to new_account_session_path,
        alert: 'Google sign-in could not be completed. Please use your existing sign-in method if you have an account.'
    end

    protected

    def after_omniauth_failure_path_for(_scope)
      new_account_session_path
    end

    def after_sign_in_path_for(_resource_or_scope)
      user_path
    end
  end
end
