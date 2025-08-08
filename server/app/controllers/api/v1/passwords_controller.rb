# frozen_string_literal: true

class Api::V1::PasswordsController < ApplicationController
  skip_before_action :authenticate_request, only: [:forgot, :reset]

  # POST /api/v1/passwords/forgot
  def forgot
    user = User.find_by(email: params[:email]&.downcase)
    
    if user
      # Generate password reset token (you would typically save this to the user)
      reset_token = SecureRandom.urlsafe_base64(32)
      reset_expires_at = 1.hour.from_now
      
      # In production, you would:
      # 1. Save reset_token and reset_expires_at to user record
      # 2. Send password reset email with token
      
      # For now, just return success (don't reveal if email exists)
      render json: {
        message: 'If an account with that email exists, password reset instructions have been sent.'
      }, status: :ok
    else
      # Don't reveal whether the email exists or not
      render json: {
        message: 'If an account with that email exists, password reset instructions have been sent.'
      }, status: :ok
    end
  end

  # POST /api/v1/passwords/reset
  def reset
    # In production, you would:
    # 1. Find user by reset token
    # 2. Verify token hasn't expired
    # 3. Update password and clear reset token
    
    render json: {
      error: 'Password reset functionality not yet implemented'
    }, status: :not_implemented
  end

  # PUT /api/v1/passwords/change
  def change
    if current_user.authenticate(change_params[:current_password])
      current_user.update!(
        password: change_params[:new_password],
        password_confirmation: change_params[:password_confirmation]
      )
      
      render json: {
        message: 'Password changed successfully'
      }, status: :ok
    else
      render json: {
        error: 'Current password is incorrect'
      }, status: :unauthorized
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: {
      error: 'Password change failed',
      details: e.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  private

  def change_params
    params.require(:password).permit(:current_password, :new_password, :password_confirmation)
  end
end