# frozen_string_literal: true

module Accounts
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
    # before_action :configure_account_update_params, only: [:update]

    def update_resource(resource, params)
      if resource.provider == 'google'
        params.delete('current_password')
        resource.password = params['password']
        resource.update_without_password(params)
      else
        resource.update_with_password(params)
      end
    end
    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource
    # def create
    #   @account = Account.new(account_params)

    #   if @account.save
    #     @user = @account.user.build(user_params)

    #     if @user.save
    #       redirect_to root_path, notice: 'Account and user were successfully created.'
    #     else
    #       render :new
    #     end
    #   else
    #     render :new
    #   end
    # end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      puts params
      devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation,
                                                         { user_attributes: %i[first_name last_name level ride_type city state] }])
    end
    # def create_account_params
    #   params.require(:account).permit(:email, :password, :password_confirmation,
    #                                   user_attributes: %i[first_name last_name level ride_type city state])
    # end

    # private

    # def account_params
    #   params.require(:account).permit(:email, :password, :password_confirmation)
    # end

    # def user_params
    #   params.require(:user).permit(:first_name, :last_name, :level, :ride_type, :city, :state)
    # end
    # If you have extra params to permit, append them to the sanitizer.
    # def configure_account_update_params
    #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
    # end

    # The path used after sign up.
    def after_sign_up_path_for(resource)
      puts current_account.user
      user_path || super(resource)
    end

    # The path used after sign up for inactive accounts.
    def after_inactive_sign_up_path_for(resource)
      puts current_account.user
      edit_user_path || super(resource)
    end
  end
end
